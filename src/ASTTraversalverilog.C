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

#include "ASTTraversalverilog.h"
#include <iostream>

AST ASTTraversalverilog::ast;

void ASTTraversalverilog::traverse()
{
  traverse_(ast);
}

void ASTTraversalverilog::print()
{
  print_(ast, 0);
}

void ASTTraversalverilog::traverse_(AST & node)
{
  if (node.getType() == AST::AST_NODE)
    {
      AST_list::iterator it;
      AST_list & nodes = node.getNodes();

      unsigned int node_rule_number = node.getRuleNumber();

      if (node_rule_number == 0)
        main(node);
      else if (node_rule_number == 1)
        source_file(node);
      else if (node_rule_number == 2)
        attribute_instance(node);
      else if (node_rule_number == 3)
        attr_spec_list(node);
      else if (node_rule_number == 4)
        attr_spec(node);
      else if (node_rule_number == 5)
        attribute_instance_opt(node);
      else if (node_rule_number == 6)
        block_item_decl(node);
      else if (node_rule_number == 7)
        block_item_decls(node);
      else if (node_rule_number == 8)
        block_item_decls_opt(node);
      else if (node_rule_number == 9)
        case_item(node);
      else if (node_rule_number == 10)
        case_items(node);
      else if (node_rule_number == 11)
        charge_strength(node);
      else if (node_rule_number == 12)
        charge_strength_opt(node);
      else if (node_rule_number == 13)
        defparam_assign(node);
      else if (node_rule_number == 14)
        defparam_assign_list(node);
      else if (node_rule_number == 15)
        delay1(node);
      else if (node_rule_number == 16)
        delay3(node);
      else if (node_rule_number == 17)
        delay3_opt(node);
      else if (node_rule_number == 18)
        delay_value(node);
      else if (node_rule_number == 19)
        delay_value_simple(node);
      else if (node_rule_number == 20)
        description(node);
      else if (node_rule_number == 21)
        drive_strength(node);
      else if (node_rule_number == 22)
        drive_strength_opt(node);
      else if (node_rule_number == 23)
        dr_strength0(node);
      else if (node_rule_number == 24)
        dr_strength1(node);
      else if (node_rule_number == 25)
        event_control(node);
      else if (node_rule_number == 26)
        event_expression_list(node);
      else if (node_rule_number == 27)
        event_expression(node);
      else if (node_rule_number == 28)
        expression(node);
      else if (node_rule_number == 29)
        expression_list(node);
      else if (node_rule_number == 30)
        expr_primary(node);
      else if (node_rule_number == 31)
        range_expression(node);
      else if (node_rule_number == 32)
        function_item(node);
      else if (node_rule_number == 33)
        function_item_list(node);
      else if (node_rule_number == 34)
        gate_instance(node);
      else if (node_rule_number == 35)
        gate_instance_list(node);
      else if (node_rule_number == 36)
        gatetype(node);
      else if (node_rule_number == 37)
        identifier(node);
      else if (node_rule_number == 38)
        list_of_ports(node);
      else if (node_rule_number == 39)
        list_of_port_declarations(node);
      else if (node_rule_number == 40)
        port_declaration(node);
      else if (node_rule_number == 41)
        module_port_declaration(node);
      else if (node_rule_number == 42)
        data_type_or_implicit(node);
      else if (node_rule_number == 43)
        data_type(node);
      else if (node_rule_number == 44)
        integer_vector_type(node);
      else if (node_rule_number == 45)
        non_integer_type(node);
      else if (node_rule_number == 46)
        signing(node);
      else if (node_rule_number == 47)
        signed_opt(node);
      else if (node_rule_number == 48)
        list_of_variables(node);
      else if (node_rule_number == 49)
        net_variable_list(node);
      else if (node_rule_number == 50)
        net_variable(node);
      else if (node_rule_number == 51)
        dimensions_opt(node);
      else if (node_rule_number == 52)
        dimensions(node);
      else if (node_rule_number == 53)
        variable_dimension(node);
      else if (node_rule_number == 54)
        lavalue(node);
      else if (node_rule_number == 55)
        braced_expression(node);
      else if (node_rule_number == 56)
        braced_expression_list(node);
      else if (node_rule_number == 57)
        constant_range(node);
      else if (node_rule_number == 58)
        lpvalue(node);
      else if (node_rule_number == 59)
        assign(node);
      else if (node_rule_number == 60)
        assign_list(node);
      else if (node_rule_number == 61)
        module(node);
      else if (node_rule_number == 62)
        module_start(node);
      else if (node_rule_number == 63)
        module_port_list_opt(node);
      else if (node_rule_number == 64)
        module_end(node);
      else if (node_rule_number == 65)
        module_parameter_port_list(node);
      else if (node_rule_number == 66)
        parameter_declaration(node);
      else if (node_rule_number == 67)
        parameter_type(node);
      else if (node_rule_number == 68)
        bit_logic_opt(node);
      else if (node_rule_number == 69)
        bit_logic(node);
      else if (node_rule_number == 70)
        module_item(node);
      else if (node_rule_number == 71)
        module_item_list(node);
      else if (node_rule_number == 72)
        net_decl_assign(node);
      else if (node_rule_number == 73)
        net_decl_assigns(node);
      else if (node_rule_number == 74)
        net_type(node);
      else if (node_rule_number == 75)
        net_type_opt(node);
      else if (node_rule_number == 76)
        parameter_assign(node);
      else if (node_rule_number == 77)
        parameter_assign_list(node);
      else if (node_rule_number == 78)
        localparam_assign(node);
      else if (node_rule_number == 79)
        localparam_assign_list(node);
      else if (node_rule_number == 80)
        parameter_value_opt(node);
      else if (node_rule_number == 81)
        parameter_value_byname(node);
      else if (node_rule_number == 82)
        parameter_value_byname_list(node);
      else if (node_rule_number == 83)
        port(node);
      else if (node_rule_number == 84)
        port_opt(node);
      else if (node_rule_number == 85)
        port_reference(node);
      else if (node_rule_number == 86)
        port_reference_list(node);
      else if (node_rule_number == 87)
        port_name(node);
      else if (node_rule_number == 88)
        port_name_list(node);
      else if (node_rule_number == 89)
        range(node);
      else if (node_rule_number == 90)
        range_opt(node);
      else if (node_rule_number == 91)
        range_or_type_opt(node);
      else if (node_rule_number == 92)
        register_variable(node);
      else if (node_rule_number == 93)
        register_variable_list(node);
      else if (node_rule_number == 94)
        specify_item(node);
      else if (node_rule_number == 95)
        specify_item_list(node);
      else if (node_rule_number == 96)
        specify_simple_path(node);
      else if (node_rule_number == 97)
        specparam(node);
      else if (node_rule_number == 98)
        specparam_list(node);
      else if (node_rule_number == 99)
        spec_polarity(node);
      else if (node_rule_number == 100)
        statement(node);
      else if (node_rule_number == 101)
        statement_list(node);
      else if (node_rule_number == 102)
        statement_opt(node);
      else if (node_rule_number == 103)
        task_item(node);
      else if (node_rule_number == 104)
        task_item_list(node);
      else if (node_rule_number == 105)
        task_item_list_opt(node);
      else if (node_rule_number == 106)
        udp_body(node);
      else if (node_rule_number == 107)
        udp_entry_list(node);
      else if (node_rule_number == 108)
        udp_comb_entry(node);
      else if (node_rule_number == 109)
        udp_comb_entry_list(node);
      else if (node_rule_number == 110)
        udp_sequ_entry_list(node);
      else if (node_rule_number == 111)
        udp_sequ_entry(node);
      else if (node_rule_number == 112)
        udp_initial(node);
      else if (node_rule_number == 113)
        udp_init_opt(node);
      else if (node_rule_number == 114)
        udp_input_list(node);
      else if (node_rule_number == 115)
        udp_input_sym(node);
      else if (node_rule_number == 116)
        udp_output_sym(node);
      else if (node_rule_number == 117)
        udp_port_decl(node);
      else if (node_rule_number == 118)
        udp_port_decls(node);
      else if (node_rule_number == 119)
        udp_port_list(node);
      else if (node_rule_number == 120)
        udp_primitive(node);
      else if (node_rule_number == 121)
        genvar_declaration(node);
      else if (node_rule_number == 122)
        list_of_genvar_identifiers(node);
      else if (node_rule_number == 123)
        generated_instantiation(node);
      else if (node_rule_number == 124)
        generate_item_list(node);
      else if (node_rule_number == 125)
        generate_item(node);
      else if (node_rule_number == 126)
        generate_if(node);
      else if (node_rule_number == 127)
        generate_conditional_statement(node);
      else if (node_rule_number == 128)
        generate_case_statement(node);
      else if (node_rule_number == 129)
        generate_case_item_list(node);
      else if (node_rule_number == 130)
        generate_case_item(node);
      else if (node_rule_number == 131)
        generate_loop_statement(node);
      else if (node_rule_number == 132)
        genvar_assignment(node);
      else if (node_rule_number == 133)
        generate_block(node);
      else if (node_rule_number == 134)
        generate_block_opt(node);
      else if (node_rule_number == 135)
        expression_list2(node);
      else if (node_rule_number == 136)
        colon_opt(node);
      else if (node_rule_number == 137)
        automatic_opt(node);
      else
        throw AriException("Unknown node : " + node.getName());

      for (it=nodes.begin(); it!=nodes.end(); ++it)
        traverse_(**it);

      if (node_rule_number == 0)
        main_exit(node);
      else if (node_rule_number == 1)
        source_file_exit(node);
      else if (node_rule_number == 2)
        attribute_instance_exit(node);
      else if (node_rule_number == 3)
        attr_spec_list_exit(node);
      else if (node_rule_number == 4)
        attr_spec_exit(node);
      else if (node_rule_number == 5)
        attribute_instance_opt_exit(node);
      else if (node_rule_number == 6)
        block_item_decl_exit(node);
      else if (node_rule_number == 7)
        block_item_decls_exit(node);
      else if (node_rule_number == 8)
        block_item_decls_opt_exit(node);
      else if (node_rule_number == 9)
        case_item_exit(node);
      else if (node_rule_number == 10)
        case_items_exit(node);
      else if (node_rule_number == 11)
        charge_strength_exit(node);
      else if (node_rule_number == 12)
        charge_strength_opt_exit(node);
      else if (node_rule_number == 13)
        defparam_assign_exit(node);
      else if (node_rule_number == 14)
        defparam_assign_list_exit(node);
      else if (node_rule_number == 15)
        delay1_exit(node);
      else if (node_rule_number == 16)
        delay3_exit(node);
      else if (node_rule_number == 17)
        delay3_opt_exit(node);
      else if (node_rule_number == 18)
        delay_value_exit(node);
      else if (node_rule_number == 19)
        delay_value_simple_exit(node);
      else if (node_rule_number == 20)
        description_exit(node);
      else if (node_rule_number == 21)
        drive_strength_exit(node);
      else if (node_rule_number == 22)
        drive_strength_opt_exit(node);
      else if (node_rule_number == 23)
        dr_strength0_exit(node);
      else if (node_rule_number == 24)
        dr_strength1_exit(node);
      else if (node_rule_number == 25)
        event_control_exit(node);
      else if (node_rule_number == 26)
        event_expression_list_exit(node);
      else if (node_rule_number == 27)
        event_expression_exit(node);
      else if (node_rule_number == 28)
        expression_exit(node);
      else if (node_rule_number == 29)
        expression_list_exit(node);
      else if (node_rule_number == 30)
        expr_primary_exit(node);
      else if (node_rule_number == 31)
        range_expression_exit(node);
      else if (node_rule_number == 32)
        function_item_exit(node);
      else if (node_rule_number == 33)
        function_item_list_exit(node);
      else if (node_rule_number == 34)
        gate_instance_exit(node);
      else if (node_rule_number == 35)
        gate_instance_list_exit(node);
      else if (node_rule_number == 36)
        gatetype_exit(node);
      else if (node_rule_number == 37)
        identifier_exit(node);
      else if (node_rule_number == 38)
        list_of_ports_exit(node);
      else if (node_rule_number == 39)
        list_of_port_declarations_exit(node);
      else if (node_rule_number == 40)
        port_declaration_exit(node);
      else if (node_rule_number == 41)
        module_port_declaration_exit(node);
      else if (node_rule_number == 42)
        data_type_or_implicit_exit(node);
      else if (node_rule_number == 43)
        data_type_exit(node);
      else if (node_rule_number == 44)
        integer_vector_type_exit(node);
      else if (node_rule_number == 45)
        non_integer_type_exit(node);
      else if (node_rule_number == 46)
        signing_exit(node);
      else if (node_rule_number == 47)
        signed_opt_exit(node);
      else if (node_rule_number == 48)
        list_of_variables_exit(node);
      else if (node_rule_number == 49)
        net_variable_list_exit(node);
      else if (node_rule_number == 50)
        net_variable_exit(node);
      else if (node_rule_number == 51)
        dimensions_opt_exit(node);
      else if (node_rule_number == 52)
        dimensions_exit(node);
      else if (node_rule_number == 53)
        variable_dimension_exit(node);
      else if (node_rule_number == 54)
        lavalue_exit(node);
      else if (node_rule_number == 55)
        braced_expression_exit(node);
      else if (node_rule_number == 56)
        braced_expression_list_exit(node);
      else if (node_rule_number == 57)
        constant_range_exit(node);
      else if (node_rule_number == 58)
        lpvalue_exit(node);
      else if (node_rule_number == 59)
        assign_exit(node);
      else if (node_rule_number == 60)
        assign_list_exit(node);
      else if (node_rule_number == 61)
        module_exit(node);
      else if (node_rule_number == 62)
        module_start_exit(node);
      else if (node_rule_number == 63)
        module_port_list_opt_exit(node);
      else if (node_rule_number == 64)
        module_end_exit(node);
      else if (node_rule_number == 65)
        module_parameter_port_list_exit(node);
      else if (node_rule_number == 66)
        parameter_declaration_exit(node);
      else if (node_rule_number == 67)
        parameter_type_exit(node);
      else if (node_rule_number == 68)
        bit_logic_opt_exit(node);
      else if (node_rule_number == 69)
        bit_logic_exit(node);
      else if (node_rule_number == 70)
        module_item_exit(node);
      else if (node_rule_number == 71)
        module_item_list_exit(node);
      else if (node_rule_number == 72)
        net_decl_assign_exit(node);
      else if (node_rule_number == 73)
        net_decl_assigns_exit(node);
      else if (node_rule_number == 74)
        net_type_exit(node);
      else if (node_rule_number == 75)
        net_type_opt_exit(node);
      else if (node_rule_number == 76)
        parameter_assign_exit(node);
      else if (node_rule_number == 77)
        parameter_assign_list_exit(node);
      else if (node_rule_number == 78)
        localparam_assign_exit(node);
      else if (node_rule_number == 79)
        localparam_assign_list_exit(node);
      else if (node_rule_number == 80)
        parameter_value_opt_exit(node);
      else if (node_rule_number == 81)
        parameter_value_byname_exit(node);
      else if (node_rule_number == 82)
        parameter_value_byname_list_exit(node);
      else if (node_rule_number == 83)
        port_exit(node);
      else if (node_rule_number == 84)
        port_opt_exit(node);
      else if (node_rule_number == 85)
        port_reference_exit(node);
      else if (node_rule_number == 86)
        port_reference_list_exit(node);
      else if (node_rule_number == 87)
        port_name_exit(node);
      else if (node_rule_number == 88)
        port_name_list_exit(node);
      else if (node_rule_number == 89)
        range_exit(node);
      else if (node_rule_number == 90)
        range_opt_exit(node);
      else if (node_rule_number == 91)
        range_or_type_opt_exit(node);
      else if (node_rule_number == 92)
        register_variable_exit(node);
      else if (node_rule_number == 93)
        register_variable_list_exit(node);
      else if (node_rule_number == 94)
        specify_item_exit(node);
      else if (node_rule_number == 95)
        specify_item_list_exit(node);
      else if (node_rule_number == 96)
        specify_simple_path_exit(node);
      else if (node_rule_number == 97)
        specparam_exit(node);
      else if (node_rule_number == 98)
        specparam_list_exit(node);
      else if (node_rule_number == 99)
        spec_polarity_exit(node);
      else if (node_rule_number == 100)
        statement_exit(node);
      else if (node_rule_number == 101)
        statement_list_exit(node);
      else if (node_rule_number == 102)
        statement_opt_exit(node);
      else if (node_rule_number == 103)
        task_item_exit(node);
      else if (node_rule_number == 104)
        task_item_list_exit(node);
      else if (node_rule_number == 105)
        task_item_list_opt_exit(node);
      else if (node_rule_number == 106)
        udp_body_exit(node);
      else if (node_rule_number == 107)
        udp_entry_list_exit(node);
      else if (node_rule_number == 108)
        udp_comb_entry_exit(node);
      else if (node_rule_number == 109)
        udp_comb_entry_list_exit(node);
      else if (node_rule_number == 110)
        udp_sequ_entry_list_exit(node);
      else if (node_rule_number == 111)
        udp_sequ_entry_exit(node);
      else if (node_rule_number == 112)
        udp_initial_exit(node);
      else if (node_rule_number == 113)
        udp_init_opt_exit(node);
      else if (node_rule_number == 114)
        udp_input_list_exit(node);
      else if (node_rule_number == 115)
        udp_input_sym_exit(node);
      else if (node_rule_number == 116)
        udp_output_sym_exit(node);
      else if (node_rule_number == 117)
        udp_port_decl_exit(node);
      else if (node_rule_number == 118)
        udp_port_decls_exit(node);
      else if (node_rule_number == 119)
        udp_port_list_exit(node);
      else if (node_rule_number == 120)
        udp_primitive_exit(node);
      else if (node_rule_number == 121)
        genvar_declaration_exit(node);
      else if (node_rule_number == 122)
        list_of_genvar_identifiers_exit(node);
      else if (node_rule_number == 123)
        generated_instantiation_exit(node);
      else if (node_rule_number == 124)
        generate_item_list_exit(node);
      else if (node_rule_number == 125)
        generate_item_exit(node);
      else if (node_rule_number == 126)
        generate_if_exit(node);
      else if (node_rule_number == 127)
        generate_conditional_statement_exit(node);
      else if (node_rule_number == 128)
        generate_case_statement_exit(node);
      else if (node_rule_number == 129)
        generate_case_item_list_exit(node);
      else if (node_rule_number == 130)
        generate_case_item_exit(node);
      else if (node_rule_number == 131)
        generate_loop_statement_exit(node);
      else if (node_rule_number == 132)
        genvar_assignment_exit(node);
      else if (node_rule_number == 133)
        generate_block_exit(node);
      else if (node_rule_number == 134)
        generate_block_opt_exit(node);
      else if (node_rule_number == 135)
        expression_list2_exit(node);
      else if (node_rule_number == 136)
        colon_opt_exit(node);
      else if (node_rule_number == 137)
        automatic_opt_exit(node);
      else
        throw AriException("Unknown node : " + node.getName());
    }
}

void ASTTraversalverilog::print_(AST & node, unsigned int indent)
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
