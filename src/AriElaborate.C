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


#include "ScriptInterface.h"
#include "AriElaborate.h"
#include "StringUtil.h"
#include "Module.h"
#include "ModuleInstance.h"
#include "ScMethod.h"
#include "SourceLocManager.h"
#include "VmaSearchInfo.h"
#include "VectorAppend.h"
#include "FileHeader.h"
#include <iostream>

//using namespace StringUtil;
using StringUtil::strip;
using StringUtil::allstrip;

AriElaborate::AriElaborate(const std::string & filename)
  : keepCase_(true), filename_(filename), hierarchy_(0), currentInfoModule_(0)
{
  ScriptInterface::instance().init("ariadne");
  const char * home = getenv("ARIADNE_HOME");
  if (home)
    {
#ifdef SCRIPT_RUBY
      ScriptInterface::instance().addRubyScriptPath(std::string(home) +"/ruby");
#endif
#ifdef SCRIPT_PYTHON
      ScriptInterface::instance().addPythonScriptPath(std::string(home) +
                                                    "/python");
#endif
    }
  ScriptInterface::instance().addTypeEquality(typeid(std::string).name(),
                                              typeid(CaseAwareString).name());
}

AriElaborate::~AriElaborate()
{
}

void AriElaborate::hierarchy(AST & node)
{
  AST_list & nodes = node.getNodes();
  Module * hierType = getModule(CaseAwareString(keepCase_,
                                                nodes[1]->getString()));
  hierarchy_ =
    hierType->makeInstance(CaseAwareString(),
                           SourceLocManager::registerNode(filename_, &node));
  currentModuleInstanceStack_.push_back(hierarchy_);
}

void AriElaborate::hierarchy_exit(AST & node)
{
  currentModuleInstanceStack_.pop_back();
}

void AriElaborate::module(AST & node)
{
  AST_list & nodes = node.getNodes();
  Module * module = getModule(CaseAwareString(keepCase_,
                                              nodes[2]->getString()));
  ModuleInstance * instance =
    module->makeInstance(CaseAwareString(keepCase_, nodes[0]->getString()),
                         SourceLocManager::registerNode(filename_, &node));
  currentModuleInstanceStack_.back()->addSubInstance(instance);
  currentModuleInstanceStack_.push_back(instance);
}

void AriElaborate::module_exit(AST & node)
{
  currentModuleInstanceStack_.pop_back();
}

void AriElaborate::info(AST & node)
{
  AST_list & nodes = node.getNodes();
  CaseAwareString name = CaseAwareString(keepCase_, nodes[1]->getString());
  ModuleMap::iterator module = modules_.find(name);
  if (module == modules_.end())
    throw AriException(EX_UNKNOWN_INFO_NAME, node,
                       SourceLocManager::registerNode(filename_, &node));
  currentInfoModule_ = module->second;
}

void AriElaborate::info_exit(AST & node)
{
  currentInfoModule_ = 0;
}

void AriElaborate::port(AST & node)
{
  AST_list & nodes = node.getNodes();
  CaseAwareString name = CaseAwareString(keepCase_, nodes[2]->getString());
  CaseAwareString groupComment;
  if (!nodes[1]->getNodes().empty())
    groupComment = CaseAwareString(keepCase_,
                                   nodes[1]->getNodes()[0]->getString()) +
      "\n";
  CaseAwareString direction;
  CaseAwareString type;
  if (nodes.size() == 7)
    {
      direction = normalizeNoWhiteString(CaseAwareString(keepCase_,
                                                         nodes[4]->text()));
      type = CaseAwareString(keepCase_, nodes[5]->text());
      if (type.strip() == "auto")
        type = CaseAwareString(true, "@UNKNOWN@");
    }
  else
    {
      direction = CaseAwareString(keepCase_, "auto");
      type = CaseAwareString(true, "@UNKNOWN@");
    }
  currentInfoModule_->addPort(name, direction, type, groupComment,
                              SourceLocManager::registerNode(filename_,&node));
}

void AriElaborate::tln_from(AST & node)
{
  AST_list & nodes = node.getNodes();
  std::string source = allstrip(nodes[2]->getString());
  SourceLoc loc = SourceLocManager::registerNode(filename_, nodes[0]);
  currentInfoModule_->setSource(source, loc);
  inputFiles_.push_back(source);
}

void AriElaborate::xrf(AST & node)
{
  AST_list & nodes = node.getNodes();
  AST_list & componentports = nodes[3]->getNodes();
  for (AST_list::const_iterator componentport=componentports.begin();
       componentport!=componentports.end(); ++componentport)
    {
      AST_list & xrfs = (*componentport)->getNodes();
      SourceLoc loc = SourceLocManager::registerNode(filename_, *componentport);
      currentInfoModule_->
        addUserXrf(CaseAwareString(keepCase_, strip(nodes[1]->text())),
                   CaseAwareString(keepCase_, strip(xrfs[0]->getString())),
                   CaseAwareString(keepCase_, strip(xrfs[2]->text())), loc);
    }
}

void AriElaborate::xrfp(AST & node)
{
  AST_list & nodes = node.getNodes();
  AST_list & componentports = nodes[3]->getNodes();
  CaseAwareString xrfToName = CaseAwareString(keepCase_,
                                              strip(nodes[1]->text()));
  for (AST_list::const_iterator componentport=componentports.begin();
       componentport!=componentports.end(); ++componentport)
    {
      AST_list & xrfs = (*componentport)->getNodes();
      SourceLoc loc = SourceLocManager::registerNode(filename_, *componentport);
      currentInfoModule_->
        addUserXrf(xrfToName,
                   CaseAwareString(keepCase_, strip(xrfs[0]->getString())),
                   CaseAwareString(keepCase_, strip(xrfs[2]->text())), loc);
    }
  SignalPort * existingPort = currentInfoModule_->getSignalPort(xrfToName);
  if (!existingPort) // this allows multiple xrfp to the same port
    currentInfoModule_->addPort(xrfToName,
                                CaseAwareString(keepCase_, "auto"),
                                CaseAwareString(true, "@UNKNOWN@"),
                                CaseAwareString(),
                                SourceLocManager::registerNode(filename_,
                                                               &node));
}

void AriElaborate::library(AST & node)
{
  AST_list & nodes = node.getNodes();
  CaseAwareString libName = CaseAwareString(keepCase_, nodes[2]->getString());
  currentInfoModule_->setLibrary(libName);
}

void AriElaborate::generic(AST & node)
{
  AST_list & nodes = node.getNodes();
  CaseAwareString name = CaseAwareString(keepCase_, nodes[1]->getString());
  CaseAwareString typeAndValue = CaseAwareString(keepCase_, nodes[3]->text());

  auto pos = typeAndValue.find(CaseAwareString(keepCase_, ":="));
  if (pos != std::string::npos)
    {
      CaseAwareString type  = typeAndValue.substr(0, pos).allstrip();
      CaseAwareString value = typeAndValue.substr(pos+2).allstrip();
      currentInfoModule_->addGeneric(name, type, value,
        SourceLocManager::registerNode(filename_,&node));
    }
  else
    currentInfoModule_->addGeneric(name, typeAndValue, CaseAwareString(),
      SourceLocManager::registerNode(filename_,&node));
}

void AriElaborate::signal(AST & node)
{
  AST_list & nodes = node.getNodes();
  CaseAwareString name = CaseAwareString(keepCase_, nodes[1]->getString());
  CaseAwareString type;
  if (nodes.size() == 5)
    {
      type = CaseAwareString(keepCase_, nodes[3]->text());
      if (type.strip() == "auto")
        type = CaseAwareString(true, "@UNKNOWN@");
    }
  else
    {
      type = CaseAwareString(true, "@UNKNOWN@");
    }
  currentInfoModule_->addSignal(name, type,
                               SourceLocManager::registerNode(filename_,&node));
}

void AriElaborate::constant(AST & node)
{
  AST_list & nodes = node.getNodes();
  CaseAwareString name = CaseAwareString(keepCase_, nodes[1]->getString());
  CaseAwareString type = CaseAwareString(keepCase_, nodes[3]->text());
  CaseAwareString value = CaseAwareString(keepCase_, nodes[5]->text());
  currentInfoModule_->addConstant(name, type, value,
                               SourceLocManager::registerNode(filename_,&node));
}

void AriElaborate::configuration(AST & node)
{
  AST_list & nodes = node.getNodes();
  Module::ConfigurationInfo configInfo;
  configInfo.name = CaseAwareString(keepCase_, nodes[1]->getString());
  AST_list & subconfigs = nodes[3]->getNodes();
  for (AST_list::const_iterator subconfig=subconfigs.begin();
       subconfig!=subconfigs.end(); ++subconfig)
    {
      AST_list & subnodes = (*subconfig)->getNodes();
      SourceLoc loc = SourceLocManager::registerNode(filename_, *subconfig);
      if (subnodes[1]->getChar() == '/')
        configInfo.subconfigs[CaseAwareString(keepCase_,
                                              subnodes[0]->getString())] =
          Module::SubConfigInfo(CaseAwareString(keepCase_,
                                                subnodes[2]->getString()),
                                loc);
      else
        configInfo.subarchs[CaseAwareString(keepCase_,
                                            subnodes[0]->getString())] =
          Module::SubArchInfo(CaseAwareString(keepCase_,
                                              subnodes[2]->getString()), loc);
    }
  currentInfoModule_->addConfiguration(configInfo,
                                      SourceLocManager::registerNode(filename_,
                                                                     nodes[1]));
}

void AriElaborate::architecture(AST & node)
{
  AST_list & nodes = node.getNodes();
  CaseAwareString archName = CaseAwareString(keepCase_, nodes[2]->getString());
  currentInfoModule_->setArchitecture(archName);
}

void AriElaborate::statements(AST & node)
{
  AST_list & nodes = node.getNodes();
  currentInfoModule_->addStatements(CaseAwareString(keepCase_,nodes[1]->text()),
                                    SourceLocManager::registerNode(filename_,
                                                                   nodes[0]));
}

void AriElaborate::declarations(AST & node)
{
  AST_list & nodes = node.getNodes();
  currentInfoModule_->addDeclarations(CaseAwareString(keepCase_,
                                                      nodes[1]->text()),
                                      SourceLocManager::registerNode(filename_,
                                                                     nodes[0]));
}

void AriElaborate::declarationstop(AST & node)
{
  AST_list & nodes = node.getNodes();
  currentInfoModule_->addDeclarationsTop(CaseAwareString(keepCase_,
                                                         nodes[1]->text()),
                                      SourceLocManager::registerNode(filename_,
                                                                     nodes[0]));
}

void AriElaborate::remove_package(AST & node)
{
  AST_list & nodes = node.getNodes();
  currentInfoModule_->removePackage(CaseAwareString(keepCase_,
                                                    nodes[2]->getString()),
    normalizeNoWhiteString(CaseAwareString(keepCase_, nodes[4]->text())));
}

void AriElaborate::add_package(AST & node)
{
  AST_list & nodes = node.getNodes();
  SourceLoc loc = SourceLocManager::registerNode(filename_, &node);
  currentInfoModule_->addPackage(CaseAwareString(keepCase_,
                                                 nodes[2]->getString()),
    normalizeNoWhiteString(CaseAwareString(keepCase_, nodes[4]->text())), loc);
}

void AriElaborate::move_package(AST & node)
{
  AST_list & nodes = node.getNodes();
  SourceLoc loc = SourceLocManager::registerNode(filename_, &node);
  currentInfoModule_->movePackage(CaseAwareString(keepCase_,
                                                  nodes[2]->getString()),
    normalizeNoWhiteString(CaseAwareString(keepCase_, nodes[4]->text())), loc);
}

void AriElaborate::add_header(AST & node)
{
  AST_list & nodes = node.getNodes();
  currentInfoModule_->
    addPackage(CaseAwareString(true, "systemc"),
               CaseAwareString(true, allstrip(nodes[2]->getString())));
}

void AriElaborate::move_header(AST & node)
{
  AST_list & nodes = node.getNodes();
  currentInfoModule_->
    movePackage(CaseAwareString(true, "systemc"),
                CaseAwareString(true, allstrip(nodes[2]->getString())));
}

void AriElaborate::remove_header(AST & node)
{
  AST_list & nodes = node.getNodes();
  currentInfoModule_->
    removePackage(CaseAwareString(true, "systemc"),
                  CaseAwareString(true, allstrip(nodes[2]->getString())));
}

void AriElaborate::exec_script(AST & node)
{
  AST_list & nodes = node.getNodes();
  currentInfoModule_->execScript(strip(nodes[2]->getString()));
}

void AriElaborate::assign(AST & node)
{
  AST_list & nodes = node.getNodes();
  AST_list & componentports = nodes[3]->getNodes();
  for (AST_list::const_iterator componentport=componentports.begin();
       componentport!=componentports.end(); ++componentport)
    {
      AST_list & xrfs = (*componentport)->getNodes();
      SourceLoc loc = SourceLocManager::registerNode(filename_,
                                                     *componentport);
      currentInfoModule_->
        addUserAssign(CaseAwareString(keepCase_, strip(nodes[1]->text())),
                      CaseAwareString(keepCase_, strip(xrfs[0]->getString())),
                      CaseAwareString(keepCase_, strip(xrfs[2]->text())), loc);
    }
}

void AriElaborate::component(AST & node)
{
  AST_list & nodes = node.getNodes();
  CaseAwareString library = CaseAwareString(keepCase_, nodes[2]->getString());
  CaseAwareString package =
    normalizeNoWhiteString(CaseAwareString(keepCase_, nodes[4]->text()));
  SourceLoc loc = SourceLocManager::registerNode(filename_, &node);
  currentInfoModule_->addComponentPackage(library, package, loc);
}

void AriElaborate::rename_ports(AST & node)
{
  AST_list & nodes = node.getNodes();
  CaseAwareString instance = CaseAwareString(keepCase_,strip(nodes[1]->text()));
  CaseAwareString match = CaseAwareString(keepCase_, strip(nodes[2]->text()));
  CaseAwareString from = CaseAwareString(keepCase_, strip(nodes[4]->text()));
  CaseAwareString to = CaseAwareString(keepCase_, strip(nodes[6]->text()));
  SourceLoc loc = SourceLocManager::registerNode(filename_, nodes[1]);
  currentInfoModule_->addRenamePorts(instance, match, from, to, loc);
}

void AriElaborate::group_comment(AST & node)
{
  AST_list & nodes = node.getNodes();
  CaseAwareString port = CaseAwareString(keepCase_, strip(nodes[1]->text()));
  CaseAwareString comment = CaseAwareString(keepCase_, strip(nodes[3]->text()));
  currentInfoModule_->addGroupComment(port, comment + "\n");
}

void AriElaborate::port_comment(AST & node)
{
  AST_list & nodes = node.getNodes();
  CaseAwareString port = CaseAwareString(keepCase_, strip(nodes[1]->text()));
  CaseAwareString comment = CaseAwareString(keepCase_, strip(nodes[3]->text()));
  currentInfoModule_->addPortComment(port, comment + "\n");
}

void AriElaborate::keep_case(AST & node)
{
  currentInfoModule_->setKeepCase();
}

void AriElaborate::language(AST & node)
{
  AST_list & nodes = node.getNodes();
  std::string lang = strip(nodes[2]->text());
  if (lang == "systemc")
    currentInfoModule_->setLanguage(Module::LANGUAGE_SYSTEMC);
  else if (lang == "verilog")
    currentInfoModule_->setLanguage(Module::LANGUAGE_VERILOG);
  else
    throw AriException(EX_UNKNOWN_LANGUAGE, lang);
}

void AriElaborate::create(AST & node)
{
  AST_list & nodes = node.getNodes();
  CaseAwareString instance = CaseAwareString(keepCase_,
                                             strip(nodes[1]->getString()));
  SourceLoc loc = SourceLocManager::registerNode(filename_, nodes[1]);
  currentInfoModule_->addCreate(instance,
                                CaseAwareString(keepCase_,
                                                strip(nodes[2]->text())), loc);
}

void AriElaborate::post_exec_script(AST & node)
{
  AST_list & nodes = node.getNodes();
  currentInfoModule_->setPostExecScript(strip(nodes[2]->getString()));
}

void AriElaborate::rubycode(AST & node)
{
  AST_list & nodes = node.getNodes();
  rubycodes_.push_back(nodes[1]->getString());
}

void AriElaborate::rubypostcode(AST & node)
{
  AST_list & nodes = node.getNodes();
  rubypostcodes_.push_back(nodes[1]->getString());
}

void AriElaborate::pythoncode(AST & node)
{
  AST_list & nodes = node.getNodes();
  pythoncodes_.push_back(nodes[1]->getString());
}

void AriElaborate::pythonpostcode(AST & node)
{
  AST_list & nodes = node.getNodes();
  pythonpostcodes_.push_back(nodes[1]->getString());
}

void AriElaborate::sc_method(AST & node)
{
  AST_list & nodes = node.getNodes();
  ScMethod method(false);
  method.methodName = nodes[1]->getString();
  AST_list & sensitives = nodes[3]->getNodes();
  for (AST_list::const_iterator sensitive=sensitives.begin();
       sensitive!=sensitives.end(); ++sensitive)
    {
      method.sensitivity.push_back((*sensitive)->getString());
    }
  method.code = nodes[5]->getString();
  currentInfoModule_->addScMethod(method);
}

void AriElaborate::sc_thread(AST & node)
{
  AST_list & nodes = node.getNodes();
  ScMethod thread(true);
  thread.methodName = nodes[1]->getString();
  AST_list & sensitives = nodes[3]->getNodes();
  for (AST_list::const_iterator sensitive=sensitives.begin();
       sensitive!=sensitives.end(); ++sensitive)
    {
      thread.sensitivity.push_back((*sensitive)->getString());
    }
  thread.code = nodes[5]->getString();
  currentInfoModule_->addScMethod(thread);
}

void AriElaborate::entity_comment(AST & node)
{
  AST_list & nodes = node.getNodes();
  currentInfoModule_->
    addEntityComment(CaseAwareString(keepCase_, strip(nodes[2]->text())));
}

void AriElaborate::arch_comment(AST & node)
{
  AST_list & nodes = node.getNodes();
  currentInfoModule_->addArchComment(CaseAwareString(keepCase_,
                                                     strip(nodes[2]->text())));
}

void AriElaborate::inst_comment(AST & node)
{
  AST_list & nodes = node.getNodes();
  currentInfoModule_->
    addInstComment(CaseAwareString(keepCase_, strip(nodes[1]->text())),
                   CaseAwareString(keepCase_, strip(nodes[3]->text())));
}

void AriElaborate::config_in_arch(AST & node)
{
  currentInfoModule_->setConfigInArch(true);
}

void AriElaborate::fileheader(AST & node)
{
  AST_list & nodes = node.getNodes();
  std::string headername = allstrip(nodes[2]->getString());
  SourceLoc loc = SourceLocManager::registerNode(filename_, nodes[0]);
  FileHeader * fileHeader = new FileHeader(headername, loc);
  currentInfoModule_->setFileHeader(fileHeader);
}

void AriElaborate::searchMissingFrom()
{
  if (!hierarchy_->haveMissingFrom())
    return;

  VmaSearchInfo searchInfo;
  if (!searchInfo.runVma())
    return;
  inputFiles_ << hierarchy_->searchMissingFrom(searchInfo);
}

void AriElaborate::addIncludedFiles(std::set<std::string> const & files)
{
  for (auto file : files)
    inputFiles_ << file;
}

void AriElaborate::resolve()
{
  ScriptInterface::instance().makeGlobalVariable("module", hierarchy_);
  for (StringUtil::stringlist::const_iterator code=rubycodes_.begin();
       code!=rubycodes_.end(); ++code)
    {
#ifdef SCRIPT_RUBY
      ScriptInterface::instance().runRubyString(*code);
#else
      throw AriException(EX_NO_RUBY_SUPPORT, filename_);
#endif
    }
  for (StringUtil::stringlist::const_iterator code=pythoncodes_.begin();
       code!=pythoncodes_.end(); ++code)
    {
#ifdef SCRIPT_PYTHON
      ScriptInterface::instance().runPythonString(*code);
#else
      throw AriException(EX_NO_PYTHON_SUPPORT, filename_);
#endif
    }

  hierarchy_->resolve();
}

void AriElaborate::generate(const StringUtil::stringlist & argv)
{
  // scripting code needs access to group/port comments
  hierarchy_->applyGroupComments();
  for (StringUtil::stringlist::const_iterator code=rubypostcodes_.begin();
       code!=rubypostcodes_.end(); ++code)
    {
#ifdef SCRIPT_RUBY
      ScriptInterface::instance().runRubyString(*code);
#else
      throw AriException(EX_NO_RUBY_SUPPORT, filename_);
#endif
    }
  for (StringUtil::stringlist::const_iterator code=pythonpostcodes_.begin();
       code!=pythonpostcodes_.end(); ++code)
    {
#ifdef SCRIPT_PYTHON
      ScriptInterface::instance().runPythonString(*code);
#else
      throw AriException(EX_NO_PYTHON_SUPPORT, filename_);
#endif
    }

  hierarchy_->generate(argv, filename_, inputFiles_);
}

void AriElaborate::queryPackages() const
{
  hierarchy_->queryPackages();
}

void AriElaborate::print()
{
  if (hierarchy_)
    std::cout << *hierarchy_;
  else
    std::cout << "empty\n";
}

Module * AriElaborate::getModule(const CaseAwareString & name)
{
  ModuleMap::iterator module = modules_.find(name);
  if (module == modules_.end())
    {
      Module * newModule = new Module(name);
      modules_[name] = newModule;
      return newModule;
    }
  else
    return module->second;
}

CaseAwareString AriElaborate::normalizeNoWhiteString(const CaseAwareString & s)
{
  CaseAwareString result(s);
  std::string::size_type pos = 0;
  while ((pos = result.find(' ')) != std::string::npos)
    result.erase(pos, 1);
  return result;
}
