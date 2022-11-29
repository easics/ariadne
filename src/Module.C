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


#include "Module.h"
#include "AriException.h"
#include "VhdlParserWrapper.h"
#include "VerilogParserWrapper.h"
#include "SignalPort.h"
#include "ConstGeneric.h"
#include "ModuleInstance.h"
#include "PathFunctions.h"
#include "CHeaderParser.h"
#include "AriOptions.h"
#include "GeneratedBlock.h"
#include "ExecScript.h"
#include "NamingRules.h"

#include <fnmatch.h>
#include <sstream>

bool Module::regenerateEntities_ = false;

Module::Module(const CaseAwareString & entityName)
  : entityName_(entityName), parsedIt_(false), isGenerated_(false),
    architecture_(false, "rtl"), library_(false, "work"),
    isLibrarySpecifiedInAri_(false),
    haveComponentPackage_(false),
    keepCase_(false), sourceLanguage_(LANGUAGE_VHDL), haveExec_(false),
    configInArch_(false), fileHeader_(nullptr)
{
}

Module::~Module()
{
}

void Module::loadFromFile(const std::string & filename, SourceLoc loc)
{
  if (filename.find_first_of("\r\t\n ") != std::string::npos)
    throw AriException(EX_SPACES_IN_FILENAME, filename, loc);
  std::string expandedName = StringUtil::expandVars(filename);
  if (expandedName.empty())
    throw AriException(EX_FILE_NOT_FOUND, filename, loc);
  // Only look in include dirs when not absolute path
  std::string fileLocation;
  if (expandedName[0] == '/')
    {
      fileLocation = expandedName;
    }
  else
    {
      StringUtil::stringlist dirs;
      dirs.push_back(".");
      dirs.insert(dirs.end(), AriOptions::getInstance()->includeDirs.begin(),
                  AriOptions::getInstance()->includeDirs.end());
      for (auto dir=dirs.begin(); dir!=dirs.end(); ++dir)
        {
          if (PathFunctions::isReadable(*dir + "/" + expandedName))
            {
              fileLocation = *dir + "/" + expandedName;
              break;
            }
        }
    }
  if (fileLocation.empty())
    throw AriException(EX_FILE_NOT_FOUND, filename, loc);

  std::string extension = PathFunctions::extension(fileLocation);
  if (extension == "h")
    {
      sourceLanguage_ = LANGUAGE_SYSTEMC;
      CHeaderParser parser(this);
      parser.parseFile(fileLocation);
    }
  else if (extension == "v")
    {
      sourceLanguage_ = LANGUAGE_VERILOG;
      VerilogParserWrapper parser(this);
      parser.parseFile(fileLocation);
      keepCase_ = true;
    }
  else
    {
      VhdlParserWrapper parser(this);

      parser.parseFile(fileLocation);
    }
  if (!parsedIt_)
    throw AriException(EX_ENTITY_NOT_FOUND_IN_FILE, entityName_.str(), filename,
                       loc);

  if (haveExec_ || !regenerateEntities_)
    return;

  GeneratedBlock block;
  if (block.extract(expandedName))
    {
      // If the command to generate this file was ariadne (myself), and one of
      // the input files has changed -> rerun command
      //if (block.getCommand().substr(0, 8) == "ariadne ")
        {
          if (true || block.needToRegenerate())
            // 'true' to always rerun ariadne, to always go to the deepest level
            // changes introduced deep down below could ripple up to top.
            // But top is probably not directly depending on deepest entities
            {
              std::cout << "Regenerating " << filename << "\n";
              block.regenerate();
              std::cout << "entity " << entityName_
                << " regenerated\n";
            }
          else
            {
              std::cout << "entity " << entityName_ << " is up to date\n";
            }
        }
    }
}

void Module::parsedIt()
{
  parsedIt_ = true;
}

const CaseAwareString & Module::getEntityName() const
{
  return entityName_;
}

void Module::setEntityName(const CaseAwareString & name)
{
  entityName_ = name;
}

void Module::addSignalPort(SignalPort * sigPort)
{
  if (signalPorts_.find(sigPort->getName()) != signalPorts_.end())
    throw AriException(EX_ALREADY_HAVE_SIGPORT,
                       sigPort->getName().str(), entityName_.str(),
                       sigPort->loc());

  signalPorts_[sigPort->getName()] = sigPort;
}

void Module::addConstGeneric(ConstGeneric * constGeneric)
{
  if (constGenerics_.find(constGeneric->getName()) != constGenerics_.end())
    throw AriException(EX_ALREADY_HAVE_CONSTGENERIC,
                       constGeneric->getName().str(),
                       entityName_.str(),
                       constGeneric->loc());

  constGenerics_[constGeneric->getName()] = constGeneric;
}

void Module::setContext(const Context & context)
{
  context_ = context;
}

void Module::removePackage(const CaseAwareString & library,
                           const CaseAwareString & package)
{
  removeContext_.add(library, package, 0);
}

void Module::movePackage(const CaseAwareString & library,
                         const CaseAwareString & package,
                         SourceLoc loc)
{
  removeContext_.add(library, package, loc);
  rtlContext_.add(library, package, loc);
}

void Module::addPackage(const CaseAwareString & library,
                        const CaseAwareString & package,
                        SourceLoc loc)
{
  entityContext_.add(library, package, loc);
}

void Module::addComponentPackage(const CaseAwareString & library,
                                 const CaseAwareString & package,
                                 SourceLoc loc)
{
  rtlContext_.add(library, package, loc);
  haveComponentPackage_ = true;
}

bool Module::haveComponentPackage()
{
  return haveComponentPackage_;
}

void Module::addPort(const CaseAwareString & name,
                     const CaseAwareString & direction,
                     const CaseAwareString & type,
                     const CaseAwareString & groupComment,
                     SourceLoc loc)
{
  SignalPortList::iterator signalPort = signalPorts_.find(name);
  if (signalPort == signalPorts_.end())
    {
      SignalPort * port = new SignalPort(name, type, false, direction, -1, loc);
      port->forcePort();
      if (type != "@UNKNOWN@")
        port->forceType(type);
      port->forceDirection(direction);
      port->setGroupComment(groupComment);
      signalPorts_[name] = port;
    }
  else
    {
      throw AriException(EX_ALREADY_HAVE_SIGPORT,
                         name.str(),
                         entityName_.str(),
                         loc);
    }
}

void Module::addSignal(const CaseAwareString & name,
                       const CaseAwareString & type,
                       SourceLoc loc)
{
  SignalPortList::iterator signalPort = signalPorts_.find(name);
  if (signalPort == signalPorts_.end())
    {
      SignalPort * sig = new SignalPort(name, type, true,
                                        CaseAwareString(), -1, loc);
      sig->forceSignal();
      sig->forceType(type);
      signalPorts_[name] = sig;
    }
  else
    {
      throw AriException(EX_ALREADY_HAVE_SIGPORT,
                         name.str(),
                         entityName_.str(),
                         loc);
    }
}

void Module::addConstant(const CaseAwareString & name,
                         const CaseAwareString & type,
                         const CaseAwareString & value,
                         SourceLoc loc)
{
  ConstGenericList::iterator constGeneric = constGenerics_.find(name);
  if (constGeneric == constGenerics_.end())
    {
      ConstGeneric * cg = new ConstGeneric(name, type, true, value, loc);
      cg->forceConstant();
      cg->forceType(type);
      cg->forceValue(value);
      constGenerics_[name] = cg;
    }
  else
    {
      throw AriException(EX_ALREADY_HAVE_CONSTGENERIC,
                         name.str(),
                         entityName_.str(),
                         loc);
    }
}

void Module::addGeneric(const CaseAwareString & name,
                        const CaseAwareString & type,
                        const CaseAwareString & value,
                        SourceLoc loc)
{
  ConstGenericList::iterator constGeneric = constGenerics_.find(name);
  if (constGeneric == constGenerics_.end())
    {
      ConstGeneric * cg = new ConstGeneric(name, type, false, value, loc);
      cg->forceGeneric();
      cg->forceType(type);
      cg->forceValue(value);
      constGenerics_[name] = cg;
    }
  else
    {
      throw AriException(EX_ALREADY_HAVE_CONSTGENERIC,
                         name.str(),
                         entityName_.str(),
                         loc);
    }
}

void Module::addStatements(const CaseAwareString & statements, SourceLoc loc)
{
  assertGenerated("statements", loc);
  statements_ += statements;
}

void Module::addDeclarations(const CaseAwareString & declarations,
                             SourceLoc loc)
{
  assertGenerated("declarations", loc);
  declarations_ += declarations;
}

void Module::addDeclarationsTop(const CaseAwareString & declarations,
                                SourceLoc loc)
{
  assertGenerated("declarationstop", loc);
  declarationsTop_ += declarations;
}

void Module::addConfiguration(const ConfigurationInfo & configInfo,
                              SourceLoc loc)
{
  assertGenerated("configuration", loc);
  configurations_.push_back(configInfo);
}

void Module::setLibrary(const CaseAwareString & name)
{
  library_ = name;
  isLibrarySpecifiedInAri_ = true;
}

void Module::setArchitecture(const CaseAwareString & name)
{
  architecture_ = name;
}

void Module::execScript(const std::string & script)
{
  ::exec_script(script);
  haveExec_ = true;
}

void Module::setSource(const std::string & source, SourceLoc loc)
{
  assertNotGenerated("tln_from", loc);
  loadFromFile(source, loc);
}

void Module::addXrf(XrfBase * parent, XrfBase * child,
                    const CaseAwareString & childName)
{
  xrfs_[childName].push_back(Xrf(parent, child));
}

void Module::addAssign(const CaseAwareString & value, XrfBase * child,
                       const CaseAwareString & childName)
{
  assigns_[childName].push_back(Assign(value, child));
}

void Module::addUserXrf(const CaseAwareString & lhsName,
                        const CaseAwareString & instance,
                        const CaseAwareString & rhsName,
                        SourceLoc loc)
{
  userXrfs_[instance].push_back(UserXrf(lhsName, rhsName, loc));
}

void Module::removeUserXrf(const CaseAwareString & instance,
                           const CaseAwareString & rhsName,
                           SourceLoc loc)
{
  UserXrfList xrfs = userXrfs_[instance];
  for (UserXrfList::iterator xrf=xrfs.begin(); xrf!=xrfs.end();)
    {
      if (xrf->second == rhsName)
        xrf = xrfs.erase(xrf);
      else
        ++xrf;
    }
  userXrfs_[instance] = xrfs;
}

void Module::addUserAssign(const CaseAwareString & value,
                           const CaseAwareString & instance,
                           const CaseAwareString & rhsName,
                           SourceLoc loc)
{
  userAssigns_[instance].push_back(UserXrf(value, rhsName, loc));
}

void Module::addRenamePorts(const CaseAwareString & instanceName,
                            const CaseAwareString & match,
                            const CaseAwareString & from,
                            const CaseAwareString & to,
                            SourceLoc loc)
{
  portRenames_[instanceName].push_back(PortRename(match, from, to, loc));
}

void Module::addGroupComment(const CaseAwareString & port,
                             const CaseAwareString & groupComment)
{
  // Port can be a regular expression
  // The group comment is not applied yet, because the port list may not be
  // complete yet. The comments are applied with the applyGroupComments function
  groupComments_[port] = groupComment;
}

void Module::addPortComment(const CaseAwareString & port,
                            const CaseAwareString & portComment)
{
  // Port can be a regular expression
  // The group comment is not applied yet, because the port list may not be
  // complete yet. The comments are applied with the applyGroupComments function
  portComments_[port] = portComment;
}

void Module::addEntityComment(const CaseAwareString & comment)
{
  entityComment_ = comment;
}

void Module::addArchComment(const CaseAwareString & comment)
{
  archComment_ = comment;
}

void Module::addInstComment(const CaseAwareString & instanceName,
                            const CaseAwareString & comment)
{
  instComment_[instanceName] += comment + "\n";
}

CaseAwareString Module::getEntityComment() const
{
  return entityComment_;
}

CaseAwareString Module::getArchComment() const
{
  return archComment_;
}

CaseAwareString Module::getInstComment(const CaseAwareString & instanceName) const
{
  auto comment = instComment_.find(instanceName);
  if (comment == instComment_.end())
    return CaseAwareString();
  else
    return comment->second;
}

void Module::setConfigInArch(bool how)
{
  configInArch_ = how;
}

bool Module::isConfigInArch() const
{
  return configInArch_;
}

void Module::setFileHeader(FileHeader * header)
{
  fileHeader_ = header;
}

FileHeader * Module::getFileHeader() const
{
  return fileHeader_;
}

void Module::applyGroupComments()
{
  for (GroupCommentList::iterator groupComment = groupComments_.begin();
       groupComment != groupComments_.end(); ++groupComment)
    {
      for (SignalPortList::iterator signalPort = signalPorts_.begin();
           signalPort != signalPorts_.end(); ++signalPort)
        {
          if (signalPort->second->isPort())
            if (fnmatch(groupComment->first.c_str(),
                        signalPort->first.c_str(),
                        FNM_CASEFOLD) == 0)
              signalPort->second->setGroupComment(groupComment->second);
        }
    }
  for (GroupCommentList::iterator portComment = portComments_.begin();
       portComment != portComments_.end(); ++portComment)
    {
      for (SignalPortList::iterator signalPort = signalPorts_.begin();
           signalPort != signalPorts_.end(); ++signalPort)
        {
          if (signalPort->second->isPort())
            if (fnmatch(portComment->first.c_str(),
                        signalPort->first.c_str(),
                        FNM_CASEFOLD) == 0)
              signalPort->second->setPortComment(portComment->second);
        }
    }
}

Context Module::getContext() const
{
  return context_;
}

Context Module::getRemoveContext() const
{
  return removeContext_;
}

Context Module::getRtlContext() const
{
  return rtlContext_;
}

Context Module::getEntityContext() const
{
  return entityContext_;
}

bool Module::isGenerated() const
{
  return isGenerated_;
}

void Module::setGenerated()
{
  isGenerated_ = true;
}

bool Module::haveSource() const
{
  return parsedIt_;
}

Module::XrfList
Module::getXrfsForInstance(const CaseAwareString & instanceName,
                           bool portsNotGenerics) const
{
  XrfMap::const_iterator resultBig = xrfs_.find(instanceName);
  XrfList result;
  if (resultBig == xrfs_.end())
    return result;
  for (XrfList::const_iterator xrf=resultBig->second.begin();
       xrf!=resultBig->second.end(); ++xrf)
    {
      if ((xrf->getParent()->isSignalPort()) == portsNotGenerics)
        result.push_back(*xrf);
    }
  return result;
}

Module::AssignList
Module::getAssignsForInstance(const CaseAwareString & instanceName,
                              bool portsNotGenerics) const
{
  AssignMap::const_iterator resultBig = assigns_.find(instanceName);
  AssignList result;
  if (resultBig == assigns_.end())
    return result;

  for (AssignList::const_iterator assign=resultBig->second.begin();
       assign!=resultBig->second.end(); ++assign)
    {
      if ((assign->getChild()->isSignalPort()) == portsNotGenerics)
        result.push_back(*assign);
    }
  return result;
}

const Module::PortRenameMap & Module::getPortRenames() const
{
  return portRenames_;
}

ModuleInstance * Module::makeInstance(const CaseAwareString & instanceName,
                                      SourceLoc loc)
{
  return new ModuleInstance(instanceName, this, loc);
}

Module::PortList Module::getPorts() const
{
  PortList result;
  for (SignalPortList::const_iterator signalPort = signalPorts_.begin();
       signalPort != signalPorts_.end(); ++signalPort)
    {
      if (signalPort->second->isPort())
        result.push_back(signalPort->second);
    }
  return result;
}

Module::PortList Module::getSignals() const
{
  PortList result;
  for (SignalPortList::const_iterator signalPort = signalPorts_.begin();
       signalPort != signalPorts_.end(); ++signalPort)
    {
      if (!signalPort->second->isPort())
        result.push_back(signalPort->second);
    }
  return result;
}

Module::ConstList Module::getConstants() const
{
  ConstList result;
  for (ConstGenericList::const_iterator constGeneric=constGenerics_.begin();
       constGeneric!=constGenerics_.end(); ++constGeneric)
    {
      if (constGeneric->second->isConstant())
        result.push_back(constGeneric->second);
    }
  return result;
}

Module::ConstList Module::getGenerics() const
{
  ConstList result;
  for (ConstGenericList::const_iterator constGeneric=constGenerics_.begin();
       constGeneric!=constGenerics_.end(); ++constGeneric)
    {
      if (!constGeneric->second->isConstant())
        result.push_back(constGeneric->second);
    }
  return result;
}

SignalPort * Module::getSignalPort(const CaseAwareString & name,
                                   NamingRules * namingRules) const
{
  CaseAwareString basename = name.substr(0, name.find_first_of(".(")).strip();
  for (SignalPortList::const_iterator sigPort=signalPorts_.begin();
       sigPort!=signalPorts_.end(); ++sigPort)
    {
      if (namingRules == nullptr)
        {
          if (sigPort->first == basename)
            return sigPort->second;
        }
      else
        {
          if (namingRules->getPortBaseName(sigPort->first,
                                           sigPort->second->getDirection()) ==
              basename)
            return sigPort->second;
        }
    }
  return 0;
}

ConstGeneric * Module::getConstGeneric(const CaseAwareString & name) const
{
  ConstGenericList::const_iterator constGeneric =constGenerics_.find(name);
  if (constGeneric != constGenerics_.end())
    return constGeneric->second;
  else
    return 0;
}

CaseAwareString Module::getDeclarations() const
{
  return declarations_;
}

CaseAwareString Module::getDeclarationsTop() const
{
  return declarationsTop_;
}

CaseAwareString Module::getStatements() const
{
  return statements_;
}

bool Module::haveUserXrf(const CaseAwareString & instanceName,
                         const CaseAwareString & portName) const
{
  UserXrfMap::const_iterator instanceXrfs = userXrfs_.find(instanceName);
  if (instanceXrfs!=userXrfs_.end())
    {
      for (UserXrfList::const_iterator userXrf=instanceXrfs->second.begin();
           userXrf!=instanceXrfs->second.end(); ++userXrf)
        {
          CaseAwareString basename =
            userXrf->second.substr(0, userXrf->second.find_first_of(".(")).
            strip();
          if (basename == portName)
            return true;
        }
    }
  UserXrfMap::const_iterator instanceAssigns = userAssigns_.find(instanceName);
  if (instanceAssigns!=userAssigns_.end())
    {
      for (UserXrfList::const_iterator
           userAssign=instanceAssigns->second.begin();
           userAssign!=instanceAssigns->second.end(); ++userAssign)
        {
          CaseAwareString basename =
            userAssign->second.substr(0,userAssign->second.find_first_of(".(")).
            strip();
          if (basename == portName)
            return true;
        }
    }
  return false;
}

Module::UserXrf Module::getUserXrf(const CaseAwareString & instanceName,
                                    const CaseAwareString & portName) const
{
  UserXrfMap::const_iterator instanceXrfs = userXrfs_.find(instanceName);
  if (instanceXrfs!=userXrfs_.end())
    {
      for (UserXrfList::const_iterator userXrf=instanceXrfs->second.begin();
           userXrf!=instanceXrfs->second.end(); ++userXrf)
        {
          CaseAwareString basename =
            userXrf->second.substr(0, userXrf->second.find_first_of(".(")).
            strip();
          if (basename == portName)
            return *userXrf;
        }
    }
  UserXrfMap::const_iterator instanceAssigns = userAssigns_.find(instanceName);
  if (instanceAssigns!=userAssigns_.end())
    {
      for (UserXrfList::const_iterator
           userAssign=instanceAssigns->second.begin();
           userAssign!=instanceAssigns->second.end(); ++userAssign)
        {
          CaseAwareString basename =
            userAssign->second.substr(0,userAssign->second.find_first_of(".(")).
            strip();
          if (basename == portName)
            return *userAssign;
        }
    }
  throw std::runtime_error("Don't have a xrf for " + instanceName.str() + "/" +
                           portName.str());
}

bool Module::haveUserXrf(const CaseAwareString & sigPortName) const
{
  for (UserXrfMap::const_iterator instanceXrfs=userXrfs_.begin();
       instanceXrfs!=userXrfs_.end(); ++instanceXrfs)
    {
      for (UserXrfList::const_iterator userXrf=instanceXrfs->second.begin();
           userXrf!=instanceXrfs->second.end(); ++userXrf)
        {
          CaseAwareString basename =
            userXrf->first.substr(0,userXrf->first.find_first_of(".(")).strip();
          if (basename == sigPortName)
            return true;
        }
    }
  return false;
}

Module::UserXrfList
Module::getUserXrfsForInstance(const CaseAwareString & instanceName) const
{
  UserXrfMap::const_iterator result = userXrfs_.find(instanceName);
  if (result == userXrfs_.end())
    return UserXrfList();
  else
    return result->second;
}

Module::UserXrfList
Module::getUserAssignsForInstance(const CaseAwareString & instanceName) const
{
  UserXrfMap::const_iterator result = userAssigns_.find(instanceName);
  if (result == userAssigns_.end())
    return UserXrfList();
  else
    return result->second;
}

Module::UserXrfMap Module::getUserXrfs() const
{
  return userXrfs_;
}

Module::UserXrfMap Module::getUserAssigns() const
{
  return userAssigns_;
}

CaseAwareString Module::getLibrary() const
{
  return library_;
}

bool Module::isLibrarySpecifiedInAri() const
{
  return isLibrarySpecifiedInAri_;
}

CaseAwareString Module::getArchitecture() const
{
  return architecture_;
}

Module::ConfigurationList Module::getConfigurations() const
{
  return configurations_;
}

void Module::renameSignalPortTypes(const CaseAwareString & oldName,
                                   const CaseAwareString & newName)
{
  for (SignalPortList::const_iterator signalPort = signalPorts_.begin();
       signalPort != signalPorts_.end(); ++signalPort)
    {
      signalPort->second->renameType(oldName, newName);
    }
}

Module::Language Module::getLanguage() const
{
  return sourceLanguage_;
}

void Module::setLanguage(Language language)
{
  sourceLanguage_ = language;
}

void Module::assertGenerated(const std::string & function,
                             SourceLoc loc) const
{
  if (!isGenerated_)
    throw AriException(EX_NOT_GENERATED, entityName_.str(), function, loc);
}

void Module::assertNotGenerated(const std::string & function,
                                SourceLoc loc) const
{
  if (isGenerated_)
    throw AriException(EX_GENERATED, entityName_.str(), function, loc);
}

void Module::addCreate(const CaseAwareString & instance,
                       const CaseAwareString & createCode,
                       SourceLoc loc)
{
  CreateBlock block;
  block.code = createCode;
  block.loc = loc;
  creates_[instance] = block;
}

const Module::CreateList & Module::getCreateBlocks() const
{
  return creates_;
}

void Module::setPostExecScript(const std::string & script)
{
  postExecScripts_.push_back(script);
}

std::list<std::string> Module::getPostExecScripts() const
{
  return postExecScripts_;
}

std::string Module::getCreateForInstance(const CaseAwareString & instance,
                                         const CaseAwareString & type) const
{
  CreateList::const_iterator needle = creates_.find(instance);
  if (needle == creates_.end())
    {
      return "  " + instance.str() + " = new " + type.str()+ "(\"" +
        instance.str() + "\");\n";
    }
  else
    {
      return needle->second.code.str();
    }
}

void Module::addScMethod(const ScMethod & method)
{
  scMethods_.push_back(method);
}

const ScMethodArray & Module::getScMethods() const
{
  return scMethods_;
}

CaseAwareString Module::getUniqueSignalName(const CaseAwareString & base) const
{
  // first try without suffix
  if (!getSignalPort(base))
    return base;

  unsigned int suffix = 0;
  while (true)
    {
      CaseAwareString name = base;
      name += "_";
      name += std::to_string(suffix);
      bool alreadyExists = false;
      for (auto sigPort=signalPorts_.begin(); sigPort!=signalPorts_.end();
           ++sigPort)
        {
          if (sigPort->first == name)
            {
              alreadyExists = true;
              break;
            }
        }
      ++suffix;
      if (alreadyExists)
        continue;
      return name;
    }
}

void Module::changeUserXrf(const CaseAwareString & originalName,
                           const CaseAwareString & newName)
{
  for (auto instanceName=userXrfs_.begin(), e=userXrfs_.end(); instanceName!=e;
       ++instanceName)
    {
      for (auto xrf=instanceName->second.begin(),
           e=instanceName->second.end(); xrf!=e; ++xrf)
        {
          if (xrf->first == originalName)
            xrf->first = newName;
        }
    }
}

