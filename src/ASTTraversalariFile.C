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

#include "ASTTraversalariFile.h"
#include "AriException.h"
#include <cstdio>
#include <iostream>

AST ASTTraversalariFile::ast;

void ASTTraversalariFile::traverse()
{
  traverse_(ast);
}

void ASTTraversalariFile::print()
{
  print_(ast, 0);
}

void ASTTraversalariFile::traverse_(AST & node)
{
  if (node.getType() == AST::AST_NODE)
    {
      AST_list::iterator it;
      AST_list & nodes = node.getNodes();

      unsigned int node_rule_number = node.getRuleNumber();

      if (node_rule_number == 0)
        syntax(node);
      else if (node_rule_number == 1)
        hierarchy(node);
      else if (node_rule_number == 2)
        module_list(node);
      else if (node_rule_number == 3)
        module(node);
      else if (node_rule_number == 4)
        opt_module_list(node);
      else if (node_rule_number == 5)
        info_list(node);
      else if (node_rule_number == 6)
        info(node);
      else if (node_rule_number == 7)
        opt_semicolon(node);
      else if (node_rule_number == 8)
        info_line_list(node);
      else if (node_rule_number == 9)
        info_line(node);
      else if (node_rule_number == 10)
        statements(node);
      else if (node_rule_number == 11)
        declarations(node);
      else if (node_rule_number == 12)
        declarationstop(node);
      else if (node_rule_number == 13)
        signal(node);
      else if (node_rule_number == 14)
        port(node);
      else if (node_rule_number == 15)
        opt_group_comment(node);
      else if (node_rule_number == 16)
        direction(node);
      else if (node_rule_number == 17)
        library(node);
      else if (node_rule_number == 18)
        configuration(node);
      else if (node_rule_number == 19)
        sub_configs(node);
      else if (node_rule_number == 20)
        sub_config(node);
      else if (node_rule_number == 21)
        architecture(node);
      else if (node_rule_number == 22)
        tln_from(node);
      else if (node_rule_number == 23)
        constant(node);
      else if (node_rule_number == 24)
        xrf(node);
      else if (node_rule_number == 25)
        componentports(node);
      else if (node_rule_number == 26)
        componentport(node);
      else if (node_rule_number == 27)
        selected_ident(node);
      else if (node_rule_number == 28)
        ident(node);
      else if (node_rule_number == 29)
        slice(node);
      else if (node_rule_number == 30)
        generic(node);
      else if (node_rule_number == 31)
        remove_package(node);
      else if (node_rule_number == 32)
        add_package(node);
      else if (node_rule_number == 33)
        move_package(node);
      else if (node_rule_number == 34)
        add_header(node);
      else if (node_rule_number == 35)
        move_header(node);
      else if (node_rule_number == 36)
        remove_header(node);
      else if (node_rule_number == 37)
        exec_script(node);
      else if (node_rule_number == 38)
        assign(node);
      else if (node_rule_number == 39)
        component(node);
      else if (node_rule_number == 40)
        rename_ports(node);
      else if (node_rule_number == 41)
        opt_match(node);
      else if (node_rule_number == 42)
        group_comment(node);
      else if (node_rule_number == 43)
        port_comment(node);
      else if (node_rule_number == 44)
        keep_case(node);
      else if (node_rule_number == 45)
        language(node);
      else if (node_rule_number == 46)
        create(node);
      else if (node_rule_number == 47)
        post_exec_script(node);
      else if (node_rule_number == 48)
        rubycode(node);
      else if (node_rule_number == 49)
        rubypostcode(node);
      else if (node_rule_number == 50)
        pythoncode(node);
      else if (node_rule_number == 51)
        pythonpostcode(node);
      else if (node_rule_number == 52)
        fileheader(node);
      else if (node_rule_number == 53)
        sc_method(node);
      else if (node_rule_number == 54)
        identifier_list(node);
      else if (node_rule_number == 55)
        xrfp(node);
      else if (node_rule_number == 56)
        entity_comment(node);
      else if (node_rule_number == 57)
        arch_comment(node);
      else if (node_rule_number == 58)
        inst_comment(node);
      else if (node_rule_number == 59)
        sc_thread(node);
      else if (node_rule_number == 60)
        config_in_arch(node);
      else
        throw AriException("Unknown node : " + node.getName());

      for (it=nodes.begin(); it!=nodes.end(); ++it)
        traverse_(**it);

      if (node_rule_number == 0)
        syntax_exit(node);
      else if (node_rule_number == 1)
        hierarchy_exit(node);
      else if (node_rule_number == 2)
        module_list_exit(node);
      else if (node_rule_number == 3)
        module_exit(node);
      else if (node_rule_number == 4)
        opt_module_list_exit(node);
      else if (node_rule_number == 5)
        info_list_exit(node);
      else if (node_rule_number == 6)
        info_exit(node);
      else if (node_rule_number == 7)
        opt_semicolon_exit(node);
      else if (node_rule_number == 8)
        info_line_list_exit(node);
      else if (node_rule_number == 9)
        info_line_exit(node);
      else if (node_rule_number == 10)
        statements_exit(node);
      else if (node_rule_number == 11)
        declarations_exit(node);
      else if (node_rule_number == 12)
        declarationstop_exit(node);
      else if (node_rule_number == 13)
        signal_exit(node);
      else if (node_rule_number == 14)
        port_exit(node);
      else if (node_rule_number == 15)
        opt_group_comment_exit(node);
      else if (node_rule_number == 16)
        direction_exit(node);
      else if (node_rule_number == 17)
        library_exit(node);
      else if (node_rule_number == 18)
        configuration_exit(node);
      else if (node_rule_number == 19)
        sub_configs_exit(node);
      else if (node_rule_number == 20)
        sub_config_exit(node);
      else if (node_rule_number == 21)
        architecture_exit(node);
      else if (node_rule_number == 22)
        tln_from_exit(node);
      else if (node_rule_number == 23)
        constant_exit(node);
      else if (node_rule_number == 24)
        xrf_exit(node);
      else if (node_rule_number == 25)
        componentports_exit(node);
      else if (node_rule_number == 26)
        componentport_exit(node);
      else if (node_rule_number == 27)
        selected_ident_exit(node);
      else if (node_rule_number == 28)
        ident_exit(node);
      else if (node_rule_number == 29)
        slice_exit(node);
      else if (node_rule_number == 30)
        generic_exit(node);
      else if (node_rule_number == 31)
        remove_package_exit(node);
      else if (node_rule_number == 32)
        add_package_exit(node);
      else if (node_rule_number == 33)
        move_package_exit(node);
      else if (node_rule_number == 34)
        add_header_exit(node);
      else if (node_rule_number == 35)
        move_header_exit(node);
      else if (node_rule_number == 36)
        remove_header_exit(node);
      else if (node_rule_number == 37)
        exec_script_exit(node);
      else if (node_rule_number == 38)
        assign_exit(node);
      else if (node_rule_number == 39)
        component_exit(node);
      else if (node_rule_number == 40)
        rename_ports_exit(node);
      else if (node_rule_number == 41)
        opt_match_exit(node);
      else if (node_rule_number == 42)
        group_comment_exit(node);
      else if (node_rule_number == 43)
        port_comment_exit(node);
      else if (node_rule_number == 44)
        keep_case_exit(node);
      else if (node_rule_number == 45)
        language_exit(node);
      else if (node_rule_number == 46)
        create_exit(node);
      else if (node_rule_number == 47)
        post_exec_script_exit(node);
      else if (node_rule_number == 48)
        rubycode_exit(node);
      else if (node_rule_number == 49)
        rubypostcode_exit(node);
      else if (node_rule_number == 50)
        pythoncode_exit(node);
      else if (node_rule_number == 51)
        pythonpostcode_exit(node);
      else if (node_rule_number == 52)
        fileheader_exit(node);
      else if (node_rule_number == 53)
        sc_method_exit(node);
      else if (node_rule_number == 54)
        identifier_list_exit(node);
      else if (node_rule_number == 55)
        xrfp_exit(node);
      else if (node_rule_number == 56)
        entity_comment_exit(node);
      else if (node_rule_number == 57)
        arch_comment_exit(node);
      else if (node_rule_number == 58)
        inst_comment_exit(node);
      else if (node_rule_number == 59)
        sc_thread_exit(node);
      else if (node_rule_number == 60)
        config_in_arch_exit(node);
      else
        throw AriException("Unknown node : " + node.getName());
    }
}

void ASTTraversalariFile::print_(AST & node, unsigned int indent)
{
  for(unsigned int i=0; i<indent; ++i)
    if (i==indent-1)
      std::cout << "|";
    else
      std::cout << "-";

  node.print();

  if (node.getType() == AST::AST_NODE)
    {
      AST_list::iterator it;
      AST_list & nodes = node.getNodes();

      for (it=nodes.begin(); it!=nodes.end(); ++it)
        print_(**it, indent+2);
    }
}
