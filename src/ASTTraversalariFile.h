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

#ifndef ASTTraversalariFile_H_
#define ASTTraversalariFile_H_

#include "AST.h"

class ASTTraversalariFile
{
public:
  static AST ast;

  ASTTraversalariFile() {};
  virtual ~ASTTraversalariFile() {};
  void traverse();
  void print();

  virtual void syntax(AST & node) {}
  virtual void hierarchy(AST & node) {}
  virtual void module_list(AST & node) {}
  virtual void module(AST & node) {}
  virtual void opt_module_list(AST & node) {}
  virtual void info_list(AST & node) {}
  virtual void info(AST & node) {}
  virtual void opt_semicolon(AST & node) {}
  virtual void info_line_list(AST & node) {}
  virtual void info_line(AST & node) {}
  virtual void statements(AST & node) {}
  virtual void declarations(AST & node) {}
  virtual void declarationstop(AST & node) {}
  virtual void signal(AST & node) {}
  virtual void port(AST & node) {}
  virtual void opt_group_comment(AST & node) {}
  virtual void direction(AST & node) {}
  virtual void library(AST & node) {}
  virtual void configuration(AST & node) {}
  virtual void sub_configs(AST & node) {}
  virtual void sub_config(AST & node) {}
  virtual void architecture(AST & node) {}
  virtual void tln_from(AST & node) {}
  virtual void constant(AST & node) {}
  virtual void xrf(AST & node) {}
  virtual void componentports(AST & node) {}
  virtual void componentport(AST & node) {}
  virtual void selected_ident(AST & node) {}
  virtual void ident(AST & node) {}
  virtual void slice(AST & node) {}
  virtual void generic(AST & node) {}
  virtual void remove_package(AST & node) {}
  virtual void add_package(AST & node) {}
  virtual void move_package(AST & node) {}
  virtual void add_header(AST & node) {}
  virtual void move_header(AST & node) {}
  virtual void remove_header(AST & node) {}
  virtual void exec_script(AST & node) {}
  virtual void assign(AST & node) {}
  virtual void component(AST & node) {}
  virtual void rename_ports(AST & node) {}
  virtual void opt_match(AST & node) {}
  virtual void group_comment(AST & node) {}
  virtual void port_comment(AST & node) {}
  virtual void keep_case(AST & node) {}
  virtual void language(AST & node) {}
  virtual void create(AST & node) {}
  virtual void post_exec_script(AST & node) {}
  virtual void rubycode(AST & node) {}
  virtual void rubypostcode(AST & node) {}
  virtual void pythoncode(AST & node) {}
  virtual void pythonpostcode(AST & node) {}
  virtual void fileheader(AST & node) {}
  virtual void sc_method(AST & node) {}
  virtual void identifier_list(AST & node) {}
  virtual void xrfp(AST & node) {}
  virtual void entity_comment(AST & node) {}
  virtual void arch_comment(AST & node) {}
  virtual void inst_comment(AST & node) {}
  virtual void sc_thread(AST & node) {}
  virtual void config_in_arch(AST & node) {}

  virtual void syntax_exit(AST & node) {}
  virtual void hierarchy_exit(AST & node) {}
  virtual void module_list_exit(AST & node) {}
  virtual void module_exit(AST & node) {}
  virtual void opt_module_list_exit(AST & node) {}
  virtual void info_list_exit(AST & node) {}
  virtual void info_exit(AST & node) {}
  virtual void opt_semicolon_exit(AST & node) {}
  virtual void info_line_list_exit(AST & node) {}
  virtual void info_line_exit(AST & node) {}
  virtual void statements_exit(AST & node) {}
  virtual void declarations_exit(AST & node) {}
  virtual void declarationstop_exit(AST & node) {}
  virtual void signal_exit(AST & node) {}
  virtual void port_exit(AST & node) {}
  virtual void opt_group_comment_exit(AST & node) {}
  virtual void direction_exit(AST & node) {}
  virtual void library_exit(AST & node) {}
  virtual void configuration_exit(AST & node) {}
  virtual void sub_configs_exit(AST & node) {}
  virtual void sub_config_exit(AST & node) {}
  virtual void architecture_exit(AST & node) {}
  virtual void tln_from_exit(AST & node) {}
  virtual void constant_exit(AST & node) {}
  virtual void xrf_exit(AST & node) {}
  virtual void componentports_exit(AST & node) {}
  virtual void componentport_exit(AST & node) {}
  virtual void selected_ident_exit(AST & node) {}
  virtual void ident_exit(AST & node) {}
  virtual void slice_exit(AST & node) {}
  virtual void generic_exit(AST & node) {}
  virtual void remove_package_exit(AST & node) {}
  virtual void add_package_exit(AST & node) {}
  virtual void move_package_exit(AST & node) {}
  virtual void add_header_exit(AST & node) {}
  virtual void move_header_exit(AST & node) {}
  virtual void remove_header_exit(AST & node) {}
  virtual void exec_script_exit(AST & node) {}
  virtual void assign_exit(AST & node) {}
  virtual void component_exit(AST & node) {}
  virtual void rename_ports_exit(AST & node) {}
  virtual void opt_match_exit(AST & node) {}
  virtual void group_comment_exit(AST & node) {}
  virtual void port_comment_exit(AST & node) {}
  virtual void keep_case_exit(AST & node) {}
  virtual void language_exit(AST & node) {}
  virtual void create_exit(AST & node) {}
  virtual void post_exec_script_exit(AST & node) {}
  virtual void rubycode_exit(AST & node) {}
  virtual void rubypostcode_exit(AST & node) {}
  virtual void pythoncode_exit(AST & node) {}
  virtual void pythonpostcode_exit(AST & node) {}
  virtual void fileheader_exit(AST & node) {}
  virtual void sc_method_exit(AST & node) {}
  virtual void identifier_list_exit(AST & node) {}
  virtual void xrfp_exit(AST & node) {}
  virtual void entity_comment_exit(AST & node) {}
  virtual void arch_comment_exit(AST & node) {}
  virtual void inst_comment_exit(AST & node) {}
  virtual void sc_thread_exit(AST & node) {}
  virtual void config_in_arch_exit(AST & node) {}

protected:
  void traverse_(AST & node);
  void print_(AST & node, unsigned int indent);

};

#endif
