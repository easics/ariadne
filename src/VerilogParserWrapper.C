// This file is part of ariadne.
//
// ariadne is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// ariadne is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// ariadne. If not, see <https://www.gnu.org/licenses/>.


#include "VerilogParserWrapper.h"
#include "verilogParser.h"
#include "Module.h"
#include "StringUtil.h"
#include "SignalPort.h"
#include "ConstGeneric.h"
#include "SourceLocManager.h"
#include <iostream>

extern unsigned int verilogcolumn_number;
extern unsigned int verilogline_number;
extern int verilogdebug;
typedef std::map<unsigned int, std::string> LineStringMap;
static LineStringMap docComments;
static LineStringMap portComments;
static unsigned int entityStartLineNumber;
static std::string getMatchingGroupComment(unsigned int lineNumber)
{
  LineStringMap::const_iterator docComment;
  std::string result;
  unsigned int firstCommentLine = 0;
  unsigned int previousLine = 1000000000u;
  for (docComment=docComments.begin(); docComment!=docComments.end();
       ++docComment)
    {
      if (docComment->first > lineNumber)
        break;
      else
        {
          // non-comment line starts new group
          if (previousLine + 1 == docComment->first)
            result += docComment->second + "\n";
          else
            {
              firstCommentLine = docComment->first;
              result = docComment->second + "\n";
            }
        }
      previousLine = docComment->first;
    }

  if (firstCommentLine >= entityStartLineNumber)
    return result;
  else
    return "";
}

static unsigned int previousPortLineNumber = 0;
static std::string getMatchingPortComment(unsigned int lineNumber)
{
  std::string result;
  unsigned int firstCommentLine = 0;
  unsigned int previousLine = 1000000000u;
  for (auto portComment=portComments.begin(); portComment!=portComments.end();
       ++portComment)
    {
      if (portComment->first <= previousPortLineNumber)
        continue;
      if (portComment->first > lineNumber)
        break;
      else
        {
          // non-comment line starts new thing
          if (previousLine + 1 == portComment->first)
            result += portComment->second + "\n";
          else
            {
              firstCommentLine = portComment->first;
              result = portComment->second + "\n";
            }
        }
      previousLine = portComment->first;
    }
  previousPortLineNumber = lineNumber;

  if (firstCommentLine >= entityStartLineNumber)
    return result;
  else
    return "";
}

void storeVerilogDocComment(const char * text, unsigned int lineNumber,
                            unsigned int columnNumber)
{
  docComments[lineNumber] = text;
}

void storeVerilogPortComment(const char * text, unsigned int lineNumber,
                             unsigned int columnNumber)
{
  portComments[lineNumber] = text;
}

VerilogParserWrapper::VerilogParserWrapper(Module * module)
  : module_(module), correctEntity_(false), inTask_(false),
    inModuleParameterPortList_(false), moduleParameterPortListExists_(false),
    last_port_declaration_(nullptr)

{
}

VerilogParserWrapper::~VerilogParserWrapper()
{
}

void VerilogParserWrapper::parseFile(const std::string & filename)
{
  verilogdebug = 0;
  filename_ = filename;
  docComments.clear();
  portComments.clear();
  verilogParser parser;
  parser.parseFile(filename.c_str());
  traverse();
}

void VerilogParserWrapper::module_start(AST & node)
{
  AST_list & nodes = node.getNodes();
  // nodes[1] = K_MODULE
  entityStartLineNumber = nodes[1]->line_number;
  if (entityStartLineNumber > 2)
    entityStartLineNumber -= 2;
  previousPortLineNumber = entityStartLineNumber;

  CaseAwareString moduleName(true, nodes[2]->getString());
  correctEntity_ = (moduleName== module_->getEntityName());
  if (correctEntity_)
    {
      module_->setEntityName(moduleName);
      module_->parsedIt();
      module_->setKeepCase();
    }
}

void VerilogParserWrapper::module_end_exit(AST & node)
{
  correctEntity_ = false;
}

void VerilogParserWrapper::module_item(AST & node)
{
  AST_list & nodes = node.getNodes();

  if (!nodes.empty() && ((nodes[0]->getTokenType() == "K_TASK") ||
                         (nodes[0]->getTokenType() == "K_FUNCTION")))
    {
      inTask_ = true;
    }
}

void VerilogParserWrapper::module_item_exit(AST & node)
{
  AST_list & nodes = node.getNodes();

  if (!nodes.empty() && ((nodes[0]->getTokenType() == "K_TASK") ||
                         (nodes[0]->getTokenType() == "K_FUNCTION")))
    {
      inTask_ = false;
    }
}

void VerilogParserWrapper::module_parameter_port_list(AST & node)
{
  if (node.getNodes().size() > 0)
    {
      inModuleParameterPortList_ = true;
      moduleParameterPortListExists_ = true;
    }
}

void VerilogParserWrapper::module_parameter_port_list_exit(AST & node)
{
  inModuleParameterPortList_ = false;
}

void VerilogParserWrapper::port_declaration(AST & node)
{
  // Note: when adapting this method, also check module_port_declaration!
  if (!correctEntity_)
    return;

  if (inTask_)
    return;

  using namespace StringUtil;
  AST_list & nodes = node.getNodes();

  CaseAwareString groupComment(true, getMatchingGroupComment(node.line_number));
  if (groupComment.size() < 4)
    groupComment.clear();
  else
    {
      // Remove first comment sign
      groupComment = groupComment.substr(3).strip(); // remove ///
      StringUtil::replace("///", "", groupComment);
    }
  CaseAwareString portComment(true, getMatchingPortComment(node.line_number));
  if (portComment.size() < 4)
    portComment.clear();
  else
    {
      // Remove first comment sign
      portComment = portComment.substr(4).strip(); // remove ////
      StringUtil::replace("////", "", portComment);
    }

  auto const & directionNode = *nodes[1];
  std::string directionString;
  if (directionNode.getTokenType() == "K_INPUT")
    directionString = "in";
  else if (directionNode.getTokenType() == "K_OUTPUT")
    directionString = "out";
  else if (directionNode.getTokenType() == "K_INOUT")
    directionString = "inout";

  CaseAwareString direction(true, directionString);
  AST const * range_opt = nullptr;
  if (nodes.size() >= 6)   // in, inout, out or expression
    {
      AST const * data_type_or_implicit = nodes[3];
      AST_list const & subnodes = data_type_or_implicit->getNodes();
      if (subnodes.empty())
        {
          range_opt = nullptr; // implicit type
        }
      else if (subnodes[0]->getName() == "data_type")
        {
          AST const * data_type = subnodes[0];
          AST_list const & subsubnodes = data_type->getNodes();
          if (subsubnodes.size() == 3)
            range_opt = subsubnodes[2]; // dimensions_opt
        }
      else if (subnodes.size() == 2)
        {
          range_opt = subnodes[1]; // dimensions_opt
        }
      else
        {
          range_opt = subnodes[0]; // dimensions
        }
    }
  else if (nodes.size() == 4) // wreal
    {
    }
  CaseAwareString type = getType(*nodes[2], range_opt);
  SignalPort * sigPort =
    new SignalPort(CaseAwareString(true, nodes[4]->getString()),
                   type, false, direction, -1,
                   SourceLocManager::registerNode(filename_, &node));
  sigPort->setGroupComment(groupComment);
  sigPort->setPortComment(portComment);
  module_->addSignalPort(sigPort);
  last_port_declaration_ = sigPort;
}

void VerilogParserWrapper::module_port_declaration(AST & node)
{
  // Note: when adapting this method, also check port_declaration!
  if (!correctEntity_)
    return;

  if (inTask_)
    return;

  using namespace StringUtil;
  AST_list & nodes = node.getNodes();

  CaseAwareString groupComment(true, getMatchingGroupComment(node.line_number));
  if (groupComment.size() < 4)
    groupComment.clear();
  else
    {
      // Remove first comment sign
      groupComment = groupComment.substr(3).strip(); // remove ///
      StringUtil::replace("///", "", groupComment);
    }
  CaseAwareString portComment(true, getMatchingPortComment(node.line_number));
  if (portComment.size() < 4)
    portComment.clear();
  else
    {
      // Remove first comment sign
      portComment = portComment.substr(4).strip(); // remove ////
      StringUtil::replace("////", "", portComment);
    }

  auto const & directionNode = *nodes[1];
  std::string directionString;
  if (directionNode.getTokenType() == "K_INPUT")
    directionString = "in";
  else if (directionNode.getTokenType() == "K_OUTPUT")
    directionString = "out";
  else if (directionNode.getTokenType() == "K_INOUT")
    directionString = "inout";

  CaseAwareString direction(true, directionString);
  AST const * range_opt = nullptr;
  if (nodes.size() >= 6)   // in, inout, out or expression
    {
      AST const * data_type_or_implicit = nodes[3];
      AST_list const & subnodes = data_type_or_implicit->getNodes();
      if (subnodes.empty())
        {
          range_opt = nullptr; // implicit type
        }
      else if (subnodes[0]->getName() == "data_type")
        {
          AST const * data_type = subnodes[0];
          AST_list const & subsubnodes = data_type->getNodes();
          if (subsubnodes.size() == 3)
            range_opt = subsubnodes[2]; // dimensions_opt
        }
      else if (subnodes.size() == 2)
        {
          range_opt = subnodes[1]; // dimensions_opt
        }
      else
        {
          range_opt = subnodes[0]; // dimensions
        }
    }
  else if (nodes.size() == 4) // wreal
    {
    }
  CaseAwareString type = getType(*nodes[2], range_opt);
  for (auto subnode : nodes[4]->getNodes())
    {
      SignalPort * sigPort =
        new SignalPort(CaseAwareString(true, subnode->getString()),
                   type, false, direction, -1,
                   SourceLocManager::registerNode(filename_, subnode));
      sigPort->setGroupComment(groupComment);
      sigPort->setPortComment(portComment);
      module_->addSignalPort(sigPort);
      last_port_declaration_ = sigPort;
    }
}

void VerilogParserWrapper::list_of_port_declarations(AST & node)
{
}

void VerilogParserWrapper::list_of_port_declarations_exit(AST & node)
{
  AST_list const & nodes = node.getNodes();
  if (nodes.size() == 2 && nodes[1]->getTokenType() == "IDENTIFIER")
    {
      // input [2:0] a, b
      //                ^^  This part
      //                    -> use info from port a
      SignalPort * sigPort =
        new SignalPort(CaseAwareString(true, nodes[1]->getString()),
                       last_port_declaration_->getType(),
                       !last_port_declaration_->isPort(),
                       last_port_declaration_->getDirection(), -1,
                       SourceLocManager::registerNode(filename_, nodes[1]));
      if (! inTask_)
        {
          module_->addSignalPort(sigPort);
        }
    }
}

void VerilogParserWrapper::parameter_assign(AST & node)
{
  if (!correctEntity_)
    return;

  // If the module parameter port list exists:
  // a parameter inside the module is an implicit localparam
  // do not consider these implicit localparams as generics
  if (moduleParameterPortListExists_ && !inModuleParameterPortList_)
    return;

  AST_list & nodes = node.getNodes();
  CaseAwareString defaultValue(true, normalizeString(nodes[2]->text()));
  // if it looks like verilog style 16'h, convert it to VHDL syntax
  // also remove _ if present then
  // and make the type std_logic_vector, because that is what I happen to need
  // today
  std::string parameterType = "integer";
  CaseAwareString::size_type tickHPos =
    defaultValue.find(CaseAwareString(false, "'h"));
  CaseAwareString::size_type tickBPos =
    defaultValue.find(CaseAwareString(false, "'b"));
  if (tickHPos != std::string::npos)
    {
      parameterType = "std_logic_vector";
      unsigned int bitWidth = std::stoul(defaultValue.str());
      defaultValue.replace("_", "");
      defaultValue = defaultValue.substr(tickHPos + 2);
      if (bitWidth % 4 == 0)
        {
          defaultValue = CaseAwareString(true, std::string(bitWidth/4, '0')) +
            defaultValue;
          defaultValue = defaultValue.substr(defaultValue.size() - bitWidth/4);
          defaultValue = "x\"" + defaultValue + "\"";
        }
      else
        {
          defaultValue = CaseAwareString(true, std::string(bitWidth, '0')) +
            defaultValue;
          defaultValue = defaultValue.substr(defaultValue.size() - bitWidth);
          defaultValue = "\"" + defaultValue + "\"";
        }
    }
  else if (tickBPos != std::string::npos)
    {
      parameterType = "std_logic_vector";
      unsigned int bitWidth = std::stoul(defaultValue.str());
      defaultValue.replace("_", "");
      defaultValue = defaultValue.substr(tickBPos + 2);
      defaultValue = CaseAwareString(true, std::string(bitWidth, '0')) +
        defaultValue;
      defaultValue = defaultValue.substr(defaultValue.size() - bitWidth);
      defaultValue = "\"" + defaultValue + "\"";
    }
  else if (defaultValue == "\"FALSE\"")
    {
      parameterType = "boolean";
      defaultValue = CaseAwareString(true, "false");
    }
  else if (defaultValue == "\"TRUE\"")
    {
      parameterType = "boolean";
      defaultValue = CaseAwareString(true, "true");
    }
  ConstGeneric * constGeneric =
    new ConstGeneric(CaseAwareString(true, nodes[0]->getString()),
                     CaseAwareString(true, parameterType), false, defaultValue,
                     SourceLocManager::registerNode(filename_, &node));
  module_->addConstGeneric(constGeneric);
}

#if 0
void VerilogParserWrapper::interf_element(AST & node)
{
  using namespace StringUtil;
  if (interf_list_mode_ == PORTS)
    {
      AST_list & nodes = node.getNodes();
      AST_list & idf_list = nodes[1]->getNodes();
      std::string groupComment = getMatchingGroupComment(node.line_number);
      if (groupComment.size() < 4)
        groupComment.clear();
      else
        {
          // Remove first comment sign
          groupComment = strip(groupComment.substr(3)); // remove --/
          StringUtil::replace("--/", "", groupComment);
        }
      std::string portComment = getMatchingPortComment(node.line_number);
      if (portComment.size() < 4)
        portComment.clear();
      else
        {
          // Remove first comment sign
          portComment = strip(portComment.substr(4)); // remove --//
          StringUtil::replace("--//", "", portComment);
        }
      for (AST_list::const_iterator identifier=idf_list.begin();
           identifier!=idf_list.end(); ++identifier)
        {
          AST_list & interf_element_2 = nodes[3]->getNodes();
          std::string direction;
          if (interf_element_2.empty())
            {
              // WTF no direction ?
              std::cout << "Warning : missing port direction @ " <<
                filename_ << ":" << nodes[3]->line_number << ":" <<
                nodes[3]->column_number << ", assuming in\n";
              // Standard says default direction is IN
              direction = "in";
            }
          else
            {
              direction = normalizeString(interf_element_2[0]->text());
            }
          SignalPort * sigPort =
            new SignalPort((*identifier)->getString(),
                           normalizeString(nodes[4]->text()), false, direction);
          sigPort->setGroupComment(groupComment);
          sigPort->setPortComment(portComment);
          module_->addSignalPort(sigPort,
                                 SourceLocManager::registerNode(ariFilefilename,
                                                                &node));
        }
    }
  else if (interf_list_mode_ == GENERICS)
    {
      AST_list & nodes = node.getNodes();
      AST_list & idf_list = nodes[1]->getNodes();
      for (AST_list::const_iterator identifier=idf_list.begin();
           identifier!=idf_list.end(); ++identifier)
        {
          AST_list & interf_element_2 = nodes[3]->getNodes();
          if (!interf_element_2.empty())
            {
              // WTF a generic with a direction ?
              std::cout << "Warning : generic with direction @ " <<
                filename_ << ":" << nodes[3]->line_number << ":" <<
                nodes[3]->column_number << "\n";
              continue;
            }
          AST_list & interf_element_4 = nodes[6]->getNodes();
          std::string defaultValue;
          if (interf_element_4.size() == 2)
            defaultValue = normalizeString(interf_element_4[1]->text());
          ConstGeneric * constGeneric =
            new ConstGeneric((*identifier)->getString(),
                             normalizeString(nodes[4]->text()),
                             false, defaultValue);
          module_->addConstGeneric(constGeneric,
                                 SourceLocManager::registerNode(ariFilefilename,
                                                                 &node));
        }
    }
}

#endif

std::string VerilogParserWrapper::normalizeString(const std::string & s)
{
  using namespace StringUtil;
  return strip(removeDoubleSpaces(s));
}

CaseAwareString VerilogParserWrapper::getType(const AST & net_type_opt,
                                              const AST * range_opt)
{
  using namespace StringUtil;
  if (strip(net_type_opt.text()) == "wreal")
    return CaseAwareString(false, "real");

  if (range_opt == nullptr || range_opt->getNodes().empty())
    return CaseAwareString(false, "std_logic");

  if (range_opt->getName() == "dimensions_opt")
    {
      if (range_opt->getNodes().empty())
        return CaseAwareString(false, "std_logic");
      else
        {
          range_opt = range_opt->getNodes()[0]; // dimensions
        }
    }
  AST_list & nodes = range_opt->getNodes()[0]->getNodes();
  return CaseAwareString(false, "std_logic_vector(" +
                         normalizeString(nodes[1]->text()) + " downto " +
                         normalizeString(nodes[3]->text()) + ")");
}

