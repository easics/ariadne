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

#ifndef ModuleInstance_h_
#define ModuleInstance_h_

#include "ScriptAccess.h"
#include "Xrf.h"
#include "cvector.h"
#include "Context.h"
#include "Module.h"
#include "SourceLoc.h"
#include "VmaSearchInfo.h"
#include <string>
#include <vector>
#include <iostream>
#include <map>

class XrfBase;
class SignalPort;
class ConstGeneric;
class SmartFile;
class NamingRules;

struct RubyXrf : public ScriptAccess
{
  CaseAwareString signalName;
  CaseAwareString childPortName;
};

class ModuleInstance : public ScriptAccess
{
public:
  typedef std::vector<ModuleInstance *> ModuleInstanceList;
  typedef std::vector<SignalPort*> PortList;
  typedef std::vector<ConstGeneric*> GenericList;
  typedef std::vector<RubyXrf*> RubyXrfList;

  ModuleInstance(const CaseAwareString & instanceName, Module * type,
                 SourceLoc loc);
  ~ModuleInstance();

  void addSubInstance(ModuleInstance * subInstance);

  void print(std::ostream & str, unsigned int indent = 0) const;

  // Check if we need to search for entities
  bool haveMissingFrom() const;
  // Search for entities that don't have a 'from' statement
  StringUtil::stringlist searchMissingFrom(const VmaSearchInfo & searchInfo);

  void verify();
  // make signal/port connection according to the tln rules
  void resolve();
  // Generate code
  void generate(const StringUtil::stringlist & argv,
                const std::string & ariFile,
                const StringUtil::stringlist & inputFiles);
  // Query why packages were included
  void queryPackages() const;

  // For our Ruby friends
  ModuleInstanceList getSubInstances() const;
  ModuleInstance * getSubInstance(const CaseAwareString & instanceName) const;
  CaseAwareString getInstanceName() const;
  PortList getPorts() const         { return type_->getPorts(); }
  PortList getSignals() const       { return type_->getSignals(); }
  CaseAwareString getEntityName() const { return type_->getEntityName(); }
  void addPort(const CaseAwareString & name,
               const CaseAwareString & direction,
               const CaseAwareString & type,
               const CaseAwareString & groupComment)
    { type_->addPort(name, direction, type, groupComment, 0); }
  void addSignal(const CaseAwareString & name, const CaseAwareString & type)
    { type_->addSignal(name, type, 0); }
  void addConstant(const CaseAwareString & name, const CaseAwareString & type,
                   const CaseAwareString & value)
    { type_->addConstant(name, type, value, 0); }
  void addGeneric(const CaseAwareString & name, const CaseAwareString & type,
                  const CaseAwareString & value)
    { type_->addGeneric(name, type, value, 0); }
  void addStatements(const CaseAwareString & statements)
    { type_->addStatements(statements, 0); }
  void addDeclarations(const CaseAwareString & declarations)
    { type_->addDeclarations(declarations, 0); }
  void addDeclarationsTop(const CaseAwareString & declarations)
    { type_->addDeclarationsTop(declarations, 0); }
  void addUserXrf(const CaseAwareString & lhsName,
                  const CaseAwareString & instance,
                  const CaseAwareString & rhsName)
    { type_->addUserXrf(lhsName, instance, rhsName, 0);
      updateGenericRenames(lhsName, instance, rhsName); }
  void removeUserXrf(const CaseAwareString & instance,
                     const CaseAwareString & rhsName)
    { type_->removeUserXrf(instance, rhsName, 0); }
  void addUserAssign(const CaseAwareString & lhsName,
                     const CaseAwareString & instance,
                     const CaseAwareString & rhsName)
    { type_->addUserAssign(lhsName, instance, rhsName, 0);
      updateGenericRenames(lhsName, instance, rhsName); }
  void addRenamePorts(const CaseAwareString & instanceName,
                      const CaseAwareString & from,
                      const CaseAwareString & to)
    { type_->addRenamePorts(instanceName, CaseAwareString(), from, to, 0); }
  void addGroupComment(const CaseAwareString & port,
                       const CaseAwareString & groupComment)
    { type_->addGroupComment(port, groupComment); }
  void addPortComment(const CaseAwareString & port,
                      const CaseAwareString & portComment)
    { type_->addPortComment(port, portComment); }
  void addEntityComment(const CaseAwareString & comment)
    { type_->addEntityComment(comment); }
  void addArchComment(const CaseAwareString & comment)
    { type_->addArchComment(comment); }
  void removePackage(const CaseAwareString & library,
                     const CaseAwareString & package)
    { type_->removePackage(library, package); }
  void movePackage(const CaseAwareString & library,
                   const CaseAwareString & package)
    { type_->movePackage(library, package); }
  void addPackage(const CaseAwareString & library,
                  const CaseAwareString & package)
    { type_->addPackage(library, package); }
  void addComponentPackage(const CaseAwareString & library,
                           const CaseAwareString & package)
    { type_->addComponentPackage(library, package); }
  bool haveUserXrf(const CaseAwareString & instanceName,
                   const CaseAwareString & portName) const
    { return type_->haveUserXrf(instanceName, portName); }
  void applyGroupComments() { type_->applyGroupComments(); }

  RubyXrfList getXrfs(const CaseAwareString & childInstanceName,
                      bool portsNotGenerics) const;
  RubyXrfList getUserXrfs(const CaseAwareString & childInstanceName) const;
  RubyXrfList getUserAssigns(const CaseAwareString & childInstanceName) const;
  // Collect all generic renames
  // A generic can get a new name/value by xrf or assign
  // Types that use this generic must also undergo the same renaming
  void collectGenericRenames();
  // Apply assigns and xrfs to generics in type names.
  // e.g. assign 3 : inst_0/g_width; this function will replace the string
  // g_dwidth with 3 in the argument type.
  CaseAwareString renameGenericInType(const CaseAwareString & instanceName,
                                      const CaseAwareString & type) const;

private:
  typedef std::map<CaseAwareString, CaseAwareString> UserAssigns;
  typedef std::map<CaseAwareString, UserAssigns > UserAssignsMap;
  struct generic_rename_info
    {
      CaseAwareString origname;
      CaseAwareString newname;
    };
  typedef std::vector<generic_rename_info> GenericRenameList;
  // generic rename per submodule
  typedef std::map<CaseAwareString, GenericRenameList> GenericRenames;
  // Child instance name and port pointer
  typedef std::pair<CaseAwareString, SignalPort*> NameAndPort;
  typedef std::vector<NameAndPort> NameAndPortList;

  void generateVhdl(const StringUtil::stringlist & argv,
                    const std::string & ariFile,
                    const StringUtil::stringlist & inputFiles);
  void generateSystemC(const StringUtil::stringlist & argv,
                       const std::string & ariFile,
                       const StringUtil::stringlist & inputFiles);
  void generateVerilog(const StringUtil::stringlist & argv,
                       const std::string & ariFile,
                       const StringUtil::stringlist & inputFiles);
  void writePorts(SmartFile & file, const PortList & ports,
                  const std::string & indent,
                  bool keepCase);
  void writeSystemCPorts(SmartFile & file, const PortList & ports,
                         const std::string & indent,
                         bool keepCase,
                         CaseAwareStringList & memberInits);
  void writeGenerics(SmartFile & output, const GenericList & ports,
                     const std::string & indent,
                     bool keepCase);
  void writeGeneratedBlock(SmartFile & output,
                           const CaseAwareString & commentToken,
                           const StringUtil::stringlist & argv,
                           const std::string & ariFile,
                           const StringUtil::stringlist & inputFiles);
  Context getContext() const;
  void applyPortRename(const CaseAwareString & instanceName,
                       CaseAwareString & portName,
                       const CaseAwareString & direction);

  CaseAwareString findGroupComment(const NameAndPortList & ports) const;
  CaseAwareString findPortComment(const NameAndPortList & ports) const;
  bool isScDt(const CaseAwareString & type) const;
  CaseAwareString prependScDtIfNeeded(const CaseAwareString & type) const;

  void verifyExistingEntity(const std::string & filename);

  void formatComment(CaseAwareString & comment,
                     const CaseAwareString & linePrefix) const;

  FileHeader * getFileHeader() const;
  bool keepCase() const { return type_->keepCase(); }

  void updateGenericRenames(const CaseAwareString & lhsName,
                            const CaseAwareString & instanceName,
                            const CaseAwareString & rhsName);

  CaseAwareString rangeToVerilog(const CaseAwareString & name) const;

  const CaseAwareString instanceName_;
  Module * type_;
  ModuleInstanceList subInstances_;
  GenericRenames genericRenames_;

  NamingRules * namingRules_;

  SourceLoc sourceLoc_;
};

std::ostream & operator<<(std::ostream & str, ModuleInstance & instance);

#endif
