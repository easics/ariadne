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


#include "VhdlParserWrapper.h"
#include "vhdlParser.h"
#include "Module.h"
#include "StringUtil.h"
#include "SignalPort.h"
#include "ConstGeneric.h"
#include "SourceLocManager.h"
#include <iostream>

extern unsigned int vhdlcolumn_number;
extern unsigned int vhdlline_number;
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

void storeDocComment(const char * text, unsigned int lineNumber,
                     unsigned int columnNumber)
{
  docComments[lineNumber] = text;
}

void storePortComment(const char * text, unsigned int lineNumber,
                      unsigned int columnNumber)
{
  portComments[lineNumber] = text;
}

VhdlParserWrapper::VhdlParserWrapper(Module * module)
  : module_(module), correctEntity_(false), interf_list_mode_(NONE)
{
}

VhdlParserWrapper::~VhdlParserWrapper()
{
}

void VhdlParserWrapper::parseFile(const std::string & filename)
{
  filename_ = filename;
  docComments.clear();
  portComments.clear();
  vhdlParser parser;
  parser.parseFile(filename.c_str());
  traverse();
}

void VhdlParserWrapper::entity_start(AST & node)
{
  //collectedContext_.clear();
  entityStartLineNumber = node.line_number;
  if (entityStartLineNumber > 2)
    entityStartLineNumber -= 2;
  previousPortLineNumber = entityStartLineNumber;

  using namespace StringUtil;
  AST_list & nodes = node.getNodes();
  CaseAwareString entityName(false, nodes[1]->getString());
  correctEntity_ = entityName == module_->getEntityName();
  if (correctEntity_)
    {
      module_->setEntityName(entityName);
      module_->parsedIt();
      module_->setContext(collectedContext_);
      collectedContext_.clear();
    }
}

void VhdlParserWrapper::use_clause_list(AST & node)
{
  using namespace StringUtil;
  AST_list & nodes = node.getNodes();
  for (AST_list::const_iterator use_clause=nodes.begin();
       use_clause!=nodes.end(); ++use_clause)
    {
      AST_list & subnodes = (*use_clause)->getNodes();
      CaseAwareString library(false, subnodes[0]->getString());
      if (subnodes.size() == 5)
        collectedContext_.add(library,
                              normalizeString(subnodes[2]->text()) + "." +
                              normalizeString(subnodes[4]->text()),
                              SourceLocManager::registerNode(filename_, &node));
      else
        collectedContext_.add(library, CaseAwareString(false,
                                                       subnodes[2]->text()),
                              SourceLocManager::registerNode(filename_, &node));
    }
}

void VhdlParserWrapper::interf_element(AST & node)
{
  using namespace StringUtil;
  if (interf_list_mode_ == PORTS)
    {
      AST_list & nodes = node.getNodes();
      AST_list & idf_list = nodes[1]->getNodes();
      CaseAwareString groupComment(false,
                                   getMatchingGroupComment(node.line_number));
      if (groupComment.size() < 4)
        groupComment.clear();
      else
        {
          // Remove first comment sign
          groupComment = groupComment.substr(3).strip(); // remove --/
          StringUtil::replace("--/", "", groupComment);
        }
      CaseAwareString portComment(false,
                                  getMatchingPortComment(node.line_number));
      if (portComment.size() < 4)
        portComment.clear();
      else
        {
          // Remove first comment sign
          portComment = portComment.substr(4).strip(); // remove --//
          StringUtil::replace("--//", "", portComment);
        }
      for (AST_list::const_iterator identifier=idf_list.begin();
           identifier!=idf_list.end(); ++identifier)
        {
          AST_list & interf_element_2 = nodes[3]->getNodes();
          CaseAwareString direction;
          if (interf_element_2.empty())
            {
              // WTF no direction ?
              std::cout << "Warning : missing port direction @ " <<
                filename_ << ":" << nodes[3]->line_number << ":" <<
                nodes[3]->column_number << ", assuming in\n";
              // Standard says default direction is IN
              direction = CaseAwareString(false, "in");
            }
          else
            {
              direction = normalizeString(interf_element_2[0]->text());
            }
          SignalPort * sigPort =
            new SignalPort(CaseAwareString(false, (*identifier)->getString()),
                           normalizeString(nodes[4]->text()), false, direction,
                           -1,
                           SourceLocManager::registerNode(filename_, &node));
          sigPort->setGroupComment(groupComment);
          sigPort->setPortComment(portComment);
          module_->addSignalPort(sigPort);
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
          CaseAwareString defaultValue;
          if (interf_element_4.size() == 2)
            defaultValue = normalizeString(interf_element_4[1]->text());
          ConstGeneric * constGeneric =
            new ConstGeneric(CaseAwareString(false, (*identifier)->getString()),
                             normalizeString(nodes[4]->text()),
                             false, defaultValue,
                             SourceLocManager::registerNode(filename_, &node));
          module_->addConstGeneric(constGeneric);
        }
    }
}

void VhdlParserWrapper::entity_decl_1(AST & node)
{
  if (correctEntity_)
    interf_list_mode_ = GENERICS;
}

void VhdlParserWrapper::entity_decl_1_exit(AST & node)
{
  interf_list_mode_ = NONE;
}

void VhdlParserWrapper::entity_decl_2(AST & node)
{
  if (correctEntity_)
    interf_list_mode_ = PORTS;
}

void VhdlParserWrapper::entity_decl_2_exit(AST & node)
{
  correctEntity_ = false;
  interf_list_mode_ = NONE;
}

CaseAwareString VhdlParserWrapper::normalizeString(const std::string & s)
{
  using namespace StringUtil;
  return CaseAwareString(false, (strip(removeDoubleSpaces(s))));
}

void skipComment(const char * comment, unsigned int row, unsigned int col)
{
}
