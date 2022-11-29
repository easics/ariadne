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

#ifndef Module_h_
#define Module_h_

#include "Xrf.h"
#include "Assign.h"
#include "Context.h"
#include "cvector.h"
#include "StringUtil.h"
#include "ScMethod.h"
#include "SourceLoc.h"
#include "CaseAwareString.h"
#include <map>
#include <string>
#include <utility>
#include <vector>
#include <list>

class SignalPort;
class ConstGeneric;
class ModuleInstance;
class XrfBase;
class FileHeader;
class NamingRules;

class Module
{
public:
  typedef cvector<SignalPort*> PortList;
  typedef cvector<ConstGeneric*> ConstList;
  typedef cvector<Xrf> XrfList;
  typedef cvector<Assign> AssignList;
  struct UserXrf
    {
      UserXrf(const CaseAwareString & first, const CaseAwareString & second,
              SourceLoc loc)
        : first(first), second(second), loc(loc) {}
      CaseAwareString first;
      CaseAwareString second;
      SourceLoc loc;
    };
  typedef cvector<UserXrf> UserXrfList;
  // List of cross references per child instance written in the dsc file
  typedef std::map<CaseAwareString, UserXrfList> UserXrfMap;
  // List of create blocks
  struct CreateBlock
    {
      CaseAwareString code;
      SourceLoc loc;
    };
  typedef std::map<CaseAwareString, CreateBlock> CreateList;

  struct SubConfigInfo
    {
      SubConfigInfo() : loc(0) {}
      SubConfigInfo(const CaseAwareString & name, SourceLoc loc)
        : name(name), loc(loc) {}
      CaseAwareString name;
      SourceLoc loc;
    };
  struct SubArchInfo
    {
      SubArchInfo() : loc(0) {}
      SubArchInfo(const CaseAwareString & name, SourceLoc loc)
        : name(name), loc(loc) {}
      CaseAwareString name;
      SourceLoc loc;
    };
  struct ConfigurationInfo
    {
      // name of the configuration
      CaseAwareString name;
      // map of <subinstancename, subconfigurationname>
      std::map<CaseAwareString, SubConfigInfo> subconfigs;
      // map of <subinstancename, subarchitecturename>
      std::map<CaseAwareString, SubArchInfo> subarchs;
    };
  typedef cvector<ConfigurationInfo> ConfigurationList;
  // List of portname renames per child instance
  struct PortRename
    {
      PortRename(const CaseAwareString & match,
                 const CaseAwareString & first,
                 const CaseAwareString & second,
                 SourceLoc loc) : match(match), first(first), second(second),
                                  loc(loc) {}
      CaseAwareString match; // only change ports matching this regexp
      CaseAwareString first; // original name
      CaseAwareString second; // new name
      SourceLoc loc;
    };
  typedef std::map<CaseAwareString, cvector<PortRename> > PortRenameMap;

  enum Language { LANGUAGE_VHDL, LANGUAGE_SYSTEMC, LANGUAGE_VERILOG };

  Module(const CaseAwareString & entityName);
  ~Module();

  void loadFromFile(const std::string & filename, SourceLoc loc);
  void parsedIt();
  const CaseAwareString & getEntityName() const;
  void setEntityName(const CaseAwareString & name); // name with the correct case

  void addSignalPort(SignalPort * sigPort);
  void addConstGeneric(ConstGeneric * constGeneric);
  void addPort(const CaseAwareString & name, const CaseAwareString & direction,
               const CaseAwareString & type, const CaseAwareString & groupComment,
               SourceLoc loc);
  void addSignal(const CaseAwareString & name, const CaseAwareString & type,
                 SourceLoc loc);
  void addConstant(const CaseAwareString & name, const CaseAwareString & type,
                   const CaseAwareString & value,
                   SourceLoc loc);
  void addGeneric(const CaseAwareString & name, const CaseAwareString & type,
                  const CaseAwareString & value,
                  SourceLoc loc);
  void addStatements(const CaseAwareString & statements, SourceLoc loc);
  void addDeclarations(const CaseAwareString & declarations, SourceLoc loc);
  void addDeclarationsTop(const CaseAwareString & declarations, SourceLoc loc);
  void addConfiguration(const ConfigurationInfo & configInfo, SourceLoc loc);
  void setLibrary(const CaseAwareString & name);
  void setArchitecture(const CaseAwareString & name);
  void setContext(const Context & context);
  void removePackage(const CaseAwareString & library, const CaseAwareString & package);
  void movePackage(const CaseAwareString & library,
                   const CaseAwareString & package, SourceLoc loc=0);
  void addPackage(const CaseAwareString & library,
                  const CaseAwareString & package, SourceLoc loc=0);
  void addComponentPackage(const CaseAwareString & library,
                           const CaseAwareString & package, SourceLoc loc=0);
  bool haveComponentPackage();
  void execScript(const std::string & script);
  void setSource(const std::string & source, SourceLoc loc);
  void addXrf(XrfBase * parent, XrfBase * child, const CaseAwareString & childName);
  void addAssign(const CaseAwareString & value, XrfBase * child,
                 const CaseAwareString & childName);
  void addUserXrf(const CaseAwareString & lhsName, const CaseAwareString & instance,
                  const CaseAwareString & rhsName, SourceLoc loc);
  void removeUserXrf(const CaseAwareString & instance,
                     const CaseAwareString & rhsName,
                     SourceLoc loc);
  void addUserAssign(const CaseAwareString & value, const CaseAwareString & instance,
                     const CaseAwareString & rhsName, SourceLoc loc);
  void addRenamePorts(const CaseAwareString & instanceName,
                      const CaseAwareString & match,
                      const CaseAwareString & from,
                      const CaseAwareString & to,
                      SourceLoc loc);
  void addGroupComment(const CaseAwareString & port,
                       const CaseAwareString & groupComment);
  void addPortComment(const CaseAwareString & port,
                      const CaseAwareString & portComment);
  void addEntityComment(const CaseAwareString & comment);
  void addArchComment(const CaseAwareString & comment);
  void addInstComment(const CaseAwareString & instanceName,
                      const CaseAwareString & comment);
  void applyGroupComments();
  Context getContext() const;
  Context getRemoveContext() const;
  Context getRtlContext() const;
  Context getEntityContext() const;
  bool isGenerated() const;
  void setGenerated();
  bool haveSource() const;
  XrfList getXrfsForInstance(const CaseAwareString & instanceName,
                             bool portsNotGenerics) const;
  AssignList getAssignsForInstance(const CaseAwareString & instanceName,
                                   bool portsNotGenerics) const;
  const PortRenameMap & getPortRenames() const;

  ModuleInstance * makeInstance(const CaseAwareString & instanceName,
                                SourceLoc loc);

  PortList getPorts() const;
  PortList getSignals() const;
  ConstList getConstants() const;
  ConstList getGenerics() const;
  SignalPort * getSignalPort(const CaseAwareString & name,
                             NamingRules * namingRules = nullptr) const;
  ConstGeneric * getConstGeneric(const CaseAwareString & name) const;
  CaseAwareString getDeclarations() const;
  CaseAwareString getDeclarationsTop() const;
  CaseAwareString getStatements() const;
  bool haveUserXrf(const CaseAwareString & instanceName,
                   const CaseAwareString & portName) const;
  UserXrf getUserXrf(const CaseAwareString & instanceName,
                     const CaseAwareString & portName) const;
  bool haveUserXrf(const CaseAwareString & sigPortName) const;
  UserXrfList getUserXrfsForInstance(const CaseAwareString & instanceName) const;
  UserXrfList getUserAssignsForInstance(const CaseAwareString & instanceName) const;
  UserXrfMap getUserXrfs() const;
  UserXrfMap getUserAssigns() const;
  CaseAwareString getLibrary() const;
  bool isLibrarySpecifiedInAri() const;
  CaseAwareString getArchitecture() const;
  ConfigurationList getConfigurations() const;

  void renameSignalPortTypes(const CaseAwareString & oldName,
                             const CaseAwareString & newName);
  void setKeepCase() { keepCase_ = true; }
  bool keepCase() const { return keepCase_; }

  Language getLanguage() const;
  void setLanguage(Language language);

  void addCreate(const CaseAwareString & instance,
                 const CaseAwareString & createCode,
                 SourceLoc loc);
  const CreateList & getCreateBlocks() const;
  std::string getCreateForInstance(const CaseAwareString & instance,
                                   const CaseAwareString & type) const;

  void setPostExecScript(const std::string & script);
  std::list<std::string> getPostExecScripts() const;

  void addScMethod(const ScMethod & method);
  const ScMethodArray & getScMethods() const;

  CaseAwareString getUniqueSignalName(const CaseAwareString & base) const;

  void changeUserXrf(const CaseAwareString & originalName,
                     const CaseAwareString & newName);

  CaseAwareString getEntityComment() const;
  CaseAwareString getArchComment() const;
  CaseAwareString getInstComment(const CaseAwareString & instanceName) const;

  // Configuration inside cfg file or inline in architecture
  void setConfigInArch(bool how);
  bool isConfigInArch() const;

  void setFileHeader(FileHeader * header);
  FileHeader * getFileHeader() const;

  static bool regenerateEntities_;

private:
  typedef std::map<CaseAwareString, SignalPort*> SignalPortList;
  typedef std::map<CaseAwareString, ConstGeneric*> ConstGenericList;
  // List of cross references per child instance
  typedef std::map<CaseAwareString, XrfList> XrfMap;
  // List of assigns per child instance
  typedef std::map<CaseAwareString, AssignList> AssignMap;
  typedef std::map<CaseAwareString, CaseAwareString> GroupCommentList;

  void assertGenerated(const std::string & function, SourceLoc loc) const;
  void assertNotGenerated(const std::string & function, SourceLoc loc) const;

  CaseAwareString entityName_;
  // true if the parser found an entity with the correct name
  bool parsedIt_;
  SignalPortList signalPorts_;
  ConstGenericList constGenerics_;
  Context context_;
  Context removeContext_;
  Context rtlContext_;
  Context entityContext_;

  bool isGenerated_;
  CaseAwareString architecture_;
  CaseAwareString library_;
  bool isLibrarySpecifiedInAri_;
  ConfigurationList configurations_;
  CaseAwareString declarations_;
  CaseAwareString declarationsTop_;
  CaseAwareString statements_;

  XrfMap xrfs_;
  AssignMap assigns_;
  UserXrfMap userXrfs_;
  UserXrfMap userAssigns_;
  bool haveComponentPackage_;
  PortRenameMap portRenames_;
  GroupCommentList groupComments_;
  GroupCommentList portComments_;
  bool keepCase_;

  Language sourceLanguage_;

  CreateList creates_;

  std::list<std::string> postExecScripts_;

  ScMethodArray scMethods_;

  CaseAwareString entityComment_;
  CaseAwareString archComment_;
  GroupCommentList instComment_;

  bool haveExec_;
  bool configInArch_;

  FileHeader * fileHeader_;
};

#endif
