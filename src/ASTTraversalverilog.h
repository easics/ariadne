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

#ifndef ASTTraversalverilog_H_
#define ASTTraversalverilog_H_

#include "AST.h"

class ASTTraversalverilog
{
public:
  static AST ast;

  ASTTraversalverilog() {};
  virtual ~ASTTraversalverilog() {};
  void traverse();
  void print();

  virtual void main(AST & node) {}
  virtual void source_file(AST & node) {}
  virtual void attribute_instance(AST & node) {}
  virtual void attr_spec_list(AST & node) {}
  virtual void attr_spec(AST & node) {}
  virtual void attribute_instance_opt(AST & node) {}
  virtual void block_item_decl(AST & node) {}
  virtual void block_item_decls(AST & node) {}
  virtual void block_item_decls_opt(AST & node) {}
  virtual void case_item(AST & node) {}
  virtual void case_items(AST & node) {}
  virtual void charge_strength(AST & node) {}
  virtual void charge_strength_opt(AST & node) {}
  virtual void defparam_assign(AST & node) {}
  virtual void defparam_assign_list(AST & node) {}
  virtual void delay1(AST & node) {}
  virtual void delay3(AST & node) {}
  virtual void delay3_opt(AST & node) {}
  virtual void delay_value(AST & node) {}
  virtual void delay_value_simple(AST & node) {}
  virtual void description(AST & node) {}
  virtual void drive_strength(AST & node) {}
  virtual void drive_strength_opt(AST & node) {}
  virtual void dr_strength0(AST & node) {}
  virtual void dr_strength1(AST & node) {}
  virtual void event_control(AST & node) {}
  virtual void event_expression_list(AST & node) {}
  virtual void event_expression(AST & node) {}
  virtual void expression(AST & node) {}
  virtual void expression_list(AST & node) {}
  virtual void expr_primary(AST & node) {}
  virtual void range_expression(AST & node) {}
  virtual void function_item(AST & node) {}
  virtual void function_item_list(AST & node) {}
  virtual void gate_instance(AST & node) {}
  virtual void gate_instance_list(AST & node) {}
  virtual void gatetype(AST & node) {}
  virtual void identifier(AST & node) {}
  virtual void list_of_ports(AST & node) {}
  virtual void list_of_port_declarations(AST & node) {}
  virtual void port_declaration(AST & node) {}
  virtual void module_port_declaration(AST & node) {}
  virtual void data_type_or_implicit(AST & node) {}
  virtual void data_type(AST & node) {}
  virtual void integer_vector_type(AST & node) {}
  virtual void non_integer_type(AST & node) {}
  virtual void signing(AST & node) {}
  virtual void signed_opt(AST & node) {}
  virtual void list_of_variables(AST & node) {}
  virtual void net_variable_list(AST & node) {}
  virtual void net_variable(AST & node) {}
  virtual void dimensions_opt(AST & node) {}
  virtual void dimensions(AST & node) {}
  virtual void variable_dimension(AST & node) {}
  virtual void lavalue(AST & node) {}
  virtual void braced_expression(AST & node) {}
  virtual void braced_expression_list(AST & node) {}
  virtual void constant_range(AST & node) {}
  virtual void lpvalue(AST & node) {}
  virtual void assign(AST & node) {}
  virtual void assign_list(AST & node) {}
  virtual void module(AST & node) {}
  virtual void module_start(AST & node) {}
  virtual void module_port_list_opt(AST & node) {}
  virtual void module_end(AST & node) {}
  virtual void module_parameter_port_list(AST & node) {}
  virtual void parameter_declaration(AST & node) {}
  virtual void parameter_type(AST & node) {}
  virtual void bit_logic_opt(AST & node) {}
  virtual void bit_logic(AST & node) {}
  virtual void module_item(AST & node) {}
  virtual void module_item_list(AST & node) {}
  virtual void net_decl_assign(AST & node) {}
  virtual void net_decl_assigns(AST & node) {}
  virtual void net_type(AST & node) {}
  virtual void net_type_opt(AST & node) {}
  virtual void parameter_assign(AST & node) {}
  virtual void parameter_assign_list(AST & node) {}
  virtual void localparam_assign(AST & node) {}
  virtual void localparam_assign_list(AST & node) {}
  virtual void parameter_value_opt(AST & node) {}
  virtual void parameter_value_byname(AST & node) {}
  virtual void parameter_value_byname_list(AST & node) {}
  virtual void port(AST & node) {}
  virtual void port_opt(AST & node) {}
  virtual void port_reference(AST & node) {}
  virtual void port_reference_list(AST & node) {}
  virtual void port_name(AST & node) {}
  virtual void port_name_list(AST & node) {}
  virtual void range(AST & node) {}
  virtual void range_opt(AST & node) {}
  virtual void range_or_type_opt(AST & node) {}
  virtual void register_variable(AST & node) {}
  virtual void register_variable_list(AST & node) {}
  virtual void specify_item(AST & node) {}
  virtual void specify_item_list(AST & node) {}
  virtual void specify_simple_path(AST & node) {}
  virtual void specparam(AST & node) {}
  virtual void specparam_list(AST & node) {}
  virtual void spec_polarity(AST & node) {}
  virtual void statement(AST & node) {}
  virtual void statement_list(AST & node) {}
  virtual void statement_opt(AST & node) {}
  virtual void task_item(AST & node) {}
  virtual void task_item_list(AST & node) {}
  virtual void task_item_list_opt(AST & node) {}
  virtual void udp_body(AST & node) {}
  virtual void udp_entry_list(AST & node) {}
  virtual void udp_comb_entry(AST & node) {}
  virtual void udp_comb_entry_list(AST & node) {}
  virtual void udp_sequ_entry_list(AST & node) {}
  virtual void udp_sequ_entry(AST & node) {}
  virtual void udp_initial(AST & node) {}
  virtual void udp_init_opt(AST & node) {}
  virtual void udp_input_list(AST & node) {}
  virtual void udp_input_sym(AST & node) {}
  virtual void udp_output_sym(AST & node) {}
  virtual void udp_port_decl(AST & node) {}
  virtual void udp_port_decls(AST & node) {}
  virtual void udp_port_list(AST & node) {}
  virtual void udp_primitive(AST & node) {}
  virtual void genvar_declaration(AST & node) {}
  virtual void list_of_genvar_identifiers(AST & node) {}
  virtual void generated_instantiation(AST & node) {}
  virtual void generate_item_list(AST & node) {}
  virtual void generate_item(AST & node) {}
  virtual void generate_if(AST & node) {}
  virtual void generate_conditional_statement(AST & node) {}
  virtual void generate_case_statement(AST & node) {}
  virtual void generate_case_item_list(AST & node) {}
  virtual void generate_case_item(AST & node) {}
  virtual void generate_loop_statement(AST & node) {}
  virtual void genvar_assignment(AST & node) {}
  virtual void generate_block(AST & node) {}
  virtual void generate_block_opt(AST & node) {}
  virtual void expression_list2(AST & node) {}
  virtual void colon_opt(AST & node) {}
  virtual void automatic_opt(AST & node) {}

  virtual void main_exit(AST & node) {}
  virtual void source_file_exit(AST & node) {}
  virtual void attribute_instance_exit(AST & node) {}
  virtual void attr_spec_list_exit(AST & node) {}
  virtual void attr_spec_exit(AST & node) {}
  virtual void attribute_instance_opt_exit(AST & node) {}
  virtual void block_item_decl_exit(AST & node) {}
  virtual void block_item_decls_exit(AST & node) {}
  virtual void block_item_decls_opt_exit(AST & node) {}
  virtual void case_item_exit(AST & node) {}
  virtual void case_items_exit(AST & node) {}
  virtual void charge_strength_exit(AST & node) {}
  virtual void charge_strength_opt_exit(AST & node) {}
  virtual void defparam_assign_exit(AST & node) {}
  virtual void defparam_assign_list_exit(AST & node) {}
  virtual void delay1_exit(AST & node) {}
  virtual void delay3_exit(AST & node) {}
  virtual void delay3_opt_exit(AST & node) {}
  virtual void delay_value_exit(AST & node) {}
  virtual void delay_value_simple_exit(AST & node) {}
  virtual void description_exit(AST & node) {}
  virtual void drive_strength_exit(AST & node) {}
  virtual void drive_strength_opt_exit(AST & node) {}
  virtual void dr_strength0_exit(AST & node) {}
  virtual void dr_strength1_exit(AST & node) {}
  virtual void event_control_exit(AST & node) {}
  virtual void event_expression_list_exit(AST & node) {}
  virtual void event_expression_exit(AST & node) {}
  virtual void expression_exit(AST & node) {}
  virtual void expression_list_exit(AST & node) {}
  virtual void expr_primary_exit(AST & node) {}
  virtual void range_expression_exit(AST & node) {}
  virtual void function_item_exit(AST & node) {}
  virtual void function_item_list_exit(AST & node) {}
  virtual void gate_instance_exit(AST & node) {}
  virtual void gate_instance_list_exit(AST & node) {}
  virtual void gatetype_exit(AST & node) {}
  virtual void identifier_exit(AST & node) {}
  virtual void list_of_ports_exit(AST & node) {}
  virtual void list_of_port_declarations_exit(AST & node) {}
  virtual void port_declaration_exit(AST & node) {}
  virtual void module_port_declaration_exit(AST & node) {}
  virtual void data_type_or_implicit_exit(AST & node) {}
  virtual void data_type_exit(AST & node) {}
  virtual void integer_vector_type_exit(AST & node) {}
  virtual void non_integer_type_exit(AST & node) {}
  virtual void signing_exit(AST & node) {}
  virtual void signed_opt_exit(AST & node) {}
  virtual void list_of_variables_exit(AST & node) {}
  virtual void net_variable_list_exit(AST & node) {}
  virtual void net_variable_exit(AST & node) {}
  virtual void dimensions_opt_exit(AST & node) {}
  virtual void dimensions_exit(AST & node) {}
  virtual void variable_dimension_exit(AST & node) {}
  virtual void lavalue_exit(AST & node) {}
  virtual void braced_expression_exit(AST & node) {}
  virtual void braced_expression_list_exit(AST & node) {}
  virtual void constant_range_exit(AST & node) {}
  virtual void lpvalue_exit(AST & node) {}
  virtual void assign_exit(AST & node) {}
  virtual void assign_list_exit(AST & node) {}
  virtual void module_exit(AST & node) {}
  virtual void module_start_exit(AST & node) {}
  virtual void module_port_list_opt_exit(AST & node) {}
  virtual void module_end_exit(AST & node) {}
  virtual void module_parameter_port_list_exit(AST & node) {}
  virtual void parameter_declaration_exit(AST & node) {}
  virtual void parameter_type_exit(AST & node) {}
  virtual void bit_logic_opt_exit(AST & node) {}
  virtual void bit_logic_exit(AST & node) {}
  virtual void module_item_exit(AST & node) {}
  virtual void module_item_list_exit(AST & node) {}
  virtual void net_decl_assign_exit(AST & node) {}
  virtual void net_decl_assigns_exit(AST & node) {}
  virtual void net_type_exit(AST & node) {}
  virtual void net_type_opt_exit(AST & node) {}
  virtual void parameter_assign_exit(AST & node) {}
  virtual void parameter_assign_list_exit(AST & node) {}
  virtual void localparam_assign_exit(AST & node) {}
  virtual void localparam_assign_list_exit(AST & node) {}
  virtual void parameter_value_opt_exit(AST & node) {}
  virtual void parameter_value_byname_exit(AST & node) {}
  virtual void parameter_value_byname_list_exit(AST & node) {}
  virtual void port_exit(AST & node) {}
  virtual void port_opt_exit(AST & node) {}
  virtual void port_reference_exit(AST & node) {}
  virtual void port_reference_list_exit(AST & node) {}
  virtual void port_name_exit(AST & node) {}
  virtual void port_name_list_exit(AST & node) {}
  virtual void range_exit(AST & node) {}
  virtual void range_opt_exit(AST & node) {}
  virtual void range_or_type_opt_exit(AST & node) {}
  virtual void register_variable_exit(AST & node) {}
  virtual void register_variable_list_exit(AST & node) {}
  virtual void specify_item_exit(AST & node) {}
  virtual void specify_item_list_exit(AST & node) {}
  virtual void specify_simple_path_exit(AST & node) {}
  virtual void specparam_exit(AST & node) {}
  virtual void specparam_list_exit(AST & node) {}
  virtual void spec_polarity_exit(AST & node) {}
  virtual void statement_exit(AST & node) {}
  virtual void statement_list_exit(AST & node) {}
  virtual void statement_opt_exit(AST & node) {}
  virtual void task_item_exit(AST & node) {}
  virtual void task_item_list_exit(AST & node) {}
  virtual void task_item_list_opt_exit(AST & node) {}
  virtual void udp_body_exit(AST & node) {}
  virtual void udp_entry_list_exit(AST & node) {}
  virtual void udp_comb_entry_exit(AST & node) {}
  virtual void udp_comb_entry_list_exit(AST & node) {}
  virtual void udp_sequ_entry_list_exit(AST & node) {}
  virtual void udp_sequ_entry_exit(AST & node) {}
  virtual void udp_initial_exit(AST & node) {}
  virtual void udp_init_opt_exit(AST & node) {}
  virtual void udp_input_list_exit(AST & node) {}
  virtual void udp_input_sym_exit(AST & node) {}
  virtual void udp_output_sym_exit(AST & node) {}
  virtual void udp_port_decl_exit(AST & node) {}
  virtual void udp_port_decls_exit(AST & node) {}
  virtual void udp_port_list_exit(AST & node) {}
  virtual void udp_primitive_exit(AST & node) {}
  virtual void genvar_declaration_exit(AST & node) {}
  virtual void list_of_genvar_identifiers_exit(AST & node) {}
  virtual void generated_instantiation_exit(AST & node) {}
  virtual void generate_item_list_exit(AST & node) {}
  virtual void generate_item_exit(AST & node) {}
  virtual void generate_if_exit(AST & node) {}
  virtual void generate_conditional_statement_exit(AST & node) {}
  virtual void generate_case_statement_exit(AST & node) {}
  virtual void generate_case_item_list_exit(AST & node) {}
  virtual void generate_case_item_exit(AST & node) {}
  virtual void generate_loop_statement_exit(AST & node) {}
  virtual void genvar_assignment_exit(AST & node) {}
  virtual void generate_block_exit(AST & node) {}
  virtual void generate_block_opt_exit(AST & node) {}
  virtual void expression_list2_exit(AST & node) {}
  virtual void colon_opt_exit(AST & node) {}
  virtual void automatic_opt_exit(AST & node) {}

protected:
  void traverse_(AST & node);
  void print_(AST & node, unsigned int indent);

};

#endif
