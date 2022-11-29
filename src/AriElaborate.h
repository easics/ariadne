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

#ifndef AriElaborate_h_
#define AriElaborate_h_

#include "ASTTraversalariFile.h"
#include "cvector.h"
#include "StringUtil.h"
#include "CaseAwareString.h"
#include <map>
#include <set>

class ModuleInstance;
class Module;

class AriElaborate : public ASTTraversalariFile
{
public:
  AriElaborate(const std::string & filename);
  ~AriElaborate();

  void hierarchy(AST & node);
  void hierarchy_exit(AST & node);
  void module(AST & node);
  void module_exit(AST & node);
  void info(AST & node);
  void info_exit(AST & node);
  void port(AST & node);
  void tln_from(AST & node);
  void xrf(AST & node);
  void xrfp(AST & node);
  void library(AST & node);
  void generic(AST & node);
  void signal(AST & node);
  void constant(AST & node);
  void configuration(AST & node);
  void architecture(AST & node);
  void statements(AST & node);
  void declarations(AST & node);
  void declarationstop(AST & node);
  void remove_package(AST & node);
  void add_package(AST & node);
  void move_package(AST & node);
  void add_header(AST & node);
  void move_header(AST & node);
  void remove_header(AST & node);
  void exec_script(AST & node);
  void assign(AST & node);
  void component(AST & node);
  void rename_ports(AST & node);
  void group_comment(AST & node);
  void port_comment(AST & node);
  void keep_case(AST & node);
  void language(AST & node);
  void create(AST & node);
  void post_exec_script(AST & node);
  void rubycode(AST & node);
  void pythoncode(AST & node);
  void sc_method(AST & node);
  void sc_thread(AST & node);
  void rubypostcode(AST & node);
  void pythonpostcode(AST & node);
  void entity_comment(AST & node);
  void arch_comment(AST & node);
  void inst_comment(AST & node);
  void config_in_arch(AST & node);
  void fileheader(AST & node);

  // Search for entities that don't have a 'from' statement
  void searchMissingFrom();

  void addIncludedFiles(std::set<std::string> const & files);
  // Use the 'tln rules' to connect all ports
  void resolve();
  // Write out vhdl files
  void generate(const StringUtil::stringlist & argv);

  // Query why packages were included
  void queryPackages() const;

  void print();

private:
  typedef std::map<CaseAwareString, Module*> ModuleMap;

  // Get the module (type) with the designated name.
  // If the module does not exists, create it.
  Module * getModule(const CaseAwareString & name);

  // convert to lowercase, remove all spaces
  CaseAwareString normalizeNoWhiteString(const CaseAwareString & s);

  bool keepCase_;
  const std::string filename_;
  ModuleInstance * hierarchy_;
  cvector<ModuleInstance*> currentModuleInstanceStack_;
  ModuleMap modules_;
  Module * currentInfoModule_;
  StringUtil::stringlist rubycodes_;
  StringUtil::stringlist rubypostcodes_;
  StringUtil::stringlist pythoncodes_;
  StringUtil::stringlist pythonpostcodes_;
  StringUtil::stringlist inputFiles_;
};

#endif
