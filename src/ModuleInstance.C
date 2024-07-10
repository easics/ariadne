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


#include "ModuleInstance.h"
#include "Module.h"
#include "SignalPort.h"
#include "ConstGeneric.h"
#include "StringUtil.h"
#include "SmartFile.h"
#include "AriOptions.h"
#include "NamingRules.h"
#include "ExecScript.h"
#include "AriadneVersionString.h"
#include "VectorAppend.h"
#include "AriException.h"
#include "FileHeader.h"
#include "SourceLocManager.h"
#include <set>
#include <algorithm>
#include <iterator>
#include <sstream>
#include <cstring>
#include <regex>

ModuleInstance::ModuleInstance(const CaseAwareString & instanceName,
                               Module * type, SourceLoc loc)
  : instanceName_(instanceName), type_(type),
    namingRules_(NamingRules::getInstance()),
    sourceLoc_(loc)
{
}

ModuleInstance::~ModuleInstance()
{
}

void ModuleInstance::addSubInstance(ModuleInstance * subInstance)
{
  type_->setGenerated();
  subInstances_.push_back(subInstance);
}

void ModuleInstance::print(std::ostream & str, unsigned int indent) const
{
  str << std::string(indent, ' ') << instanceName_ << " : "
      << type_->getEntityName() << "\n";
  for (ModuleInstanceList::const_iterator instance=subInstances_.begin();
       instance!=subInstances_.end(); ++instance)
    {
      (*instance)->print(str, indent + 2);
    }
}

bool ModuleInstance::haveMissingFrom() const
{
  bool result = false;
  for (auto subInstance : subInstances_)
    {
      result = result || subInstance->haveMissingFrom();
      if (result)
        break;
    }
  return result || (!type_->isGenerated() && !type_->haveSource());
}

StringUtil::stringlist
ModuleInstance::searchMissingFrom(const VmaSearchInfo & searchInfo)
{
  StringUtil::stringlist result;
  for (auto subInstance : subInstances_)
    result << subInstance->searchMissingFrom(searchInfo);

  if (type_->isGenerated() || type_->haveSource())
    return result;

  CaseAwareString libraryName = type_->getLibrary();
  if (!type_->isLibrarySpecifiedInAri())
    libraryName = CaseAwareString();
  std::cout << "Autosearch " << type_->getEntityName() << "\n";
  auto sources = searchInfo.getEntityFile(libraryName.str(),
                                          type_->getEntityName().str());
  if (sources.size() == 1)
    {
      std::cout << "Found it in " << sources[0].first << " : " <<
        sources[0].second << "\n";
      type_->setSource(sources[0].second, sourceLoc_);
      type_->setLibrary(CaseAwareString(false, sources[0].first));
      result << sources[0].second;
    }
  else if (sources.size() > 1)
    {
      std::cerr << "Found multiple possibilities :\n";
      for (auto source : sources)
        {
          std::cerr << source.first << " : " << source.second << "\n";
        }
    }
  else
    {
      std::cerr << "Nothing found";
      if (type_->isLibrarySpecifiedInAri())
        std::cerr << " in library " << type_->getLibrary() << "\n";
      else
        std::cerr << " in any library searched by vma\n";
    }
  return result;
}

void ModuleInstance::verify()
{
  if (!type_->isGenerated() && !type_->haveSource())
    {
      throw AriException(EX_MISSING_TLN_FROM, type_->getEntityName().str(),
                         sourceLoc_);
    }
  // Check if all user xrfs have a valid instance name.
  // Can't do it at parse for some reason I don't remember
  Module::UserXrfMap xrfs = type_->getUserXrfs();
  for (Module::UserXrfMap::const_iterator subname=xrfs.begin();
       subname!=xrfs.end(); ++subname)
    {
      ModuleInstance * needle = nullptr;
      for (ModuleInstanceList::const_iterator subInstance=subInstances_.begin();
           subInstance!=subInstances_.end(); ++subInstance)
        {
          if ((*subInstance)->instanceName_ == subname->first)
            needle = *subInstance;
        }
      if (!needle)
        {
          SourceLoc loc = subname->second.front().loc;
          throw AriException(EX_NO_SUCH_INSTANCE, type_->getEntityName().str(),
                             subname->first.str(), loc);
        }
      // Check if all user Xrfs have a valid port/generic name
      auto ports = needle->type_->getPorts();
      auto generics = needle->type_->getGenerics();
      std::set<CaseAwareString> portGenericSet;
      for (auto port : ports)
        portGenericSet.insert(port->getName());
      for (auto generic : generics)
        portGenericSet.insert(generic->getName());

      for (auto xrfRhs : subname->second)
        {
          CaseAwareString basicPortName =
            xrfRhs.second.substr(0, xrfRhs.second.find_first_of("(.")).strip();
          if (portGenericSet.find(basicPortName) == portGenericSet.end())
            {
              throw AriException(EX_NO_SUCH_PORT,
                                 needle->type_->getEntityName().str(),
                                 xrfRhs.second.str(),
                                 xrfRhs.loc);
            }
        }
    }
  // Check if all user assigns have a valid instance name.
  Module::UserXrfMap assigns = type_->getUserAssigns();
  for (Module::UserXrfMap::const_iterator subname=assigns.begin();
       subname!=assigns.end(); ++subname)
    {
      bool haveIt = false;
      for (ModuleInstanceList::const_iterator subInstance=subInstances_.begin();
           subInstance!=subInstances_.end(); ++subInstance)
        {
          if ((*subInstance)->instanceName_ == subname->first)
            haveIt = true;
        }
      if (!haveIt)
        {
          SourceLoc loc = subname->second.front().loc;
          throw AriException(EX_NO_SUCH_INSTANCE, type_->getEntityName().str(),
                             subname->first.str(), loc);
        }
    }
  // Check if all user configurations have a valid instance name.
  Module::ConfigurationList configs = type_->getConfigurations();
  for (Module::ConfigurationList::const_iterator subnames=configs.begin();
       subnames!=configs.end(); ++subnames)
    {
      bool haveIt;
      for (auto subname=subnames->subconfigs.begin();
           subname!=subnames->subconfigs.end(); ++subname)
        {
          haveIt = false;
          for (ModuleInstanceList::const_iterator
               subInstance=subInstances_.begin();
               subInstance!=subInstances_.end(); ++subInstance)
            {
              if ((*subInstance)->instanceName_ == subname->first)
                haveIt = true;
            }
          if (!haveIt)
            {
              SourceLoc loc = subname->second.loc;
              throw AriException(EX_NO_SUCH_INSTANCE,
                                 type_->getEntityName().str(),
                                 subname->first.str(), loc);
            }
        }
      for (auto subname=subnames->subarchs.begin();
           subname!=subnames->subarchs.end(); ++subname)
        {
          haveIt = false;
          for (ModuleInstanceList::const_iterator
               subInstance=subInstances_.begin();
               subInstance!=subInstances_.end(); ++subInstance)
            {
              if ((*subInstance)->instanceName_ == subname->first)
                haveIt = true;
            }
          if (!haveIt)
            {
              SourceLoc loc = subname->second.loc;
              throw AriException(EX_NO_SUCH_INSTANCE,
                                 type_->getEntityName().str(),
                                 subname->first.str(), loc);
            }
        }
    }
  // Check if all port renames have a valid instance name
  Module::PortRenameMap portRenames = type_->getPortRenames();
  for (Module::PortRenameMap::const_iterator subname=portRenames.begin();
       subname!=portRenames.end(); ++subname)
    {
      bool haveIt = false;
      for (ModuleInstanceList::const_iterator subInstance=subInstances_.begin();
           subInstance!=subInstances_.end(); ++subInstance)
        {
          if ((*subInstance)->instanceName_ == subname->first)
            haveIt = true;
        }
      if (!haveIt)
        {
          SourceLoc loc = subname->second.front().loc;
          throw AriException(EX_NO_SUCH_INSTANCE, type_->getEntityName().str(),
                             subname->first.str(), loc);
        }
    }
  // Check if all create blocks have a valid instance name
  const Module::CreateList & creates = type_->getCreateBlocks();
  for (Module::CreateList::const_iterator block=creates.begin();
       block!=creates.end(); ++block)
    {
      bool haveIt = false;
      for (ModuleInstanceList::const_iterator subInstance=subInstances_.begin();
           subInstance!=subInstances_.end(); ++subInstance)
        {
          if ((*subInstance)->instanceName_ == block->first)
            haveIt = true;
        }
      if (!haveIt)
        {
          SourceLoc loc = block->second.loc;
          throw AriException(EX_NO_SUCH_INSTANCE, type_->getEntityName().str(),
                             block->first.str(), loc);
        }
    }
}

void ModuleInstance::resolve()
{
  verify();
  // Need to do this depth-first
  for (ModuleInstanceList::iterator instance=subInstances_.begin();
       instance!=subInstances_.end(); ++instance)
    {
      (*instance)->resolve();
    }

  const CaseAwareString outString(keepCase(), "out");
  const CaseAwareString inString(keepCase(), "in");
  const CaseAwareString inoutString(keepCase(), "inout");

  // Determine direction of 'auto' ports
  PortList portList;
  portList = type_->getPorts();
  for (auto port=portList.begin(); port!=portList.end(); ++port)
    {
      // Check what is connected to the port and derive direction from that
      unsigned int nrIns = 0;
      unsigned int nrOuts = 0;
      unsigned int nrInouts = 0;

      // check explicitly xrf'd ports
      // They are normally connected to a signal, but because the port
      // was explicitly created, the port is connect to the signal.
      // The direction of the port should match the direction in the
      // child
      Module::UserXrfMap childXrfs = type_->getUserXrfs();
      for (auto xrf=childXrfs.begin(); xrf!=childXrfs.end(); ++xrf)
        {
          for (auto childXrf=xrf->second.begin(); childXrf!=xrf->second.end();
               ++childXrf)
            {
              CaseAwareString basicPortName = childXrf->first;
              basicPortName =
                basicPortName.substr(0, basicPortName.find_first_of("(."));
              if (basicPortName == (*port)->getBasename())
                {
                  // xrf maps to the port we investigating
                  SignalPort * childPort =
                   getSubInstance(xrf->first)->type_->
                                  getSignalPort(childXrf->second);
                  if (childPort)
                    {
                      CaseAwareString direction = childPort->getDirection();
                      if (direction == inString)
                        ++nrIns;
                      else if (direction == outString)
                        ++nrOuts;
                      else if (direction == inoutString)
                        ++nrInouts;
                    }
                  else
                    {
                      // non existing child port ???
                    }
                }
            }
        }
      unsigned int portOrderInput = 0;
      std::string diagnosticSources;
      for (auto instance : subInstances_)
        {
          PortList childPortList = instance->type_->getPorts();
          for (auto childPort : childPortList)
            {
              CaseAwareString portName =
                namingRules_->getPortBaseName(childPort);
              if (type_->haveUserXrf(instance->getInstanceName(),
                                     childPort->getName()))
                {
                  auto userXrf = type_->getUserXrf(instance->getInstanceName(),
                                                   childPort->getName());
                  if (userXrf.second == (*port)->getName())
                    {
                      diagnosticSources += instance->getInstanceName().str() +
                        " : " + childPort->getDirection().str() + "\n";
                    }
                  // already checked it
                  continue;
                }
              applyPortRename(instance->instanceName_, portName,
                              childPort->getDirection());
              if (portName ==
                  namingRules_->getPortBaseName((*port)->getBasename(),
                                                (*port)->getDirection()))
                {
                  CaseAwareString direction = childPort->getDirection();
                  if (direction == inString)
                    {
                      if (!portOrderInput)
                        portOrderInput = childPort->getPortOrder();
                      ++nrIns;
                      diagnosticSources += instance->getInstanceName().str() +
                        " : " + inString.str() + "\n";
                    }
                  else if (direction == "out")
                    {
                      ++nrOuts;
                      diagnosticSources += instance->getInstanceName().str() +
                        " : out\n";
                    }
                  else if (direction == "inout")
                    {
                      ++nrInouts;
                      diagnosticSources += instance->getInstanceName().str() +
                        " : inout\n";
                    }
                }
            }
        }

      if ((*port)->getDirection() == "auto")
        {
          if (nrInouts)
            (*port)->forceDirection(inoutString);
          else if (nrOuts == 1)
            (*port)->forceDirection(outString);
          else if (nrOuts == 0 && nrIns)
            (*port)->forceDirection(inString);
          else
            throw AriException(EX_AUTO_PORT_DIRECTION,(*port)->getName().str(),
                               diagnosticSources, (*port)->loc());
        }

      if (nrOuts == 1 && nrIns)
        {
          // Would create intermediate signal but an output with the same name
          // already exists -> create intermediate signal, assign to output port
          // and reconnect all others to signal
          CaseAwareString portName = namingRules_->getPortBaseName(*port);
          CaseAwareString signalName =
            namingRules_->getInternalSignalName(portName + "_i");
          signalName = type_->getUniqueSignalName(signalName);
          SignalPort * sig =
            new SignalPort(signalName,
                           (*port)->getType().strip(), true, CaseAwareString(),
                           -1, sourceLoc_);
          sig->forceType(sig->getType());
          sig->setRelatedPort(*port);
          type_->addSignalPort(sig);
          (*port)->overridePortOrder(portOrderInput);
          // change all user xrf that refer to the port
          type_->changeUserXrf(portName, signalName);
          // make user xrf for port that would get auto connected
          NameAndPortList connectedPorts;
          for (ModuleInstanceList::const_iterator
               instance=subInstances_.begin();
               instance!=subInstances_.end(); ++instance)
            {
              PortList childPortList = (*instance)->type_->getPorts();
              for (PortList::const_iterator childPort=childPortList.begin();
                   childPort!=childPortList.end(); ++childPort)
                {
                  if (type_->haveUserXrf((*instance)->getInstanceName(),
                                     namingRules_->getPortBaseName(*childPort)))
                    // no auto connect
                    continue;
                  CaseAwareString portName =
                    namingRules_->getPortBaseName(*childPort);
                  applyPortRename((*instance)->instanceName_, portName,
                                  (*childPort)->getDirection());
                  if (portName ==
                      namingRules_->getPortBaseName((*port)->getBasename(),
                                                    (*port)->getDirection()))
                    {
                      type_->addUserXrf(sig->getName(),
                                        (*instance)->getInstanceName(),
                                        (*childPort)->getName(), 0);
                      connectedPorts.
                        push_back(std::make_pair((*childPort)->getName(),
                                                 *childPort));
                    }
                }
            }
          // Inherit comments
          if ((*port)->getGroupComment().empty())
            (*port)->setGroupComment(findGroupComment(connectedPorts));
          if ((*port)->getPortComment().empty())
            (*port)->setPortComment(findPortComment(connectedPorts));
          // Assign port from signal
          if (type_->getLanguage() == Module::LANGUAGE_VHDL)
            type_->addStatements(CaseAwareString(keepCase(), "  ") +
                                 (*port)->getName() + " <= " +
                                 sig->getName() + ";\n", 0);
          else if (type_->getLanguage() == Module::LANGUAGE_VERILOG)
            type_->addStatements(CaseAwareString(keepCase(),"  assign ")+
                                 (*port)->getName() + " = " +
                                 sig->getName() + ";\n", 0);
          continue;
        }
    }

  // Collect all the ports from the subinstances and group them by name
  // Per port name, a list of child instance name and port pointer
  typedef std::map<CaseAwareString, NameAndPortList> PortGroups;
  PortGroups portGroups;
  UserAssignsMap userAssignsMap;
  for (ModuleInstanceList::const_iterator instance=subInstances_.begin();
       instance!=subInstances_.end(); ++instance)
    {
      Module::UserXrfList userAssigns =
        type_->getUserAssignsForInstance((*instance)->instanceName_);
      for (Module::UserXrfList::const_iterator userAssign=userAssigns.begin();
           userAssign!=userAssigns.end(); ++userAssign)
        {
          userAssignsMap[(*instance)->instanceName_][userAssign->second]
            = userAssign->first;
        }

      portList = (*instance)->type_->getPorts();
      for (PortList::const_iterator port=portList.begin();
           port!=portList.end(); ++port)
        {
          CaseAwareString portName = namingRules_->getPortBaseName(*port);
          applyPortRename((*instance)->instanceName_, portName,
                          (*port)->getDirection());
          portGroups[portName].
            push_back(std::make_pair((*instance)->instanceName_, *port));
        }
    }

  // Then create new signals/ports where needed and add xrfs
  for (PortGroups::const_iterator portGroup=portGroups.begin();
       portGroup!=portGroups.end(); ++portGroup)
    {
      NameAndPortList inputPorts;
      NameAndPortList outputPorts;
      NameAndPortList inoutPorts;
      unsigned int nrIns = 0;
      unsigned int nrOuts = 0;
      unsigned int nrInouts = 0;
      // Count number of input and output ports
      bool newNoPort = false;
      for (NameAndPortList::const_iterator port=portGroup->second.begin();
           port!=portGroup->second.end(); ++port)
        {
          // Exclude explicitly xrf'd ports
          if (type_->haveUserXrf(port->first, port->second->getName()))
            continue;
          if (type_->haveUserXrf(portGroup->first))
            {
              newNoPort = true;
            }

          CaseAwareString direction = port->second->getDirection();
          if (direction == outString)
            {
              outputPorts.push_back(*port);
              ++nrOuts;
            }
          else if (direction == inString)
            {
              inputPorts.push_back(*port);
              ++nrIns;
            }
          else if (direction == inoutString)
            {
              inoutPorts.push_back(*port);
              ++nrInouts;
            }
          else
            {
              std::cerr << "WARNING : Unsupported port direction " << direction
                << "\n";
            }
        }

      // First find a port in the portGroup that has no xrf's.
      // It will be used to determine the type of the new signal/port
      // If there are several options, prefer the one which has a constrained
      // type (rather than e.g. an unconstrained unsigned)
      CaseAwareString type = CaseAwareString(true, "@INTERNAL_ARIADNE_ERROR@");
      for (NameAndPortList::const_iterator port=portGroup->second.begin();
           port!=portGroup->second.end(); ++port)
        {
          if (type_->haveUserXrf(port->first, portGroup->first))
            continue;
          CaseAwareString newType =
            renameGenericInType(port->first, port->second->getType());
          if (type.find('(') == std::string::npos &&
              newType.find('(') != std::string::npos)
            {
              type = newType;
              break;
            }
          if (type.find(CaseAwareString(false, " range ")) == std::string::npos &&
              newType.find(CaseAwareString(false, " range ")) != std::string::npos)
            {
              type = newType;
              break;
            }
          if (type == "@INTERNAL_ARIADNE_ERROR@")
            type = newType;
        }

      // Don't touch a group if this module already has a signal/port of the
      // same name (which must have been explicitly set in the dsc file)
      SignalPort * sigPort = type_->getSignalPort(portGroup->first,
                                                  namingRules_);
      if (sigPort)
        {
          for (NameAndPortList::const_iterator port=portGroup->second.begin();
               port!=portGroup->second.end(); ++port)
            {
              // And if the user xrf'd this signal, don't even connect it.  It
              // will be connected by the user xrf.
              if (type_->haveUserXrf(port->first, port->second->getName()))
                continue;
              type_->addXrf(sigPort, port->second, port->first);
            }
          // User is allowed to leave the type unknown -> set it here
          if (sigPort->getType() == "@UNKNOWN@" &&
              type != "@INTERNAL_ARIADNE_ERROR@")
            sigPort->setType(type);
          continue;
        }

      // case 1 : more than 1 output
      //       -> error
      if (nrOuts > 1)
        {
          CaseAwareString instances;
          for (NameAndPortList::const_iterator port=outputPorts.begin();
               port!=outputPorts.end(); ++port)
            {
              instances += port->first + "\n";
            }
          throw AriException(EX_MULTIPLE_OUTPUTS, type_->getEntityName().str(),
                             portGroup->first.str(), instances.str());
        }

      // case 2 : all inputs
      //       -> create an input port and connect all
      else if (nrOuts == 0 && nrIns != 0 && nrInouts == 0)
        {
          SignalPort * port = inputPorts.front().second;
          CaseAwareString portBaseName =
            namingRules_->getPortBaseName(port->getName(),
                                          port->getDirection());
          applyPortRename(inputPorts.front().first, portBaseName, inString);
          CaseAwareString name;
          if (newNoPort)
            name = namingRules_->getInternalSignalName(portBaseName);
          else
            name = namingRules_->getPortName(portBaseName, inString);
          SignalPort * newport =
            new SignalPort(name, type, newNoPort, inString,
                           port->getPortOrder(), sourceLoc_);
          newport->setGroupComment(findGroupComment(portGroup->second));
          newport->setPortComment(findPortComment(inputPorts));
          type_->addSignalPort(newport);
          for (NameAndPortList::const_iterator port=inputPorts.begin();
               port!=inputPorts.end(); ++port)
            {
              type_->addXrf(newport, port->second, port->first);
            }
        }

      // case 3 : 1 output and more than zero inputs
      //       -> create a signal and connect all
      else if (nrOuts == 1 && nrIns > 0 && nrInouts == 0)
        {
          SignalPort * sig =
            new SignalPort(namingRules_->
                           getInternalSignalName(portGroup->first), type, true,
                           CaseAwareString(), -1, sourceLoc_);
          type_->addSignalPort(sig);
          for (NameAndPortList::const_iterator port=inputPorts.begin();
               port!=inputPorts.end(); ++port)
            {
              type_->addXrf(sig, port->second, port->first);
            }
          type_->addXrf(sig, outputPorts.front().second,
                        outputPorts.front().first);
        }

      // case 4 : 1 output
      //       -> create output port and connect it
      else if (nrOuts == 1 && nrInouts == 0)
        {
          SignalPort * port = outputPorts.front().second;
          CaseAwareString portBaseName =
            namingRules_->getPortBaseName(port->getName(),
                                          port->getDirection());
          applyPortRename(outputPorts.front().first, portBaseName, outString);
          CaseAwareString name;
          if (newNoPort)
            name = namingRules_->getInternalSignalName(portBaseName);
          else
            name = namingRules_->getPortName(portBaseName, outString);
          SignalPort * newport =
            new SignalPort(name, type, newNoPort, outString,
                           port->getPortOrder(), sourceLoc_);
          newport->setGroupComment(findGroupComment(portGroup->second));
          newport->setPortComment(findPortComment(outputPorts));
          type_->addSignalPort(newport);
          type_->addXrf(newport, outputPorts.front().second,
                        outputPorts.front().first);
        }
      // case 5 : inouts in combination with in or out
      //        -> error
      else if (nrInouts != 0 && (nrOuts != 0 || nrIns != 0))
        {
          CaseAwareString instances;
          for (NameAndPortList::const_iterator port=outputPorts.begin();
               port!=outputPorts.end(); ++port)
            {
              instances += port->first + "\n";
            }
          throw AriException(EX_MIX_INOUT, type_->getEntityName().str(),
                             portGroup->first.str(), instances.str());
        }
      // case 6 : 1 inout
      //        -> create inout port and connect it
      else if (nrInouts == 1)
        {
          SignalPort * port = inoutPorts.front().second;
          CaseAwareString portBaseName =
            namingRules_->getPortBaseName(port->getName(),
                                          port->getDirection());
          applyPortRename(inoutPorts.front().first, portBaseName,
                          inoutString);
          SignalPort * newport =
            new SignalPort(namingRules_->getPortName(portBaseName, inoutString),
                           type, newNoPort, inoutString, port->getPortOrder(),
                           sourceLoc_);
          newport->setGroupComment(findGroupComment(portGroup->second));
          newport->setPortComment(findPortComment(inoutPorts));
          type_->addSignalPort(newport);
          type_->addXrf(newport, inoutPorts.front().second,
                        inoutPorts.front().first);
        }
      // case 7 : more than 1 inout
      //        -> connect them
      else if (nrInouts > 0)
        {
          if (nrInouts == 0)
            throw AriException(EX_INTERNAL_ERROR, __FILE__);
          SignalPort * port = inoutPorts.front().second;
          SignalPort * sig =
            new SignalPort(namingRules_->getInternalSignalName
                           (portGroup->first), type, true, CaseAwareString(),
                           port->getPortOrder(), sourceLoc_);
          type_->addSignalPort(sig);
          for (NameAndPortList::const_iterator port=inoutPorts.begin();
               port!=inoutPorts.end(); ++port)
            {
              type_->addXrf(sig, port->second, port->first);
            }
        }
    }

  // Collect all the generics from the subinstances and group them by name
  // Child instance name and generics pointer
  typedef std::pair<CaseAwareString, ConstGeneric*> NameAndGeneric;
  typedef std::list<NameAndGeneric> NameAndGenericList;
  // Per generic name, a list of child instance name and generic pointer
  typedef std::map<CaseAwareString, NameAndGenericList> GenericGroups;
  GenericGroups genericGroups;
  GenericList genericList;
  for (ModuleInstanceList::const_iterator instance=subInstances_.begin();
       instance!=subInstances_.end(); ++instance)
    {
      genericList = (*instance)->type_->getGenerics();
      for (GenericList::const_iterator generic=genericList.begin();
           generic!=genericList.end(); ++generic)
        {
          genericGroups[(*generic)->getName()].
            push_back(std::make_pair((*instance)->instanceName_, *generic));
        }
    }

  // Then create new constants/generics where needed and add xrfs
  for (GenericGroups::const_iterator genericGroup=genericGroups.begin();
       genericGroup!=genericGroups.end(); ++genericGroup)
    {
      NameAndGenericList generics;
      // Don't touch a group if this module already has a const/generic of the
      // same name (which must have been explicitly set in the dsc file)
      ConstGeneric * constGeneric = type_->getConstGeneric(genericGroup->first);
      if (constGeneric)
        {
          for (NameAndGenericList::const_iterator
               generic=genericGroup->second.begin();
               generic!=genericGroup->second.end(); ++generic)
            {
              // And if the user xrf'd this generic, don't even connect it.  It
              // will be connected by the user xrf.
              if (type_->haveUserXrf(generic->first,
                                     generic->second->getName()))
                continue;
              type_->addXrf(constGeneric, generic->second, generic->first);
            }
          continue;
        }

      unsigned int genericCount = 0;
      for (NameAndGenericList::const_iterator
           generic=genericGroup->second.begin();
           generic!=genericGroup->second.end(); ++generic)
        {
          // Exclude explicitly xrf'd ports
          if (type_->haveUserXrf(generic->first, genericGroup->first))
            continue;
          ++genericCount;
        }

      // case 1 : 1 or more generic
      //       -> create a generic and connect it
      if (genericCount >= 1)
        {
          ConstGeneric * newgeneric =
            new ConstGeneric(genericGroup->second.front().second->getName(),
                             genericGroup->second.front().second->getType(),
                             false,
                             genericGroup->second.front().second->getValue(),
                             sourceLoc_);
          newgeneric->overridePortOrder(genericGroup->second.front().second->
                                        getPortOrder());
          type_->addConstGeneric(newgeneric);

          // Loop over list of appearances of the generic
          // Submodule consists of instance name and generic pointer
          for (auto submodule : genericGroup->second)
            {
              if (type_->haveUserXrf(submodule.first, genericGroup->first))
                continue;
              type_->addXrf(newgeneric, submodule.second, submodule.first);
            }
        }
    }

  // Handle UserXrfs
  // First handle xrfs where the first part (the signal name) does not contain
  // a .  or () (record and array stuff)
  // Then handle the xrfs with record and array indices
  // This way the first iteration can add the high level typed (record, array)
  // signals to the module and the second iteration will then find these signals
  // and can reference them
  for (unsigned int iteration=0; iteration<2; ++iteration)
    {
  for (ModuleInstanceList::const_iterator instance=subInstances_.begin();
       instance!=subInstances_.end(); ++instance)
    {
      Module::UserXrfList userXrfs =
        type_->getUserXrfsForInstance((*instance)->instanceName_);
      for (Module::UserXrfList::const_iterator userXrf=userXrfs.begin();
           userXrf!=userXrfs.end(); ++userXrf)
        {
          CaseAwareString basicPortName = userXrf->first;
          std::string::size_type stop = basicPortName.find_first_of("(.");
          if (stop != std::string::npos)
            {
              if (iteration == 0)
                continue;
              basicPortName = basicPortName.substr(0, stop).removeSpaces();
            }
          else
            {
              if (iteration == 1)
                continue;
            }
          SignalPort * sigPort = type_->getSignalPort(basicPortName);
          SignalPort * subSigPort =
            (*instance)->type_->getSignalPort(userXrf->second);

          ConstGeneric * constGeneric = type_->getConstGeneric(basicPortName);
          ConstGeneric * subConstGeneric =
            (*instance)->type_->getConstGeneric(userXrf->second);

          // Weed out non-ports
          if (subSigPort)
            if (!subSigPort->isPort())
              subSigPort = 0;

          // Weed out constants
          if (subConstGeneric)
            if (subConstGeneric->isConstant())
              subConstGeneric = 0;

          if (subSigPort)
            {
              if (!sigPort)
                {
                  // Try to figure out the type
                  // subSigPort->getType() is not always correct since it can
                  // be the record type and the xrf can be a signal indexed in
                  // the record

                  CaseAwareString type = CaseAwareString(true, "@UNKNOWN@");
                  // check if the type of subSigPort is an array or record,
                  // if not, use the type of subSigPort
                  // If it is a array or record, postpone determination of type
                  // hoping there will be another xrf that can be used to
                  // determine the type
                  if (userXrf->second.find_first_of("().") ==
                      std::string::npos)
                    {
                      type = renameGenericInType((*instance)->instanceName_,
                                           subSigPort->getType());
                    }

                  sigPort = new SignalPort(userXrf->first, type, true,
                                           CaseAwareString(), -1, sourceLoc_);
                  type_->addSignalPort(sigPort);
                }
              else
                {
                  // port or signal already created
                  if (sigPort->getType() == "@UNKNOWN@")
                    {
                      if (userXrf->second.find_first_of("().") ==
                          std::string::npos)
                        {
                          CaseAwareString type =
                            renameGenericInType((*instance)->instanceName_,
                                          subSigPort->getType());
                          sigPort->setType(type);
                          SignalPort * relatedPort = sigPort->getRelatedPort();
                          if (relatedPort)
                            relatedPort->setType(type);
                        }
                    }
                  else
                    {
                      // Maybe this one has an constrained type and the original
                      // one had an unconstrainted type -> prefer the
                      // constrained one
                      CaseAwareString type =
                        renameGenericInType((*instance)->instanceName_,
                                      subSigPort->getType());
                      if (userXrf->second.find_first_of("().") ==
                          std::string::npos)
                        if (sigPort->getType().find('(') == std::string::npos &&
                            type.find('(') != std::string::npos)
                          {
                            sigPort->setType(type);
                            SignalPort * relatedPort =sigPort->getRelatedPort();
                            if (relatedPort)
                              relatedPort->setType(type);
                          }
                    }
                }
              // Inherit comments
              if (sigPort->getGroupComment().empty())
                sigPort->setGroupComment(subSigPort->getGroupComment());
              if (sigPort->getPortComment().empty())
                sigPort->setPortComment(subSigPort->getPortComment());

              // userXrf->second is not necessarily the same as
              // subSigPort->getName() (record and array indexing)
              // -> make a new one with the correct name if needed
              using StringUtil::removeDoubleSpaces;
              if (subSigPort->getName().removeSpaces() !=
                  userXrf->second.removeSpaces())
                {
                  subSigPort =
                    new SignalPort(userXrf->second,
                                   renameGenericInType((*instance)->instanceName_,
                                                 subSigPort->getType()), false,
                                   subSigPort->getDirection(), sourceLoc_);
                }
              // The same goes for sigPort
              // -> make a new port with the correct name if needed
              if (sigPort->getName().removeSpaces() !=
                  userXrf->first.removeSpaces())
                {
                  sigPort = new SignalPort(userXrf->first.removeDoubleSpaces(),
                                           sigPort->getType(),
                                           false, sigPort->getDirection(), -1,
                                           sourceLoc_);
                }
              type_->addXrf(sigPort, subSigPort, (*instance)->instanceName_);
            }
          else if (subConstGeneric)
            {
              if (!constGeneric)
                {
                  constGeneric = new ConstGeneric(userXrf->first,
                                                  subConstGeneric->getType(),
                                                  true,
                                                  subConstGeneric->getValue(),
                                                  sourceLoc_);
                  type_->addConstGeneric(constGeneric);
                }
              type_->addXrf(constGeneric, subConstGeneric,
                            (*instance)->instanceName_);
            }
          else
            {
              throw AriException(EX_NO_SUCH_PORT,
                                 (*instance)->type_->getEntityName().str(),
                                 userXrf->second.str(),
                                 userXrf->loc);
            }
        }
    }
    }

  // Handle user assigns
  for (ModuleInstanceList::const_iterator instance=subInstances_.begin();
       instance!=subInstances_.end(); ++instance)
    {
      Module::UserXrfList userAssigns =
        type_->getUserAssignsForInstance((*instance)->instanceName_);
      for (Module::UserXrfList::const_iterator userAssign=userAssigns.begin();
           userAssign!=userAssigns.end(); ++userAssign)
        {
          SignalPort * subSigPort =
            (*instance)->type_->getSignalPort(userAssign->second);
          ConstGeneric * subConstGeneric =
            (*instance)->type_->getConstGeneric(userAssign->second);

          // Weed out non-ports
          if (subSigPort)
            if (!subSigPort->isPort())
              subSigPort = 0;

          // Weed out constants
          if (subConstGeneric)
            if (subConstGeneric->isConstant())
              subConstGeneric = 0;

          if (subSigPort)
            {
              type_->addAssign(userAssign->first, subSigPort,
                               (*instance)->instanceName_);
            }
          else if (subConstGeneric)
            {
              type_->addAssign(userAssign->first, subConstGeneric,
                               (*instance)->instanceName_);
            }
          else
            {
              throw AriException(EX_NO_SUCH_PORT,
                                 (*instance)->type_->getEntityName().str(),
                                 userAssign->second.str(),
                                 userAssign->loc);
            }
        }
    }
}

void ModuleInstance::generate(const StringUtil::stringlist & argv,
                              const std::string & ariFile,
                              const StringUtil::stringlist & inputFiles)
{
  XrfBase::generating = true;
  for (ModuleInstanceList::iterator instance=subInstances_.begin();
       instance!=subInstances_.end(); ++instance)
    {
      (*instance)->generate(argv, ariFile, inputFiles);
    }

  if (!type_->isGenerated())
    return;

  FileHeader * header = getFileHeader();
  if (header)
    {
      header->setVar("module", type_->getEntityName().strCase());
      if (type_->getLanguage() == Module::LANGUAGE_VHDL)
        header->setComment("--");
      else if (type_->getLanguage() == Module::LANGUAGE_SYSTEMC)
        header->setComment("//");
      else if (type_->getLanguage() == Module::LANGUAGE_VERILOG)
        header->setComment("//");
    }

  if (type_->getLanguage() == Module::LANGUAGE_VHDL)
    generateVhdl(argv, ariFile, inputFiles);
  else if (type_->getLanguage() == Module::LANGUAGE_SYSTEMC)
    generateSystemC(argv, ariFile, inputFiles);
  else if (type_->getLanguage() == Module::LANGUAGE_VERILOG)
    generateVerilog(argv, ariFile, inputFiles);

  std::list<std::string> postExecScripts = type_->getPostExecScripts();
  for (auto script : postExecScripts)
    exec_script(script);
}

void ModuleInstance::queryPackages() const
{
  auto entityContext = getContext();

  Context rtlContext = type_->getRtlContext();
  for (ModuleInstanceList::const_iterator instance=subInstances_.begin();
       instance!=subInstances_.end(); ++instance)
    {
      rtlContext.merge((*instance)->type_->getRtlContext());
    }
  auto allContext = entityContext.getAllContext();
  std::cout << "Entity packages and their origin\n";
  for (auto lib : allContext)
    {
      for (auto package : lib.second)
        {
          SourceLocInfo locInfo =
            SourceLocManager::instance().resolveSourceLoc(package.origin);
          std::cout << lib.first << "." << package.packageName <<
            " :\n  " << locInfo.str();
        }
    }
  if (allContext.empty())
    std::cout << "no packages\n";
  std::cout << "RTL packages and their origin\n";
  allContext = rtlContext.getAllContext();
  for (auto lib : allContext)
    {
      for (auto package : lib.second)
        {
          SourceLocInfo locInfo =
            SourceLocManager::instance().resolveSourceLoc(package.origin);
          std::cout << lib.first << "." << package.packageName <<
            " :\n  " << locInfo.str();
        }
    }
  if (allContext.empty())
    std::cout << "no packages\n";
}

ModuleInstance::ModuleInstanceList ModuleInstance::getSubInstances() const
{
  return subInstances_;
}

ModuleInstance *
ModuleInstance::getSubInstance(const CaseAwareString & instanceName) const
{
  for (auto child=subInstances_.begin(); child!=subInstances_.end(); ++child)
    {
      if ((*child)->getInstanceName() == instanceName)
        return *child;
    }
  return 0;
}

CaseAwareString ModuleInstance::getInstanceName() const
{
  return instanceName_;
}

ModuleInstance::RubyXrfList
ModuleInstance::getXrfs(const CaseAwareString & childInstanceName,
                        bool portsNotGenerics) const
{
  Module::XrfList autoXrfs = type_->getXrfsForInstance(childInstanceName,
                                                       portsNotGenerics);
  RubyXrfList result;
  for (auto autoXrf=autoXrfs.begin(); autoXrf!=autoXrfs.end(); ++autoXrf)
    {
      RubyXrf * xrf = new RubyXrf; // Oops, memory leak
      xrf->signalName = autoXrf->getParent()->getName();
      xrf->childPortName = autoXrf->getChild()->getName();
      result.push_back(xrf);
    }
  return result;
}

ModuleInstance::RubyXrfList
ModuleInstance::getUserXrfs(const CaseAwareString & childInstanceName) const
{
  Module::UserXrfList userXrfs =
    type_->getUserXrfsForInstance(childInstanceName);
  RubyXrfList result;
  for (auto userXrf=userXrfs.begin(); userXrf!=userXrfs.end(); ++userXrf)
    {
      RubyXrf * xrf = new RubyXrf; // Oops, memory leak
      xrf->signalName = userXrf->first;
      xrf->childPortName = userXrf->second;
      result.push_back(xrf);
    }
  return result;
}

ModuleInstance::RubyXrfList
ModuleInstance::getUserAssigns(const CaseAwareString & childInstanceName) const
{
  Module::UserXrfList userAssigns =
    type_->getUserAssignsForInstance(childInstanceName);
  RubyXrfList result;
  for (auto userAssign=userAssigns.begin(); userAssign!=userAssigns.end();
       ++userAssign)
    {
      RubyXrf * assign = new RubyXrf; // Oops, memory leak
      assign->signalName = userAssign->first;
      assign->childPortName = userAssign->second;
      result.push_back(assign);
    }
  return result;
}

void ModuleInstance::generateVhdl(const StringUtil::stringlist & argv,
                                  const std::string & ariFile,
                                  const StringUtil::stringlist & inputFiles)
{
  AriOptions * ariOptions = AriOptions::getInstance();

  CaseAwareString entityName = type_->getEntityName();
  std::string filename = namingRules_->getEntityFileName(entityName);
  if (ariOptions->entitiesCastInStone)
    {
      verifyExistingEntity(filename);
    }
  else if (ariOptions->getWriteEntity())
    {
      SmartFile entity(filename.c_str());

      if (getFileHeader()) {
        getFileHeader()->setVar("designunit", "VHDL entity");
        getFileHeader()->setVar("fname", filename);
        entity << getFileHeader()->stream();
      }
      writeGeneratedBlock(entity, CaseAwareString(keepCase(), "--"),
                          argv, ariFile, inputFiles);

      entity << getContext().getText();

      CaseAwareString entityComment = type_->getEntityComment();
      if (!entityComment.empty())
        {
          formatComment(entityComment, CaseAwareString(keepCase(), "-- "));
          entity << entityComment << "\n";
        }
      entity << "entity " << entityName << " is\n";
      PortList ports = type_->getPorts();
      GenericList generics = type_->getGenerics();
      writeGenerics(entity, generics, "", keepCase());
      writePorts(entity, ports, "", keepCase());
      entity << "end " << entityName << ";\n";
      entity.close();
    }

  // merge rtl contexts
  Context rtlContext = type_->getRtlContext();
  for (ModuleInstanceList::const_iterator instance=subInstances_.begin();
       instance!=subInstances_.end(); ++instance)
    {
      rtlContext.merge((*instance)->type_->getRtlContext());
    }
  // library statements required when specifying a configuration inside the
  // architecture
  for (auto instance : subInstances_)
    {
      if (!instance->type_->isConfigInArch())
        continue;
      rtlContext.add(instance->type_->getLibrary(), CaseAwareString(),
                     sourceLoc_);
    }

  CaseAwareString arch = type_->getArchitecture();
  filename = namingRules_->getArchitectureFileName(entityName, arch);
  SmartFile rtl(filename);
  if (getFileHeader()) {
    getFileHeader()->setVar("designunit", "VHDL architecture");
    getFileHeader()->setVar("fname", filename);
    rtl << getFileHeader()->stream();
  }
  writeGeneratedBlock(rtl, CaseAwareString(keepCase(), "--"),
                      argv, ariFile, inputFiles);
  rtl << rtlContext.getText();
  CaseAwareString archComment = type_->getArchComment();
  if (!archComment.empty())
    {
      formatComment(archComment, CaseAwareString(keepCase(), "-- "));
      rtl << archComment << "\n";
    }
  rtl << "architecture " << type_->getArchitecture() << " of "
      << entityName << " is\n";

  // User declarations to go at the top of the file
  // e.g. type declarations for signals that are defined in the .ari file
  rtl << type_->getDeclarationsTop() << "\n";

  // Constants
  GenericList constants = type_->getConstants();
  auto sortedConstants = constants;
  std::sort(sortedConstants.begin(), sortedConstants.end(),
            [] (ConstGeneric * p1, ConstGeneric * p2)
            {
            return p1->getPortOrder() < p2->getPortOrder();
            });
  for (auto constant : sortedConstants)
    {
      rtl << "  constant " << constant->getName() << " : " <<
        constant->getType() << " := " << constant->getValue() << ";\n";
    }

  // Signals
  PortList signals = type_->getSignals();
  for (PortList::const_iterator sig=signals.begin(); sig!=signals.end(); ++sig)
    {
      if ((*sig)->getName() != "open")
        rtl << "  signal " << (*sig)->getName() << " : " << (*sig)->getType()
          << ";\n";
    }

  // Components declarations
  std::set<CaseAwareString> uniqueNames;
  for (ModuleInstanceList::const_iterator instance=subInstances_.begin();
       instance!=subInstances_.end(); ++instance)
    {
      if (!(*instance)->type_->haveComponentPackage())
        {
          CaseAwareString name = (*instance)->type_->getEntityName();
          if (uniqueNames.find(name) != uniqueNames.end())
            continue;
          uniqueNames.insert(name);
          rtl << "  component " << name << "\n";
          writeGenerics(rtl, (*instance)->type_->getGenerics(), "  ",
                        keepCase());
          writePorts(rtl, (*instance)->type_->getPorts(), "  ", keepCase());
          rtl << "  end component;\n\n";
        }
    }

  Module::ConfigurationList configs = type_->getConfigurations();

  // Configuration declarations
  for (auto instance : subInstances_)
    {
      if (!instance->type_->isConfigInArch())
        continue;
      if (configs.empty())
        {
          Module * type = instance->type_;
          std::ostringstream forClause;
          forClause << "  for " << instance->instanceName_ << " : "
            << type->getEntityName() << "\n"
            << "    use entity "
            << type->getLibrary() << "." << type->getEntityName()
            << "(" << type->getArchitecture() << ");\n";
          rtl << forClause.str();
        }
      else
        {
          // Check if all configurations have the same selection for this
          // instance
          bool isSubconfig;
          CaseAwareString subName;
          bool first = true;
          for (auto config : configs)
            {
              auto subconfig =config.subconfigs.find(instance->instanceName_);
              auto subarch = config.subarchs.find(instance->instanceName_);
              if (first)
                {
                  if (subconfig != config.subconfigs.end())
                    {
                      first = false;
                      isSubconfig = true;
                      subName = subconfig->second.name;
                    }
                  if (subarch != config.subarchs.end())
                    {
                      first = false;
                      isSubconfig = false;
                      subName = subarch->second.name;
                    }
                }
              else
                {
                  if (subconfig != config.subconfigs.end())
                    {
                      if (!isSubconfig || subconfig->second.name != subName)
                        throw AriException(EX_MULTIPLE_CONFIGS_NO_INLINE,
                                           instance->type_->getEntityName().
                                           str());
                    }
                  if (subarch != config.subarchs.end())
                    {
                      if (isSubconfig || subarch->second.name != subName)
                        throw AriException(EX_MULTIPLE_CONFIGS_NO_INLINE,
                                           instance->type_->getEntityName().
                                           str());
                    }
                }
            }
          Module * type = instance->type_;
          std::ostringstream forClause;
          forClause << "  for " << instance->instanceName_ << " : "
            << type->getEntityName() << "\n";
          bool blackbox = false;
          if (!first && isSubconfig)
            {
              forClause << "    use configuration "
                << type->getLibrary() << "." << subName
                << ";\n";
              blackbox = subName == "blackbox";
            }
          else if (!first && !isSubconfig)
            {
              forClause << "    use entity "
                << type->getLibrary() << "." << type->getEntityName()
                << "(" << subName << ");\n";
            }
          else
            {
              forClause << "    use entity "
                << type->getLibrary() << "." << type->getEntityName()
                << "(" << type->getArchitecture() << ");\n";
            }
          if (!blackbox)
            rtl << forClause.str();
        }
    }

  // User declarations
  rtl << type_->getDeclarations() << "\n";

  rtl << "begin\n";

  // Component instantiations
  for (ModuleInstanceList::const_iterator instance=subInstances_.begin();
       instance!=subInstances_.end(); ++instance)
    {
      CaseAwareString instComment =
        type_->getInstComment((*instance)->instanceName_);
      formatComment(instComment, CaseAwareString(keepCase(), "  -- "));
      if (!instComment.empty())
        rtl << instComment << "\n";
      rtl << "  " << (*instance)->instanceName_ << " : "
        << (*instance)->type_->getEntityName() << "\n";
      Module::XrfList xrfs =
        type_->getXrfsForInstance((*instance)->instanceName_, false);
      Module::AssignList assigns =
        type_->getAssignsForInstance((*instance)->instanceName_, false);
      if (!xrfs.empty() || !assigns.empty())
        {
          rtl << "    generic map (\n      ";
          CaseAwareStringList lines;
          for (Module::XrfList::const_iterator xrf=xrfs.begin();
               xrf!=xrfs.end(); ++xrf)
            {
              lines.push_back(xrf->getChild()->getName() + " => " +
                              xrf->getParent()->getName());
            }
          for (Module::AssignList::const_iterator assign=assigns.begin();
               assign!=assigns.end(); ++assign)
            {
              lines.push_back(assign->getChild()->getName() + " => " +
                              assign->getValue());
            }
          rtl << join(",\n      ", lines);
          rtl << ")\n";
        }
      xrfs = type_->getXrfsForInstance((*instance)->instanceName_, true);
      assigns = type_->getAssignsForInstance((*instance)->instanceName_, true);
      if (!xrfs.empty() || !assigns.empty())
        {
          rtl << "    port map (\n      ";
          StringUtil::stringlist lines;
          for (Module::XrfList::const_iterator xrf=xrfs.begin();
               xrf!=xrfs.end(); ++xrf)
            {
              std::string childName;
              std::string parentName;
              if (keepCase())
                parentName = xrf->getParent()->getName().str();
              else
                parentName = xrf->getParent()->getName().strLower();
              if (keepCase())
                childName = xrf->getChild()->getName().str();
              else
                childName = xrf->getChild()->getName().strLower();
              lines.push_back(childName + " => " + parentName);
            }
          for (Module::AssignList::const_iterator assign=assigns.begin();
               assign!=assigns.end(); ++assign)
            {
              lines.push_back(assign->getChild()->getName().str() + " => " +
                              assign->getValue().str());
            }
          rtl << StringUtil::join(",\n      ", lines);
          rtl << ")";
        }
      rtl << ";\n";
    }

  // User statements
  rtl << type_->getStatements() << "\n";

  rtl << "end " << type_->getArchitecture() << ";\n";
  rtl.close();

  /// Configuration ///
  std::set<CaseAwareString> libs;
  for (ModuleInstanceList::const_iterator instance=subInstances_.begin();
       instance!=subInstances_.end(); ++instance)
    libs.insert((*instance)->type_->getLibrary());

  CaseAwareString configurationName
    = namingRules_->getConfigurationName(entityName, arch);

  if (configs.empty())
    {
      filename = namingRules_->getConfigurationFileName(configurationName);
      SmartFile cfg(filename.c_str());

      if (getFileHeader()) {
        getFileHeader()->setVar("designunit", "VHDL configuration");
        getFileHeader()->setVar("fname", filename);
        cfg << getFileHeader()->stream();
      }
      writeGeneratedBlock(cfg, CaseAwareString(keepCase(), "--"),
                          argv, ariFile, inputFiles);

      for (std::set<CaseAwareString>::const_iterator lib=libs.begin();
           lib!=libs.end(); ++lib)
        if (*lib != "work")
          cfg << "library " << *lib << ";\n";

      cfg << "configuration " << configurationName
        << " of " << entityName << " is\n"
        << "  for " << arch << "\n";
      for (ModuleInstanceList::const_iterator instance=subInstances_.begin();
           instance!=subInstances_.end(); ++instance)
        {
          Module * type = (*instance)->type_;
          if (type->isConfigInArch())
            continue;
          cfg << "    for " << (*instance)->instanceName_ << " : "
            << type->getEntityName() << "\n      use entity "
            << type->getLibrary() << "." << type->getEntityName()
            << "(" << type->getArchitecture() << ");\n" << "    end for;\n";
        }
      cfg << "  end for;\n";
      cfg << "end " << configurationName << ";\n";
      cfg.close();
    }
  else
    {
      for (Module::ConfigurationList::const_iterator config=configs.begin();
           config!=configs.end(); ++config)
        {
          filename = namingRules_->getConfigurationFileName(config->name);
          SmartFile cfg(filename.c_str());

          if (getFileHeader()) {
            getFileHeader()->setVar("designunit", "VHDL configuration");
            getFileHeader()->setVar("fname", filename);
            cfg << getFileHeader()->stream();
          }
          writeGeneratedBlock(cfg, CaseAwareString(keepCase(), "--"),
                              argv, ariFile, inputFiles);

          for (std::set<CaseAwareString>::const_iterator lib=libs.begin();
               lib!=libs.end(); ++lib)
            if (*lib != "work")
              cfg << "library " << *lib << ";\n";

          cfg << "configuration " << config->name << " of " << entityName
            << " is\n"
            << "  for " << arch << "\n";
          for (ModuleInstanceList::const_iterator inst=subInstances_.begin();
               inst!=subInstances_.end(); ++inst)
            {
              Module * type = (*inst)->type_;
              if (type->isConfigInArch())
                continue;
              std::ostringstream forClause;
              forClause << "    for " << (*inst)->instanceName_ << " : "
                << type->getEntityName() << "\n";
              std::map<CaseAwareString,Module::SubConfigInfo>::const_iterator
                subconfig = config->subconfigs.find((*inst)->instanceName_);
              std::map<CaseAwareString,Module::SubArchInfo>::const_iterator
                subarch = config->subarchs.find((*inst)->instanceName_);
              bool blackbox = false;
              if (subconfig != config->subconfigs.end())
                {
                  forClause << "      use configuration "
                    << type->getLibrary() << "." << subconfig->second.name
                    << ";\n";
                  blackbox = (subconfig->second.name == "blackbox");
                }
              else if (subarch != config->subarchs.end())
                {
                  forClause << "      use entity "
                    << type->getLibrary() << "." << type->getEntityName()
                    << "(" << subarch->second.name << ");\n";
                }
              else
                {
                  forClause << "      use entity "
                    << type->getLibrary() << "." << type->getEntityName()
                    << "(" << type->getArchitecture() << ");\n";
                }
              forClause << "    end for;\n";
              if (!blackbox)
                cfg << forClause.str();
            }
          cfg << "  end for;\n";
          cfg << "end " << config->name << ";\n";
        }
    }
}

void ModuleInstance::writePorts(SmartFile & file, const PortList & ports,
                                const std::string & indent, bool keepCase)
{
  if (!ports.empty())
    {
      file << indent << "  port (\n";
      typedef std::map<CaseAwareString, PortList> PortGroups;
      PortGroups portGroups;
      typedef std::pair<CaseAwareString,int> CommentWithOrder;
      std::vector<CommentWithOrder> sortedGroups;
      unsigned int numPorts = 0;
      for (PortList::const_iterator port=ports.begin(); port!=ports.end();
           ++port)
        {
          CaseAwareString groupComment = (*port)->getGroupComment();
          formatComment(groupComment, CaseAwareString(keepCase,
                                                      indent + "        --/ "));
          portGroups[groupComment].push_back(*port);
          ++numPorts;
        }
      // Sort port groups based on the smallest port order in the group
      for (auto portGroup : portGroups)
        {
          int smallest_order =
            (*std::min_element(portGroup.second.begin(),
                             portGroup.second.end(),
                             [](SignalPort * p1, SignalPort * p2)
                             {
                               return p1->getPortOrder() < p2->getPortOrder();
                             }))->getPortOrder();
          sortedGroups.push_back({portGroup.first,smallest_order});
        }
      std::sort(sortedGroups.begin(), sortedGroups.end(),
                [](CommentWithOrder const & group1,
                   CommentWithOrder const & group2)
                {
                  // .second is port order
                  return group1.second < group2.second;
                });

      unsigned int portNum = 1;
      for (auto sortGroup : sortedGroups)
        {
          auto portGroup = portGroups.find(sortGroup.first);
          if (portGroup == portGroups.end())
            throw AriException(EX_INTERNAL_ERROR, "Port group not found");
          if (!portGroup->first.empty())
            file << portGroup->first << "\n";
          else
            file << "\n";
          PortList sortedPorts = portGroup->second;
          std::sort(sortedPorts.begin(), sortedPorts.end(),
                    [] (SignalPort * p1, SignalPort * p2)
                    {
                      return p1->getPortOrder() < p2->getPortOrder();
                    });
          for (PortList::const_iterator port=sortedPorts.begin();
               port!=sortedPorts.end();)
            {
              CaseAwareString portComment = (*port)->getPortComment();
              if (!portComment.empty())
                {
                  formatComment(portComment,
                                CaseAwareString(keepCase,
                                                indent + "        --// "));
                  file << portComment << "\n";
                }
              CaseAwareString direction = (*port)->getDirection();
              file << indent << "        ";
              if (keepCase)
                file << (*port)->getName().str();
              else
                file << (*port)->getName().strLower();
              file << " : "
                << direction << " " << (*port)->getType();
              ++port;
              if (portNum != numPorts)
                file << ";";
              ++portNum;
              file << "\n";
            }
        }
      file << indent << "       );\n";
    }
}

void ModuleInstance::writeSystemCPorts(SmartFile & file,
                                       const PortList & ports,
                                       const std::string & indent,
                                       bool keepCase,
                                       CaseAwareStringList & memberInits)
{
  if (!ports.empty())
    {
      typedef std::map<CaseAwareString, PortList> PortGroups;
      PortGroups portGroups;
      unsigned int numPorts = 0;
      for (PortList::const_iterator port=ports.begin(); port!=ports.end();
           ++port)
        {
          portGroups[(*port)->getGroupComment()].push_back(*port);
          ++numPorts;
        }
      unsigned int groupNum = 0;
      for (PortGroups::const_iterator portGroup=portGroups.begin();
           portGroup!=portGroups.end(); ++portGroup, ++groupNum)
        {
          CaseAwareString groupComment = portGroup->first;
          if (!groupComment.empty())
            {
              formatComment(groupComment, CaseAwareString(keepCase,
                                                          indent + "   *"));
              file << indent << "  /** @name Group" << groupNum << "\n"
                   << indent << "   * " << groupComment
                   << indent << "   */\n"
                   << indent << "  //@{\n";
            }
          PortList sortedPorts = portGroup->second;
          std::sort(sortedPorts.begin(), sortedPorts.end(),
                    [] (SignalPort * p1, SignalPort * p2)
                    {
                      return p1->getPortOrder() < p2->getPortOrder();
                    });
          for (PortList::const_iterator port=sortedPorts.begin();
               port!=sortedPorts.end(); ++port)
            {
              CaseAwareString portComment = (*port)->getPortComment();
              if (!portComment.empty())
                {
                  formatComment(portComment,
                                CaseAwareString(keepCase, indent + "  //! "));
                  file << portComment << "\n";
                }

              CaseAwareString direction = (*port)->getDirection();
              file << indent << "  ";
              file << "sc_core::sc_" << direction << "<"
                   << prependScDtIfNeeded((*port)->getType())
                   << " > ";
              if (keepCase)
                {
                  file << (*port)->getName();
                  memberInits.push_back((*port)->getName() + "(\"" +
                                        (*port)->getName() + "\")");
                }
              else
                {
                  file << (*port)->getName().strLower();
                  memberInits.push_back((*port)->getName().lower() + "(\"" +
                                        (*port)->getName().lower() + "\")");
                }
              file << ";\n";
            }
          if (!portGroup->first.empty())
            file << indent << "  //@}\n";
        }
    }
}

void ModuleInstance::writeGenerics(SmartFile & file,
                                   const GenericList & generics,
                                   const std::string & indent,
                                   bool keepCase)
{
  if (!generics.empty())
    {
      file << indent << "  generic (\n";
      auto sortedGenerics = generics;
      std::sort(sortedGenerics.begin(), sortedGenerics.end(),
                [] (ConstGeneric * p1, ConstGeneric * p2)
                {
                  return p1->getPortOrder() < p2->getPortOrder();
                });
      for (GenericList::const_iterator generic=sortedGenerics.begin();
           generic!=sortedGenerics.end();)
        {
          file << indent << "        ";
          if (keepCase)
            file << (*generic)->getName().str();
          else
            file << (*generic)->getName().strLower();
          file << " : " << (*generic)->getType();
          CaseAwareString genericValue = (*generic)->getValue();
          if (!genericValue.empty())
            file << " := " << (*generic)->getValue();
          ++generic;
          if (generic!=sortedGenerics.end())
            file << ";";
          file << "\n";
        }
      file << indent << "       );\n";
    }
}

void ModuleInstance::writeGeneratedBlock(SmartFile & output,
                                         const CaseAwareString & commentToken,
                                         const StringUtil::stringlist & argv,
                                         const std::string & ariFile,
                                         const StringUtil::stringlist &
                                         inputFiles)
{
  StringUtil::stringlist argvWithoutFirst = argv;
  argvWithoutFirst.erase(argvWithoutFirst.begin());
  output << commentToken << " EASICS generated file\n";
  output << commentToken << " command : ariadne "
         << StringUtil::join(" ", argvWithoutFirst) <<"\n";
  char * namingRules = getenv("ARIADNE_NAMING_RULES");
  if (namingRules)
    output << commentToken << " env : ARIADNE_NAMING_RULES=" << namingRules
      << "\n";
  char * groupSource = getenv("ARIADNE_GROUP_SOURCE");
  if (groupSource)
    output << commentToken << " env : ARIADNE_GROUP_SOURCE=" << groupSource
      << "\n";
  char * forceWrite = getenv("ARIADNE_FORCE_WRITE");
  if (forceWrite)
    output << commentToken << " env : ARIADNE_FORCE_WRITE=" << forceWrite
      << "\n";
  char * regenerate = getenv("ARIADNE_REGENERATE");
  if (regenerate)
    output << commentToken << " env : ARIADNE_REGENERATE=" << regenerate
      << "\n";
  output << commentToken << " tool_version : " << ariadneVersionString << "\n";
  output << commentToken << " input : " << ariFile << "\n";
  for (auto file=inputFiles.begin(); file!=inputFiles.end(); ++file)
    {
      output << commentToken << " input : " << *file << "\n";
    }
  output << "\n";
}

Context ModuleInstance::getContext() const
{
  if (type_->isGenerated())
    {
      Context context;
      for (ModuleInstanceList::const_iterator instance=subInstances_.begin();
           instance!=subInstances_.end(); ++instance)
        {
          context.merge((*instance)->getContext());
        }
      context.substract(type_->getRemoveContext());
      context.merge(type_->getEntityContext());
      return context;
    }
  else
    {
      return type_->getContext();
    }
}

void ModuleInstance::collectGenericRenames()
{
  // Renames by xrf
  for (ModuleInstanceList::const_iterator instance=subInstances_.begin();
       instance!=subInstances_.end(); ++instance)
    {
      Module::UserXrfList userXrfs =
        type_->getUserXrfsForInstance((*instance)->instanceName_);
      for (Module::UserXrfList::const_iterator userXrf=userXrfs.begin();
           userXrf!=userXrfs.end(); ++userXrf)
        {
          try
            {
              updateGenericRenames(userXrf->first, (*instance)->instanceName_,
                                   userXrf->second);
            }
          catch (AriException & e)
            {
              SourceLocInfo locInfo =
                SourceLocManager::instance().resolveSourceLoc((*userXrf).loc);
              throw AriException(locInfo.str() + e.getMessage());
            }
          catch (std::exception & e)
            {
              SourceLocInfo locInfo =
                SourceLocManager::instance().resolveSourceLoc((*userXrf).loc);
              throw std::runtime_error(locInfo.str() + e.what());
            }
        }
    }
  // Renames by assign
  for (ModuleInstanceList::const_iterator instance=subInstances_.begin();
       instance!=subInstances_.end(); ++instance)
    {
      Module::UserXrfList userAssigns =
        type_->getUserAssignsForInstance((*instance)->instanceName_);
      for (Module::UserXrfList::const_iterator userAssign=userAssigns.begin();
           userAssign!=userAssigns.end(); ++userAssign)
        {
          try
            {
              updateGenericRenames(userAssign->first, (*instance)->instanceName_,
                                   userAssign->second);
            }
          catch (AriException & e)
            {
              SourceLocInfo locInfo =
                SourceLocManager::instance().resolveSourceLoc((*userAssign).loc);
              throw AriException(locInfo.str() + e.getMessage());
            }
          catch (std::exception & e)
            {
              SourceLocInfo locInfo =
                SourceLocManager::instance().resolveSourceLoc((*userAssign).loc);
              throw std::runtime_error(locInfo.str() + e.what());
            }
        }
    }
}

CaseAwareString
ModuleInstance::renameGenericInType(const CaseAwareString & instanceName,
                                    const CaseAwareString & type) const
{
  GenericRenames::const_iterator genericRenamesInModule =
    genericRenames_.find(instanceName);
  if (genericRenamesInModule != genericRenames_.end())
    {
      CaseAwareStringList sl =
        StringUtil::keywordsplit(type,
                                 "abcdefghijklmnopqrstuvwxyz"
                                 "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                                 "0123456789_"
                                 );
      // Replace all generics ...
      for (GenericRenameList::const_iterator genericRename =
           genericRenamesInModule->second.begin();
           genericRename!=genericRenamesInModule->second.end(); ++genericRename)
        {
          // ... in all matching words of the type
          for (auto s=sl.begin(); s!=sl.end(); ++s)
            {
              if (genericRename->origname == *s)
                *s = CaseAwareString(keepCase(), "(") + genericRename->newname +
                  ")";
            }
        }
      // Replace all constants ...
      GenericList constants = type_->getConstants();
      auto sortedConstants = constants;
      // reverse sort because a value of a constant can depend on another
      // constant.  We want to replace that too.
      std::sort(sortedConstants.begin(), sortedConstants.end(),
                [] (ConstGeneric * p1, ConstGeneric * p2)
                {
                return p1->getPortOrder() > p2->getPortOrder();
                });
      for (auto constant : sortedConstants)
        {
          sl = StringUtil::keywordsplit(join(" ", sl),
                                        "abcdefghijklmnopqrstuvwxyz"
                                        "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                                        "0123456789_"
                                       );
          // ... in all matching words of the type
          for (auto s=sl.begin(); s!=sl.end(); ++s)
            {
              if (*s == constant->getName())
                {
                  // Constant value is aggregate?
                  // Check in constant valuefor construction (name => value),
                  // by search for =>
                  // where type consists of: ( recordtypename )   .  name
                  //                        s-1     s       s+1 s+2  s+3
                  // (recordtypename).name to be replaced by value
                  CaseAwareString constantValue = constant->getValue();
                  std::string aggregateArrow = "=>";
                  if ((constantValue.str().find(aggregateArrow) !=
                       std::string::npos)
                      && ((s+1) != sl.end())
                      && ((s+2) != sl.end())
                      && ((s+3) != sl.end())
                      && (*(s+2) == "."))
                    {
                      // elementName = name
                      CaseAwareString elementName = (*(s+3));

                      // constantValueClean = name1=>value1,name2=>value2
                      CaseAwareString constantValueClean =
                        constantValue.fullstrip();
                      StringUtil::replace("\n", "", constantValueClean);
                      constantValueClean =
                        StringUtil::strip(constantValueClean, "(");
                      constantValueClean =
                        StringUtil::strip(constantValueClean, ")");

                      // list of all name=>value assignments for this type
                      CaseAwareStringList aggregateList =
                        StringUtil::split(constantValueClean, ',');

                      // start = name=>
                      CaseAwareString start =
                        CaseAwareString(elementName.caseSensitive(),
                                        elementName.str() + aggregateArrow);
                      auto needle =
                        std::find_if(aggregateList.begin(), aggregateList.end(),
                                     [start] (CaseAwareString other)
                                     {
                                       return
                                         StringUtil::startsWith(other, start);
                                     });
                      // aggregateValue = name=>value
                      CaseAwareString aggregateValue = (*needle);
                      aggregateValue.replace(start.str(), "", 1);
                      // resultingValue = (value)
                      CaseAwareString resultingValue =
                        "(" + aggregateValue + ")";
                      *s = resultingValue;
                      *(s+2) = CaseAwareString(keepCase(), "");
                      *(s+3) = CaseAwareString(keepCase(), "");
                    }
                  else
                    *s = CaseAwareString(keepCase(), "(") +
                      constant->getValue() + ")";
                }
            }
        }

      CaseAwareString result = join(" ", sl);
      StringUtil::replace(" (", "(", result);
      StringUtil::replace(" )", ")", result);
      StringUtil::replace("  ", " ", result);
      StringUtil::replace("* *", "**", result);
      StringUtil::replace("/ =", "/=", result);
      StringUtil::replace("< =", "<=", result);
      StringUtil::replace("> =", ">=", result);
      return result;
    }
  return type;
}

void ModuleInstance::applyPortRename(const CaseAwareString & instanceName,
                                     CaseAwareString & portName,
                                     const CaseAwareString & direction)
{
  const Module::PortRenameMap & portRenames = type_->getPortRenames();
  Module::PortRenameMap::const_iterator renameList =
    portRenames.find(instanceName);
  if (renameList == portRenames.end())
    return;
  for (auto rename : renameList->second)
    {
      if (!rename.matchAll)
        {
          if (!std::regex_search(portName.strCase(), rename.match,
                                 std::regex_constants::format_sed))
            continue;
        }
      auto by = rename.replacement;
      by = Module::PortRename::applyDirection(by, direction);

      portName =
        CaseAwareString(portName.caseSensitive(),
                        std::regex_replace(portName.str(),
                                           rename.originals[direction.strLower()],
                                           by.str(),
                                           std::regex_constants::format_sed));
    }
}

CaseAwareString
ModuleInstance::findGroupComment(const NameAndPortList & ports) const
{
  CaseAwareString groupComment;
  bool groupCommentIsSource = AriOptions::getInstance()->groupCommentIsSource;
  for (NameAndPortList::const_iterator port=ports.begin(); port!=ports.end();
       ++port)
    {
      if (groupCommentIsSource)
        {
          groupComment += port->first + " ";
        }
      else
        {
          groupComment = port->second->getGroupComment();
          if (!groupComment.empty())
            break;
        }
    }
  return groupComment;
}

CaseAwareString
ModuleInstance::findPortComment(const NameAndPortList & ports) const
{
  CaseAwareString portComment;
  // Take the first port which has port comments
  for (auto port=ports.begin(); port!=ports.end(); ++port)
    {
      portComment = port->second->getPortComment();
      if (!portComment.empty())
        break;
    }
  return portComment;
}

void ModuleInstance::generateSystemC(const StringUtil::stringlist & argv,
                                     const std::string & ariFile,
                                     const StringUtil::stringlist & inputFiles)
{
  AriOptions * ariOptions = AriOptions::getInstance();

  CaseAwareString entityName = type_->getEntityName();
  std::string filename = entityName.strCase() + ".h";
  PortList ports = type_->getPorts();
  const ScMethodArray & scMethods = type_->getScMethods();
  CaseAwareStringList memberInits;
  if (ariOptions->entitiesCastInStone)
    {
      verifyExistingEntity(filename);
    }
  else if (ariOptions->getWriteEntity())
    {
      SmartFile entity(filename.c_str());

      if (getFileHeader()) {
        getFileHeader()->setVar("designunit", "SystemC header file");
        getFileHeader()->setVar("fname", filename);
        entity << getFileHeader()->stream();
      }
      writeGeneratedBlock(entity, CaseAwareString(keepCase(), "//"),
                          argv, ariFile, inputFiles);

      entity << "#ifndef " << entityName << "_h_\n"
             << "#define " << entityName << "_h_\n\n";

      Context context = getContext();
      Context systemcHeader;
      systemcHeader.add(CaseAwareString(true, "systemc"),
                        CaseAwareString(true, "<systemc>"), sourceLoc_);
      context.merge(systemcHeader);
      entity << context.getSystemCText();
      for (ModuleInstanceList::const_iterator instance=subInstances_.begin();
           instance!=subInstances_.end(); ++instance)
        {
          entity << "class " << (*instance)->type_->getEntityName() << ";\n";
        }

      entity << "class " << entityName << " : public sc_core::sc_module\n"
        "{\n"
        "public:\n"
        "  " << entityName << "(sc_core::sc_module_name name);\n"
        "  ~" << entityName << "();\n"
        "  SC_HAS_PROCESS(" << entityName << ");\n";

      writeSystemCPorts(entity, ports, "", keepCase(), memberInits);
      entity << "private:\n";
      entity << type_->getDeclarationsTop() << "\n";
      for (ModuleInstanceList::const_iterator instance=subInstances_.begin();
           instance!=subInstances_.end(); ++instance)
        {
          entity << "  " << (*instance)->type_->getEntityName() << " * "
                 << (*instance)->instanceName_ << ";\n";
        }
      // Signals
      PortList signals = type_->getSignals();
      for (PortList::const_iterator sig=signals.begin(); sig!=signals.end();
           ++sig)
        {
          if ((*sig)->getName() != "open")
            {
              using namespace StringUtil;
              auto type = (*sig)->getType();
              if (contains("tlm_fifo_put_if", type) ||
                  contains("tlm_fifo_get_if", type))
                {
                  CaseAwareString::size_type typeStart = type.find('<') + 1;
                  CaseAwareString::size_type typeEnd   = type.rfind('>');

                  entity << "  tlm::tlm_fifo<"
                         << prependScDtIfNeeded(type.substr(typeStart,
                                                            typeEnd-typeStart).strip())
                         << " > "
                         << (*sig)->getName() << ";\n";
                }
              else
                {
                  entity << "  sc_core::sc_signal<"
                         << prependScDtIfNeeded((*sig)->getType()) << " > "
                         << (*sig)->getName() << ";\n";
                }
            }
        }

      // User declarations
      entity << type_->getDeclarations() << "\n";

      for (ScMethodArray::const_iterator method=scMethods.begin();
           method!=scMethods.end(); ++method)
        {
          entity << method->declaration() << "\n";
        }

      entity << "};\n"
             << "\n#endif\n";
      entity.close();
    }

  // merge rtl contexts
  Context rtlContext = type_->getRtlContext();
  Context defaultContext;
  defaultContext.add(CaseAwareString(true, "systemc"),
                     "\"" + entityName + ".h\"", sourceLoc_);
  rtlContext.merge(defaultContext);
  Context subModuleHeaders;
  for (ModuleInstanceList::const_iterator instance=subInstances_.begin();
       instance!=subInstances_.end(); ++instance)
    {
      subModuleHeaders.add(CaseAwareString(true, "systemc"),
                           "\"" + (*instance)->type_->getEntityName() + ".h\"",
                           sourceLoc_);
    }
  rtlContext.merge(subModuleHeaders);

  filename = entityName.strCase() + ".C";
  SmartFile rtl(filename);
  if (getFileHeader()) {
    getFileHeader()->setVar("designunit", "SystemC implementation");
    getFileHeader()->setVar("fname", filename);
    rtl << getFileHeader()->stream();
  }
  writeGeneratedBlock(rtl, CaseAwareString(keepCase(), "//"),
                      argv, ariFile, inputFiles);
  rtl << rtlContext.getSystemCText();

  rtl << entityName << "::" << entityName << "(sc_core::sc_module_name name)\n"
      << "  : sc_core::sc_module(name),\n";
  PortList signals = type_->getSignals();
  for (PortList::const_iterator sig=signals.begin(); sig!=signals.end();
       ++sig)
    {
      if ((*sig)->getName() != "open")
        memberInits.push_back((*sig)->getName() + "(\"" + (*sig)->getName() +
                              "\")");
    }
  if (!memberInits.empty())
    rtl << "    " << join(",\n    ", memberInits) << "\n";
  rtl << "{\n";

  for (ModuleInstanceList::const_iterator instance=subInstances_.begin();
       instance!=subInstances_.end(); ++instance)
    {
      rtl << type_->getCreateForInstance((*instance)->instanceName_,
                                         (*instance)->type_->getEntityName());
      Module::XrfList xrfs =
        type_->getXrfsForInstance((*instance)->instanceName_, true);
      if (!xrfs.empty())
        {
          for (Module::XrfList::const_iterator xrf=xrfs.begin();
               xrf!=xrfs.end(); ++xrf)
            {
              std::string childName;
              std::string parentName;
              childName = xrf->getChild()->getName().str();
              if (type_->keepCase())
                {
                  parentName = xrf->getParent()->getName().str();
                }
              else
                {
                  parentName = xrf->getParent()->getName().strLower();
                }
              rtl << "  " << (*instance)->instanceName_ << "->" << childName
                  << "(" << parentName << ");\n";
            }
        }
    }
  // User statements
  rtl << type_->getStatements() << "\n";

  for (ScMethodArray::const_iterator method=scMethods.begin();
       method!=scMethods.end(); ++method)
    {
      rtl << method->constructor() << "\n";
    }

  rtl << "}\n\n"
      << entityName << "::~" << entityName << "()\n"
      << "{\n";
  for (ModuleInstanceList::const_iterator instance=subInstances_.begin();
       instance!=subInstances_.end(); ++instance)
    {
      rtl << "  delete " << (*instance)->getInstanceName() << ";\n";
      rtl << "  " << (*instance)->getInstanceName() << " = 0;\n";
    }
  rtl << "}\n\n";

  for (ScMethodArray::const_iterator method=scMethods.begin();
       method!=scMethods.end(); ++method)
    {
      rtl << method->implementation(entityName.strCase()) << "\n";
    }

  rtl << "SC_MODULE_EXPORT(" << entityName << ");\n";
}

void ModuleInstance::generateVerilog(const StringUtil::stringlist & argv,
                                     const std::string & ariFile,
                                     const StringUtil::stringlist & inputFiles)
{
  AriOptions * ariOptions = AriOptions::getInstance();

  CaseAwareString entityName = type_->getEntityName();
  std::string filename = entityName.strCase() + ".v";
  PortList ports = type_->getPorts();
  GenericList generics = type_->getGenerics();
  if (ariOptions->entitiesCastInStone)
    {
      verifyExistingEntity(filename);
    }

  SmartFile module(filename.c_str());

  if (getFileHeader()) {
    getFileHeader()->setVar("designunit", "Verilog implementation");
    getFileHeader()->setVar("fname", filename);
    module << getFileHeader()->stream();
  }
  writeGeneratedBlock(module, CaseAwareString(keepCase(), "//"),
                      argv, ariFile, inputFiles);

  Context context = getContext();
  module << context.getVerilogText();

  module << "module " << entityName << "\n";
  if (!generics.empty())
    {
      CaseAwareStringList parameters;
      module << "  #(\n";
      auto sortedGenerics = generics;
      std::sort(sortedGenerics.begin(), sortedGenerics.end(),
                [] (ConstGeneric * p1, ConstGeneric * p2)
                {
                  return p1->getPortOrder() < p2->getPortOrder();
                });
      for (auto generic : sortedGenerics)
        {
          CaseAwareString parameter(keepCase(), "    parameter ");
          parameter += generic->getName();
          auto defaultValue = generic->getValue();
          if (!defaultValue.empty())
            parameter += " = " + defaultValue;
          parameters.push_back(parameter);
        }
      module << join(",\n", parameters);
      module << "\n  )\n";
    }

  if (!ports.empty())
    {
      module << "  (\n";
      typedef std::map<CaseAwareString, PortList> PortGroups;
      PortGroups portGroups;
      unsigned int numPorts = 0;
      // List of (group comment, smallest port order)
      typedef std::pair<CaseAwareString,int> CommentWithOrder;
      std::vector<CommentWithOrder> sortedGroups;
      for (PortList::const_iterator port=ports.begin(); port!=ports.end();
           ++port)
        {
          CaseAwareString groupComment = (*port)->getGroupComment();
          formatComment(groupComment, CaseAwareString(keepCase(), "   /// "));
          portGroups[groupComment].push_back(*port);
          ++numPorts;
        }
      // Sort port groups based on the smallest port order in the group
      for (auto portGroup : portGroups)
        {
          int smallest_order =
            (*std::min_element(portGroup.second.begin(),
                             portGroup.second.end(),
                             [](SignalPort * p1, SignalPort * p2)
                             {
                               return p1->getPortOrder() < p2->getPortOrder();
                             }))->getPortOrder();
          sortedGroups.push_back({portGroup.first,smallest_order});
        }
      std::sort(sortedGroups.begin(), sortedGroups.end(),
                [](CommentWithOrder const & group1,
                   CommentWithOrder const & group2)
                {
                  // .second is port order
                  return group1.second < group2.second;
                });

      StringUtil::stringlist portNames;
      unsigned int portNum = 1;
      for (auto sortGroup : sortedGroups)
        {
          auto portGroup = portGroups.find(sortGroup.first);
          if (portGroup == portGroups.end())
            throw AriException(EX_INTERNAL_ERROR, "Port group not found");
          if (!portGroup->first.empty())
            module << "\n" << portGroup->first << "\n";

          PortList sortedPorts = portGroup->second;
          std::sort(sortedPorts.begin(), sortedPorts.end(),
                    [] (SignalPort * p1, SignalPort * p2)
                    {
                      return p1->getPortOrder() < p2->getPortOrder();
                    });
          for (auto port : sortedPorts)
            {
              CaseAwareString portString(keepCase(), "   ");
              CaseAwareString portComment = port->getPortComment();
              if (!portComment.empty())
                {
                  formatComment(portComment,
                                CaseAwareString(keepCase(), "//// "));
                  portString += portComment + "\n   ";
                }
              if (port->getDirection() == "inout")
                portString += "inout ";
              else
                portString += port->getDirection() + "put ";
              if (port->getType() == "real")
                portString += "wreal ";
              CaseAwareString width = port->getWidthMin1();
              CaseAwareString portName;
              if (type_->keepCase())
                portName = port->getNameOrigCase();
              else
                portName = port->getName();
              if (width == "0")
                portString += portName;
              else
                {
                  CaseAwareString leftRange = port->getLeftRange();
                  CaseAwareString rightRange = port->getRightRange();
                  portString += "[" + leftRange + ":" + rightRange + "] " +
                                portName;
                }
              module << portString;

              bool isLastPort = portNum == numPorts;
              if (!isLastPort)
                module << ",";
              module << "\n";
              ++portNum;
            }
        }
      module << "  )";
    }
  module << ";\n\n";

  // User declarations to go at the top of the file
  // e.g. type declarations for signals that are defined in the .ari file
  module << type_->getDeclarationsTop() << "\n";

  // Signals
  PortList signals = type_->getSignals();
  for (PortList::const_iterator sig=signals.begin(); sig!=signals.end(); ++sig)
    {
      if ((*sig)->getName() != "open")
        {
          if ((*sig)->getType() == "real")
            module << "wreal ";
          else
            module << "wire ";
          CaseAwareString width = (*sig)->getWidthMin1();
          std::string sigName;
          if (type_->keepCase())
            sigName = (*sig)->getName().str();
          else
            sigName = (*sig)->getName().strLower();
          if (width == "0")
            module << sigName <<";\n";
          else
            {
              CaseAwareString leftRange = (*sig)->getLeftRange();
              CaseAwareString rightRange = (*sig)->getRightRange();
              module << "[" << leftRange << ":" << rightRange << "] " <<
                        sigName <<";\n";
            }
        }
    }
  module << "\n";

  // User declarations
  module << type_->getDeclarations() << "\n";

  // merge rtl contexts
  for (ModuleInstanceList::const_iterator instance=subInstances_.begin();
       instance!=subInstances_.end(); ++instance)
    {
      CaseAwareString instComment =
        type_->getInstComment((*instance)->instanceName_);
      formatComment(instComment, CaseAwareString(keepCase(), "  // "));
      if (!instComment.empty())
        module << instComment << "\n";
      module << "  " << (*instance)->type_->getEntityName();
      Module::XrfList xrfs =
        type_->getXrfsForInstance((*instance)->instanceName_, false);
      Module::AssignList assigns =
        type_->getAssignsForInstance((*instance)->instanceName_, false);
      if (!xrfs.empty() || !assigns.empty())
        {
          module << "\n    #(\n      ";
          CaseAwareStringList lines;
          for (Module::XrfList::const_iterator xrf=xrfs.begin();
               xrf!=xrfs.end(); ++xrf)
            {
              // Verilog does not allow a range on the left hand side of the
              // port map
              lines.push_back("." + xrf->getChild()->getName() + "(" +
                              rangeToVerilog(xrf->getParent()->getName()) +
                              ")");
            }
          for (Module::AssignList::const_iterator assign=assigns.begin();
               assign!=assigns.end(); ++assign)
            {
              lines.push_back("." + assign->getChild()->getName() +
                              "(" + assign->getValue() + ")");
            }
          module << join(",\n      ", lines);
          module << "\n    )\n  ";
        }
      else
        module << " ";
      module << (*instance)->instanceName_ << "\n";

      xrfs = type_->getXrfsForInstance((*instance)->instanceName_, true);
      assigns = type_->getAssignsForInstance((*instance)->instanceName_, true);
      if (!xrfs.empty() || !assigns.empty())
        {
          module << "    (\n     ";
          StringUtil::stringlist lines;
          for (Module::XrfList::const_iterator xrf=xrfs.begin();
               xrf!=xrfs.end(); ++xrf)
            {
              std::string childName;
              std::string parentName;
              parentName = rangeToVerilog(xrf->getParent()->getName()).str();
              if ((*instance)->type_->keepCase())
                childName = xrf->getChild()->getName().str();
              else
                childName = xrf->getChild()->getName().strLower();
              // verilog does not have an open keyword, you just leave out the
              // second part to make an explicitly unconnected port
              if (parentName == "open")
                parentName.clear();
              lines.push_back("." + childName + "(" + parentName + ")");
            }
          for (Module::AssignList::const_iterator assign=assigns.begin();
               assign!=assigns.end(); ++assign)
            {
              lines.push_back("." + assign->getChild()->getName().str() + "(" +
                              assign->getValue().str() + ")");
            }
          module << StringUtil::join(",\n     ", lines);
          module << "\n    )";
        }
      module << ";\n";
    }
  // User statements
  module << type_->getStatements() << "\n";

  module << "\nendmodule\n";
}

bool ModuleInstance::isScDt(const CaseAwareString & type) const
{
  return type.substr(0, 5) == "sc_lv" ||
         type.substr(0, 5) == "sc_bv" ||
         type.substr(0, 8) == "sc_logic" ||
         type.substr(0, 6) == "sc_int" ||
         type.substr(0, 7) == "sc_uint" ||
         type.substr(0, 9) == "sc_bigint" ||
         type.substr(0, 10) == "sc_biguint" ||
         type.substr(0, 9) == "sc_signed" ||
         type.substr(0, 11) == "sc_unsigned";
}

CaseAwareString ModuleInstance::prependScDtIfNeeded(const CaseAwareString & type) const
{
  CaseAwareString strippedType = type.strip();
  if (isScDt(strippedType))
    return "sc_dt::" + strippedType;
  else
    return strippedType;
}

void ModuleInstance::verifyExistingEntity(const std::string & filename)
{
  CaseAwareString entityName = type_->getEntityName();
  PortList ports = type_->getPorts();

  Module existingEntity(entityName);
  existingEntity.loadFromFile(filename, sourceLoc_);
  PortList existingPorts = existingEntity.getPorts();

  PortList onlyInNewPorts;
  PortList onlyInExistingPorts;
  using namespace StringUtil;
  for (auto existingPort=existingPorts.begin();
       existingPort!=existingPorts.end(); ++existingPort)
    {
      bool foundIt = false;
      for (auto port=ports.begin(); port!=ports.end(); ++port)
        {
          if (((*existingPort)->getName() == (*port)->getName()) &&
              ((*existingPort)->getType().removeSpaces() ==
               (*port)->getType().removeSpaces()))
            {
              foundIt = true;
              break;
            }
        }
      if (!foundIt)
        onlyInExistingPorts.push_back(*existingPort);
    }
  for (auto port=ports.begin(); port!=ports.end(); ++port)
    {
      bool foundIt = false;
      for (auto existingPort=existingPorts.begin();
           existingPort!=existingPorts.end(); ++existingPort)
        {
          if (((*existingPort)->getName() == (*port)->getName()) &&
              ((*existingPort)->getType().removeSpaces() ==
               (*port)->getType().removeSpaces()))
            {
              foundIt = true;
              break;
            }
        }
      if (!foundIt)
        onlyInNewPorts.push_back(*port);
    }
  std::ostringstream message;
  if (!onlyInExistingPorts.empty())
    {
      message << "Existing entity has more ports\n";
      for (auto port=onlyInExistingPorts.begin();
           port!=onlyInExistingPorts.end(); ++port)
        {
          message << "  " << (*port)->getName() << " : " << (*port)->getType()
            << "\n";
        }
    }
  if (!onlyInNewPorts.empty())
    {
      message << "New entity has more ports\n";
      for (auto port=onlyInNewPorts.begin(); port!=onlyInNewPorts.end(); ++port)
        {
          message << "  " << (*port)->getName() << " : " << (*port)->getType()
            << "\n";
        }
    }

  GenericList generics = type_->getGenerics();
  GenericList existingGenerics = existingEntity.getGenerics();
  GenericList onlyInNewGenerics;
  GenericList onlyInExistingGenerics;
  using namespace StringUtil;
  for (auto existingGeneric=existingGenerics.begin();
       existingGeneric!=existingGenerics.end(); ++existingGeneric)
    {
      bool foundIt = false;
      for (auto generic=generics.begin(); generic!=generics.end(); ++generic)
        {
          if (((*existingGeneric)->getName() == (*generic)->getName()) &&
              ((*existingGeneric)->getType().removeSpaces() ==
               (*generic)->getType().removeSpaces()))
            {
              foundIt = true;
              break;
            }
        }
      if (!foundIt)
        onlyInExistingGenerics.push_back(*existingGeneric);
    }
  for (auto generic=generics.begin(); generic!=generics.end(); ++generic)
    {
      bool foundIt = false;
      for (auto existingGeneric=existingGenerics.begin();
           existingGeneric!=existingGenerics.end(); ++existingGeneric)
        {
          if (((*existingGeneric)->getName() == (*generic)->getName()) &&
              ((*existingGeneric)->getType().removeSpaces() ==
               (*generic)->getType().removeSpaces()))
            {
              foundIt = true;
              break;
            }
        }
      if (!foundIt)
        onlyInNewGenerics.push_back(*generic);
    }
  if (!onlyInExistingGenerics.empty())
    {
      message << "Existing entity has more generics\n";
      for (auto generic=onlyInExistingGenerics.begin();
           generic!=onlyInExistingGenerics.end(); ++generic)
        {
          message << "  " << (*generic)->getName() << " : " << (*generic)->getType()
            << "\n";
        }
    }
  if (!onlyInNewGenerics.empty())
    {
      message << "New entity has more generics\n";
      for (auto generic=onlyInNewGenerics.begin();
           generic!=onlyInNewGenerics.end(); ++generic)
        {
          message << "  " << (*generic)->getName() << " : " << (*generic)->getType()
            << "\n";
        }
    }
  if (!message.str().empty())
    throw AriException(EX_MORE_PORTS_CHECK, filename, message.str());
}

void ModuleInstance::formatComment(CaseAwareString & comment,
                                   const CaseAwareString & linePrefix) const
{
  if (comment.empty())
    return;
  CaseAwareStringList lines = StringUtil::split(comment, '\n');
  for (auto & line : lines)
    line = line.strip();
  comment = linePrefix + join("\n" + linePrefix, lines);
}


FileHeader * ModuleInstance::getFileHeader() const
{
  FileHeader * header = AriOptions::getInstance()->getFileHeader();
  if (!header)
    {
      header = type_->getFileHeader();
    }
  return header;
}

void ModuleInstance::updateGenericRenames(const CaseAwareString & lhsName,
                                          const CaseAwareString & instanceName,
                                          const CaseAwareString & rhsName)
{
  ModuleInstance * instance = getSubInstance(instanceName);
  if (instance == nullptr)
    {
      // Throw exception: Sourceloc undefined as the ruby will catch it
      // and throw its own with the right sourceloc
      throw AriException(EX_NO_SUCH_INSTANCE, type_->getEntityName().str(),
                         instanceName.str(), 0);
    }

  ConstGeneric * subConstGeneric = instance->type_->getConstGeneric(rhsName);

  if (subConstGeneric)
    {
      if (!subConstGeneric->isConstant())
        {
          generic_rename_info rename;
          rename.origname = rhsName;
          rename.newname = lhsName;
          genericRenames_[instanceName].push_back(rename);
        }
    }
}

CaseAwareString ModuleInstance::rangeToVerilog(const CaseAwareString & name) const
{
  // Transform the VHDL range to the Verilog equivalent
  const std::string::size_type rangeBeginIndex = name.find_first_of("(");

  if (rangeBeginIndex == std::string::npos) {return name;}

  const CaseAwareString baseName = name.substr(0, rangeBeginIndex);

  CaseAwareString range = name.substr(rangeBeginIndex);
  range.replace("(", "[", 1);
  StringUtil::rreplace(')', "]", range, 1);
  range.replace(" downto ", ":");

  return baseName + range;
}

std::ostream & operator<<(std::ostream & str, ModuleInstance & instance)
{
  instance.print(str);
  return str;
}
