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

#include "ASTTraversalvhdl.h"
#include <iostream>

AST ASTTraversalvhdl::ast;

void ASTTraversalvhdl::traverse()
{
  traverse_(ast);
}

void ASTTraversalvhdl::print()
{
  print_(ast, 0);
}

void ASTTraversalvhdl::traverse_(AST & node)
{
  if (node.getType() == AST::AST_NODE)
    {
      AST_list::iterator it;
      AST_list & nodes = node.getNodes();

      unsigned int node_rule_number = node.getRuleNumber();

      if (node_rule_number == 0)
        design_file(node);
      else if (node_rule_number == 1)
        design_unit_list(node);
      else if (node_rule_number == 2)
        designator(node);
      else if (node_rule_number == 3)
        character_literal(node);
      else if (node_rule_number == 4)
        literal(node);
      else if (node_rule_number == 5)
        enumeration_literal(node);
      else if (node_rule_number == 6)
        physical_literal(node);
      else if (node_rule_number == 7)
        physical_literal_no_default(node);
      else if (node_rule_number == 8)
        idf_list(node);
      else if (node_rule_number == 9)
        design_unit(node);
      else if (node_rule_number == 10)
        context_list(node);
      else if (node_rule_number == 11)
        lib_unit(node);
      else if (node_rule_number == 12)
        context_item(node);
      else if (node_rule_number == 13)
        lib_clause(node);
      else if (node_rule_number == 14)
        use_clause(node);
      else if (node_rule_number == 15)
        use_clause_list(node);
      else if (node_rule_number == 16)
        use_clause_item(node);
      else if (node_rule_number == 17)
        package_selection(node);
      else if (node_rule_number == 18)
        entity_decl(node);
      else if (node_rule_number == 19)
        entity_start(node);
      else if (node_rule_number == 20)
        entity_decl_5(node);
      else if (node_rule_number == 21)
        entity_decl_4(node);
      else if (node_rule_number == 22)
        entity_decl_3(node);
      else if (node_rule_number == 23)
        entity_decl_2(node);
      else if (node_rule_number == 24)
        entity_decl_1(node);
      else if (node_rule_number == 25)
        arch_body(node);
      else if (node_rule_number == 26)
        arch_start(node);
      else if (node_rule_number == 27)
        arch_body_2(node);
      else if (node_rule_number == 28)
        arch_body_1(node);
      else if (node_rule_number == 29)
        config_decl(node);
      else if (node_rule_number == 30)
        config_start(node);
      else if (node_rule_number == 31)
        config_decl_2(node);
      else if (node_rule_number == 32)
        config_decl_1(node);
      else if (node_rule_number == 33)
        config_decl_3(node);
      else if (node_rule_number == 34)
        package_decl(node);
      else if (node_rule_number == 35)
        package_start(node);
      else if (node_rule_number == 36)
        package_decl_2(node);
      else if (node_rule_number == 37)
        package_decl_1(node);
      else if (node_rule_number == 38)
        package_body(node);
      else if (node_rule_number == 39)
        pack_body_start(node);
      else if (node_rule_number == 40)
        package_body_2(node);
      else if (node_rule_number == 41)
        package_body_1(node);
      else if (node_rule_number == 42)
        common_decltve_item(node);
      else if (node_rule_number == 43)
        entity_decltve_item(node);
      else if (node_rule_number == 44)
        block_decltve_item(node);
      else if (node_rule_number == 45)
        package_decltve_item(node);
      else if (node_rule_number == 46)
        package_body_decltve_item(node);
      else if (node_rule_number == 47)
        subprog_decltve_item(node);
      else if (node_rule_number == 48)
        procs_decltve_item(node);
      else if (node_rule_number == 49)
        config_decltve_item(node);
      else if (node_rule_number == 50)
        constant_decl(node);
      else if (node_rule_number == 51)
        constant_decl_1(node);
      else if (node_rule_number == 52)
        signal_decl(node);
      else if (node_rule_number == 53)
        signal_decl_2(node);
      else if (node_rule_number == 54)
        signal_decl_1(node);
      else if (node_rule_number == 55)
        shared_var_decl(node);
      else if (node_rule_number == 56)
        variable_decl(node);
      else if (node_rule_number == 57)
        variable_decl_1(node);
      else if (node_rule_number == 58)
        subprog_decl(node);
      else if (node_rule_number == 59)
        subprog_spec(node);
      else if (node_rule_number == 60)
        subprog_spec_2(node);
      else if (node_rule_number == 61)
        subprog_body(node);
      else if (node_rule_number == 62)
        subprog_body_2(node);
      else if (node_rule_number == 63)
        subprog_body_1(node);
      else if (node_rule_number == 64)
        interf_list(node);
      else if (node_rule_number == 65)
        interf_list_1(node);
      else if (node_rule_number == 66)
        interf_element(node);
      else if (node_rule_number == 67)
        subprog_interf_list(node);
      else if (node_rule_number == 68)
        subprog_interf_list_1(node);
      else if (node_rule_number == 69)
        subprog_interf_element(node);
      else if (node_rule_number == 70)
        interf_element_4(node);
      else if (node_rule_number == 71)
        interf_element_3(node);
      else if (node_rule_number == 72)
        interf_element_2(node);
      else if (node_rule_number == 73)
        interf_element_1(node);
      else if (node_rule_number == 74)
        mode(node);
      else if (node_rule_number == 75)
        association_list(node);
      else if (node_rule_number == 76)
        association_list_1(node);
      else if (node_rule_number == 77)
        association_element(node);
      else if (node_rule_number == 78)
        formal_part(node);
      else if (node_rule_number == 79)
        actual_part(node);
      else if (node_rule_number == 80)
        gen_association_list(node);
      else if (node_rule_number == 81)
        gen_association_list_1(node);
      else if (node_rule_number == 82)
        gen_association_element(node);
      else if (node_rule_number == 83)
        element_association_list(node);
      else if (node_rule_number == 84)
        element_association(node);
      else if (node_rule_number == 85)
        choices(node);
      else if (node_rule_number == 86)
        choice(node);
      else if (node_rule_number == 87)
        mark(node);
      else if (node_rule_number == 88)
        expr(node);
      else if (node_rule_number == 89)
        and_relation(node);
      else if (node_rule_number == 90)
        or_relation(node);
      else if (node_rule_number == 91)
        xor_relation(node);
      else if (node_rule_number == 92)
        xnor_relation(node);
      else if (node_rule_number == 93)
        relation(node);
      else if (node_rule_number == 94)
        primary(node);
      else if (node_rule_number == 95)
        name(node);
      else if (node_rule_number == 96)
        name2(node);
      else if (node_rule_number == 97)
        sel_name(node);
      else if (node_rule_number == 98)
        ifts_name(node);
      else if (node_rule_number == 99)
        attribute_name(node);
      else if (node_rule_number == 100)
        suffix(node);
      else if (node_rule_number == 101)
        aggregate(node);
      else if (node_rule_number == 102)
        qualified_expr(node);
      else if (node_rule_number == 103)
        allocator(node);
      else if (node_rule_number == 104)
        allocator_2(node);
      else if (node_rule_number == 105)
        allocator_1(node);
      else if (node_rule_number == 106)
        type_decl(node);
      else if (node_rule_number == 107)
        type_decl_1(node);
      else if (node_rule_number == 108)
        type_definition(node);
      else if (node_rule_number == 109)
        enumeration_type_definition(node);
      else if (node_rule_number == 110)
        enumeration_type_definition_1(node);
      else if (node_rule_number == 111)
        physical_type_definition(node);
      else if (node_rule_number == 112)
        physical_type_definition_1(node);
      else if (node_rule_number == 113)
        base_unit_decl(node);
      else if (node_rule_number == 114)
        secondary_unit_decl(node);
      else if (node_rule_number == 115)
        unconstrained_array_definition(node);
      else if (node_rule_number == 116)
        unconstrained_array_definition_1(node);
      else if (node_rule_number == 117)
        index_subtype_definition(node);
      else if (node_rule_number == 118)
        constrained_array_definition(node);
      else if (node_rule_number == 119)
        record_type_definition(node);
      else if (node_rule_number == 120)
        record_type_definition_2(node);
      else if (node_rule_number == 121)
        record_type_definition_1(node);
      else if (node_rule_number == 122)
        element_decl(node);
      else if (node_rule_number == 123)
        access_type_definition(node);
      else if (node_rule_number == 124)
        file_type_definition(node);
      else if (node_rule_number == 125)
        subtype_decl(node);
      else if (node_rule_number == 126)
        subtype_indic(node);
      else if (node_rule_number == 127)
        gen_association_list_array(node);
      else if (node_rule_number == 128)
        subtype_indic1(node);
      else if (node_rule_number == 129)
        range_constraint(node);
      else if (node_rule_number == 130)
        index_constraint(node);
      else if (node_rule_number == 131)
        index_constraint_1(node);
      else if (node_rule_number == 132)
        discrete_range(node);
      else if (node_rule_number == 133)
        discrete_range1(node);
      else if (node_rule_number == 134)
        range_spec_discrete(node);
      else if (node_rule_number == 135)
        range_spec(node);
      else if (node_rule_number == 136)
        direction(node);
      else if (node_rule_number == 137)
        object_class(node);
      else if (node_rule_number == 138)
        signal_kind(node);
      else if (node_rule_number == 139)
        alias_decl(node);
      else if (node_rule_number == 140)
        file_decl(node);
      else if (node_rule_number == 141)
        file_decl_common(node);
      else if (node_rule_number == 142)
        file_decl87(node);
      else if (node_rule_number == 143)
        file_decl93(node);
      else if (node_rule_number == 144)
        file_open_info(node);
      else if (node_rule_number == 145)
        file_decl_1(node);
      else if (node_rule_number == 146)
        disconnection_spec(node);
      else if (node_rule_number == 147)
        signal_list(node);
      else if (node_rule_number == 148)
        signal_list_1(node);
      else if (node_rule_number == 149)
        attribute_decl(node);
      else if (node_rule_number == 150)
        attribute_spec(node);
      else if (node_rule_number == 151)
        entity_spec(node);
      else if (node_rule_number == 152)
        entity_name_list(node);
      else if (node_rule_number == 153)
        entity_name_list_1(node);
      else if (node_rule_number == 154)
        entity_class(node);
      else if (node_rule_number == 155)
        generation_scheme(node);
      else if (node_rule_number == 156)
        if_scheme(node);
      else if (node_rule_number == 157)
        for_scheme(node);
      else if (node_rule_number == 158)
        concurrent_stats(node);
      else if (node_rule_number == 159)
        concurrent_stat(node);
      else if (node_rule_number == 160)
        block_stat(node);
      else if (node_rule_number == 161)
        block_stat_5(node);
      else if (node_rule_number == 162)
        block_stat_4(node);
      else if (node_rule_number == 163)
        block_stat_3(node);
      else if (node_rule_number == 164)
        block_stat_7(node);
      else if (node_rule_number == 165)
        block_stat_2(node);
      else if (node_rule_number == 166)
        block_stat_8(node);
      else if (node_rule_number == 167)
        block_stat_1(node);
      else if (node_rule_number == 168)
        comp_inst_stat(node);
      else if (node_rule_number == 169)
        comp_inst_stat_2(node);
      else if (node_rule_number == 170)
        comp_inst_stat_1(node);
      else if (node_rule_number == 171)
        concurrent_assertion_stat(node);
      else if (node_rule_number == 172)
        concurrent_procedure_call(node);
      else if (node_rule_number == 173)
        concurrent_signal_assign_stat(node);
      else if (node_rule_number == 174)
        condal_signal_assign(node);
      else if (node_rule_number == 175)
        condal_wavefrms(node);
      else if (node_rule_number == 176)
        condal_wavefrms_1(node);
      else if (node_rule_number == 177)
        condal_wavefrms_2(node);
      else if (node_rule_number == 178)
        wavefrm(node);
      else if (node_rule_number == 179)
        wavefrm_element(node);
      else if (node_rule_number == 180)
        wavefrm_element_1(node);
      else if (node_rule_number == 181)
        target(node);
      else if (node_rule_number == 182)
        opts(node);
      else if (node_rule_number == 183)
        opts_2(node);
      else if (node_rule_number == 184)
        opts_1(node);
      else if (node_rule_number == 185)
        sel_signal_assign(node);
      else if (node_rule_number == 186)
        sel_wavefrms(node);
      else if (node_rule_number == 187)
        sel_wavefrms_2(node);
      else if (node_rule_number == 188)
        generate_stat(node);
      else if (node_rule_number == 189)
        generate_stat_1(node);
      else if (node_rule_number == 190)
        procs_stat(node);
      else if (node_rule_number == 191)
        procs_stat1(node);
      else if (node_rule_number == 192)
        procs_stat1_4(node);
      else if (node_rule_number == 193)
        procs_stat1_3(node);
      else if (node_rule_number == 194)
        procs_stat1_2(node);
      else if (node_rule_number == 195)
        procs_stat1_1(node);
      else if (node_rule_number == 196)
        sensitivity_list(node);
      else if (node_rule_number == 197)
        seq_stats(node);
      else if (node_rule_number == 198)
        seq_stat(node);
      else if (node_rule_number == 199)
        assertion_stat(node);
      else if (node_rule_number == 200)
        assertion_stat_2(node);
      else if (node_rule_number == 201)
        assertion_stat_1(node);
      else if (node_rule_number == 202)
        case_stat(node);
      else if (node_rule_number == 203)
        case_stat_1(node);
      else if (node_rule_number == 204)
        case_stat_alternative(node);
      else if (node_rule_number == 205)
        exit_stat(node);
      else if (node_rule_number == 206)
        exit_stat_2(node);
      else if (node_rule_number == 207)
        exit_stat_1(node);
      else if (node_rule_number == 208)
        if_stat(node);
      else if (node_rule_number == 209)
        if_stat_2(node);
      else if (node_rule_number == 210)
        if_stat_1(node);
      else if (node_rule_number == 211)
        if_stat_3(node);
      else if (node_rule_number == 212)
        loop_stat(node);
      else if (node_rule_number == 213)
        loop_for(node);
      else if (node_rule_number == 214)
        loop_infinite(node);
      else if (node_rule_number == 215)
        loop_while(node);
      else if (node_rule_number == 216)
        loop_stat_3(node);
      else if (node_rule_number == 217)
        loop_stat_1(node);
      else if (node_rule_number == 218)
        next_stat(node);
      else if (node_rule_number == 219)
        next_stat_2(node);
      else if (node_rule_number == 220)
        next_stat_1(node);
      else if (node_rule_number == 221)
        null_stat(node);
      else if (node_rule_number == 222)
        procedure_call_stat(node);
      else if (node_rule_number == 223)
        return_stat(node);
      else if (node_rule_number == 224)
        return_stat_1(node);
      else if (node_rule_number == 225)
        report_stat(node);
      else if (node_rule_number == 226)
        signal_assign_stat(node);
      else if (node_rule_number == 227)
        signal_assign_stat_1(node);
      else if (node_rule_number == 228)
        variable_assign_stat(node);
      else if (node_rule_number == 229)
        wait_stat(node);
      else if (node_rule_number == 230)
        sensitivity_clause(node);
      else if (node_rule_number == 231)
        condition_clause(node);
      else if (node_rule_number == 232)
        timeout_clause(node);
      else if (node_rule_number == 233)
        comp_decl(node);
      else if (node_rule_number == 234)
        comp_decl_3(node);
      else if (node_rule_number == 235)
        comp_decl_2(node);
      else if (node_rule_number == 236)
        comp_decl_1(node);
      else if (node_rule_number == 237)
        block_config(node);
      else if (node_rule_number == 238)
        subblock_config(node);
      else if (node_rule_number == 239)
        block_config_2(node);
      else if (node_rule_number == 240)
        block_config_1(node);
      else if (node_rule_number == 241)
        block_spec(node);
      else if (node_rule_number == 242)
        block_spec_1(node);
      else if (node_rule_number == 243)
        index_spec(node);
      else if (node_rule_number == 244)
        config_item(node);
      else if (node_rule_number == 245)
        comp_config(node);
      else if (node_rule_number == 246)
        comp_config_2(node);
      else if (node_rule_number == 247)
        comp_config_1(node);
      else if (node_rule_number == 248)
        config_spec(node);
      else if (node_rule_number == 249)
        comp_spec(node);
      else if (node_rule_number == 250)
        inst_list(node);
      else if (node_rule_number == 251)
        binding_indic(node);
      else if (node_rule_number == 252)
        binding_indic_2(node);
      else if (node_rule_number == 253)
        binding_indic_1(node);
      else if (node_rule_number == 254)
        entity_aspect(node);
      else if (node_rule_number == 255)
        entity_aspect_arch_name(node);
      else
        throw AriException("Unknown node : " + node.getName());

      for (it=nodes.begin(); it!=nodes.end(); ++it)
        traverse_(**it);

      if (node_rule_number == 0)
        design_file_exit(node);
      else if (node_rule_number == 1)
        design_unit_list_exit(node);
      else if (node_rule_number == 2)
        designator_exit(node);
      else if (node_rule_number == 3)
        character_literal_exit(node);
      else if (node_rule_number == 4)
        literal_exit(node);
      else if (node_rule_number == 5)
        enumeration_literal_exit(node);
      else if (node_rule_number == 6)
        physical_literal_exit(node);
      else if (node_rule_number == 7)
        physical_literal_no_default_exit(node);
      else if (node_rule_number == 8)
        idf_list_exit(node);
      else if (node_rule_number == 9)
        design_unit_exit(node);
      else if (node_rule_number == 10)
        context_list_exit(node);
      else if (node_rule_number == 11)
        lib_unit_exit(node);
      else if (node_rule_number == 12)
        context_item_exit(node);
      else if (node_rule_number == 13)
        lib_clause_exit(node);
      else if (node_rule_number == 14)
        use_clause_exit(node);
      else if (node_rule_number == 15)
        use_clause_list_exit(node);
      else if (node_rule_number == 16)
        use_clause_item_exit(node);
      else if (node_rule_number == 17)
        package_selection_exit(node);
      else if (node_rule_number == 18)
        entity_decl_exit(node);
      else if (node_rule_number == 19)
        entity_start_exit(node);
      else if (node_rule_number == 20)
        entity_decl_5_exit(node);
      else if (node_rule_number == 21)
        entity_decl_4_exit(node);
      else if (node_rule_number == 22)
        entity_decl_3_exit(node);
      else if (node_rule_number == 23)
        entity_decl_2_exit(node);
      else if (node_rule_number == 24)
        entity_decl_1_exit(node);
      else if (node_rule_number == 25)
        arch_body_exit(node);
      else if (node_rule_number == 26)
        arch_start_exit(node);
      else if (node_rule_number == 27)
        arch_body_2_exit(node);
      else if (node_rule_number == 28)
        arch_body_1_exit(node);
      else if (node_rule_number == 29)
        config_decl_exit(node);
      else if (node_rule_number == 30)
        config_start_exit(node);
      else if (node_rule_number == 31)
        config_decl_2_exit(node);
      else if (node_rule_number == 32)
        config_decl_1_exit(node);
      else if (node_rule_number == 33)
        config_decl_3_exit(node);
      else if (node_rule_number == 34)
        package_decl_exit(node);
      else if (node_rule_number == 35)
        package_start_exit(node);
      else if (node_rule_number == 36)
        package_decl_2_exit(node);
      else if (node_rule_number == 37)
        package_decl_1_exit(node);
      else if (node_rule_number == 38)
        package_body_exit(node);
      else if (node_rule_number == 39)
        pack_body_start_exit(node);
      else if (node_rule_number == 40)
        package_body_2_exit(node);
      else if (node_rule_number == 41)
        package_body_1_exit(node);
      else if (node_rule_number == 42)
        common_decltve_item_exit(node);
      else if (node_rule_number == 43)
        entity_decltve_item_exit(node);
      else if (node_rule_number == 44)
        block_decltve_item_exit(node);
      else if (node_rule_number == 45)
        package_decltve_item_exit(node);
      else if (node_rule_number == 46)
        package_body_decltve_item_exit(node);
      else if (node_rule_number == 47)
        subprog_decltve_item_exit(node);
      else if (node_rule_number == 48)
        procs_decltve_item_exit(node);
      else if (node_rule_number == 49)
        config_decltve_item_exit(node);
      else if (node_rule_number == 50)
        constant_decl_exit(node);
      else if (node_rule_number == 51)
        constant_decl_1_exit(node);
      else if (node_rule_number == 52)
        signal_decl_exit(node);
      else if (node_rule_number == 53)
        signal_decl_2_exit(node);
      else if (node_rule_number == 54)
        signal_decl_1_exit(node);
      else if (node_rule_number == 55)
        shared_var_decl_exit(node);
      else if (node_rule_number == 56)
        variable_decl_exit(node);
      else if (node_rule_number == 57)
        variable_decl_1_exit(node);
      else if (node_rule_number == 58)
        subprog_decl_exit(node);
      else if (node_rule_number == 59)
        subprog_spec_exit(node);
      else if (node_rule_number == 60)
        subprog_spec_2_exit(node);
      else if (node_rule_number == 61)
        subprog_body_exit(node);
      else if (node_rule_number == 62)
        subprog_body_2_exit(node);
      else if (node_rule_number == 63)
        subprog_body_1_exit(node);
      else if (node_rule_number == 64)
        interf_list_exit(node);
      else if (node_rule_number == 65)
        interf_list_1_exit(node);
      else if (node_rule_number == 66)
        interf_element_exit(node);
      else if (node_rule_number == 67)
        subprog_interf_list_exit(node);
      else if (node_rule_number == 68)
        subprog_interf_list_1_exit(node);
      else if (node_rule_number == 69)
        subprog_interf_element_exit(node);
      else if (node_rule_number == 70)
        interf_element_4_exit(node);
      else if (node_rule_number == 71)
        interf_element_3_exit(node);
      else if (node_rule_number == 72)
        interf_element_2_exit(node);
      else if (node_rule_number == 73)
        interf_element_1_exit(node);
      else if (node_rule_number == 74)
        mode_exit(node);
      else if (node_rule_number == 75)
        association_list_exit(node);
      else if (node_rule_number == 76)
        association_list_1_exit(node);
      else if (node_rule_number == 77)
        association_element_exit(node);
      else if (node_rule_number == 78)
        formal_part_exit(node);
      else if (node_rule_number == 79)
        actual_part_exit(node);
      else if (node_rule_number == 80)
        gen_association_list_exit(node);
      else if (node_rule_number == 81)
        gen_association_list_1_exit(node);
      else if (node_rule_number == 82)
        gen_association_element_exit(node);
      else if (node_rule_number == 83)
        element_association_list_exit(node);
      else if (node_rule_number == 84)
        element_association_exit(node);
      else if (node_rule_number == 85)
        choices_exit(node);
      else if (node_rule_number == 86)
        choice_exit(node);
      else if (node_rule_number == 87)
        mark_exit(node);
      else if (node_rule_number == 88)
        expr_exit(node);
      else if (node_rule_number == 89)
        and_relation_exit(node);
      else if (node_rule_number == 90)
        or_relation_exit(node);
      else if (node_rule_number == 91)
        xor_relation_exit(node);
      else if (node_rule_number == 92)
        xnor_relation_exit(node);
      else if (node_rule_number == 93)
        relation_exit(node);
      else if (node_rule_number == 94)
        primary_exit(node);
      else if (node_rule_number == 95)
        name_exit(node);
      else if (node_rule_number == 96)
        name2_exit(node);
      else if (node_rule_number == 97)
        sel_name_exit(node);
      else if (node_rule_number == 98)
        ifts_name_exit(node);
      else if (node_rule_number == 99)
        attribute_name_exit(node);
      else if (node_rule_number == 100)
        suffix_exit(node);
      else if (node_rule_number == 101)
        aggregate_exit(node);
      else if (node_rule_number == 102)
        qualified_expr_exit(node);
      else if (node_rule_number == 103)
        allocator_exit(node);
      else if (node_rule_number == 104)
        allocator_2_exit(node);
      else if (node_rule_number == 105)
        allocator_1_exit(node);
      else if (node_rule_number == 106)
        type_decl_exit(node);
      else if (node_rule_number == 107)
        type_decl_1_exit(node);
      else if (node_rule_number == 108)
        type_definition_exit(node);
      else if (node_rule_number == 109)
        enumeration_type_definition_exit(node);
      else if (node_rule_number == 110)
        enumeration_type_definition_1_exit(node);
      else if (node_rule_number == 111)
        physical_type_definition_exit(node);
      else if (node_rule_number == 112)
        physical_type_definition_1_exit(node);
      else if (node_rule_number == 113)
        base_unit_decl_exit(node);
      else if (node_rule_number == 114)
        secondary_unit_decl_exit(node);
      else if (node_rule_number == 115)
        unconstrained_array_definition_exit(node);
      else if (node_rule_number == 116)
        unconstrained_array_definition_1_exit(node);
      else if (node_rule_number == 117)
        index_subtype_definition_exit(node);
      else if (node_rule_number == 118)
        constrained_array_definition_exit(node);
      else if (node_rule_number == 119)
        record_type_definition_exit(node);
      else if (node_rule_number == 120)
        record_type_definition_2_exit(node);
      else if (node_rule_number == 121)
        record_type_definition_1_exit(node);
      else if (node_rule_number == 122)
        element_decl_exit(node);
      else if (node_rule_number == 123)
        access_type_definition_exit(node);
      else if (node_rule_number == 124)
        file_type_definition_exit(node);
      else if (node_rule_number == 125)
        subtype_decl_exit(node);
      else if (node_rule_number == 126)
        subtype_indic_exit(node);
      else if (node_rule_number == 127)
        gen_association_list_array_exit(node);
      else if (node_rule_number == 128)
        subtype_indic1_exit(node);
      else if (node_rule_number == 129)
        range_constraint_exit(node);
      else if (node_rule_number == 130)
        index_constraint_exit(node);
      else if (node_rule_number == 131)
        index_constraint_1_exit(node);
      else if (node_rule_number == 132)
        discrete_range_exit(node);
      else if (node_rule_number == 133)
        discrete_range1_exit(node);
      else if (node_rule_number == 134)
        range_spec_discrete_exit(node);
      else if (node_rule_number == 135)
        range_spec_exit(node);
      else if (node_rule_number == 136)
        direction_exit(node);
      else if (node_rule_number == 137)
        object_class_exit(node);
      else if (node_rule_number == 138)
        signal_kind_exit(node);
      else if (node_rule_number == 139)
        alias_decl_exit(node);
      else if (node_rule_number == 140)
        file_decl_exit(node);
      else if (node_rule_number == 141)
        file_decl_common_exit(node);
      else if (node_rule_number == 142)
        file_decl87_exit(node);
      else if (node_rule_number == 143)
        file_decl93_exit(node);
      else if (node_rule_number == 144)
        file_open_info_exit(node);
      else if (node_rule_number == 145)
        file_decl_1_exit(node);
      else if (node_rule_number == 146)
        disconnection_spec_exit(node);
      else if (node_rule_number == 147)
        signal_list_exit(node);
      else if (node_rule_number == 148)
        signal_list_1_exit(node);
      else if (node_rule_number == 149)
        attribute_decl_exit(node);
      else if (node_rule_number == 150)
        attribute_spec_exit(node);
      else if (node_rule_number == 151)
        entity_spec_exit(node);
      else if (node_rule_number == 152)
        entity_name_list_exit(node);
      else if (node_rule_number == 153)
        entity_name_list_1_exit(node);
      else if (node_rule_number == 154)
        entity_class_exit(node);
      else if (node_rule_number == 155)
        generation_scheme_exit(node);
      else if (node_rule_number == 156)
        if_scheme_exit(node);
      else if (node_rule_number == 157)
        for_scheme_exit(node);
      else if (node_rule_number == 158)
        concurrent_stats_exit(node);
      else if (node_rule_number == 159)
        concurrent_stat_exit(node);
      else if (node_rule_number == 160)
        block_stat_exit(node);
      else if (node_rule_number == 161)
        block_stat_5_exit(node);
      else if (node_rule_number == 162)
        block_stat_4_exit(node);
      else if (node_rule_number == 163)
        block_stat_3_exit(node);
      else if (node_rule_number == 164)
        block_stat_7_exit(node);
      else if (node_rule_number == 165)
        block_stat_2_exit(node);
      else if (node_rule_number == 166)
        block_stat_8_exit(node);
      else if (node_rule_number == 167)
        block_stat_1_exit(node);
      else if (node_rule_number == 168)
        comp_inst_stat_exit(node);
      else if (node_rule_number == 169)
        comp_inst_stat_2_exit(node);
      else if (node_rule_number == 170)
        comp_inst_stat_1_exit(node);
      else if (node_rule_number == 171)
        concurrent_assertion_stat_exit(node);
      else if (node_rule_number == 172)
        concurrent_procedure_call_exit(node);
      else if (node_rule_number == 173)
        concurrent_signal_assign_stat_exit(node);
      else if (node_rule_number == 174)
        condal_signal_assign_exit(node);
      else if (node_rule_number == 175)
        condal_wavefrms_exit(node);
      else if (node_rule_number == 176)
        condal_wavefrms_1_exit(node);
      else if (node_rule_number == 177)
        condal_wavefrms_2_exit(node);
      else if (node_rule_number == 178)
        wavefrm_exit(node);
      else if (node_rule_number == 179)
        wavefrm_element_exit(node);
      else if (node_rule_number == 180)
        wavefrm_element_1_exit(node);
      else if (node_rule_number == 181)
        target_exit(node);
      else if (node_rule_number == 182)
        opts_exit(node);
      else if (node_rule_number == 183)
        opts_2_exit(node);
      else if (node_rule_number == 184)
        opts_1_exit(node);
      else if (node_rule_number == 185)
        sel_signal_assign_exit(node);
      else if (node_rule_number == 186)
        sel_wavefrms_exit(node);
      else if (node_rule_number == 187)
        sel_wavefrms_2_exit(node);
      else if (node_rule_number == 188)
        generate_stat_exit(node);
      else if (node_rule_number == 189)
        generate_stat_1_exit(node);
      else if (node_rule_number == 190)
        procs_stat_exit(node);
      else if (node_rule_number == 191)
        procs_stat1_exit(node);
      else if (node_rule_number == 192)
        procs_stat1_4_exit(node);
      else if (node_rule_number == 193)
        procs_stat1_3_exit(node);
      else if (node_rule_number == 194)
        procs_stat1_2_exit(node);
      else if (node_rule_number == 195)
        procs_stat1_1_exit(node);
      else if (node_rule_number == 196)
        sensitivity_list_exit(node);
      else if (node_rule_number == 197)
        seq_stats_exit(node);
      else if (node_rule_number == 198)
        seq_stat_exit(node);
      else if (node_rule_number == 199)
        assertion_stat_exit(node);
      else if (node_rule_number == 200)
        assertion_stat_2_exit(node);
      else if (node_rule_number == 201)
        assertion_stat_1_exit(node);
      else if (node_rule_number == 202)
        case_stat_exit(node);
      else if (node_rule_number == 203)
        case_stat_1_exit(node);
      else if (node_rule_number == 204)
        case_stat_alternative_exit(node);
      else if (node_rule_number == 205)
        exit_stat_exit(node);
      else if (node_rule_number == 206)
        exit_stat_2_exit(node);
      else if (node_rule_number == 207)
        exit_stat_1_exit(node);
      else if (node_rule_number == 208)
        if_stat_exit(node);
      else if (node_rule_number == 209)
        if_stat_2_exit(node);
      else if (node_rule_number == 210)
        if_stat_1_exit(node);
      else if (node_rule_number == 211)
        if_stat_3_exit(node);
      else if (node_rule_number == 212)
        loop_stat_exit(node);
      else if (node_rule_number == 213)
        loop_for_exit(node);
      else if (node_rule_number == 214)
        loop_infinite_exit(node);
      else if (node_rule_number == 215)
        loop_while_exit(node);
      else if (node_rule_number == 216)
        loop_stat_3_exit(node);
      else if (node_rule_number == 217)
        loop_stat_1_exit(node);
      else if (node_rule_number == 218)
        next_stat_exit(node);
      else if (node_rule_number == 219)
        next_stat_2_exit(node);
      else if (node_rule_number == 220)
        next_stat_1_exit(node);
      else if (node_rule_number == 221)
        null_stat_exit(node);
      else if (node_rule_number == 222)
        procedure_call_stat_exit(node);
      else if (node_rule_number == 223)
        return_stat_exit(node);
      else if (node_rule_number == 224)
        return_stat_1_exit(node);
      else if (node_rule_number == 225)
        report_stat_exit(node);
      else if (node_rule_number == 226)
        signal_assign_stat_exit(node);
      else if (node_rule_number == 227)
        signal_assign_stat_1_exit(node);
      else if (node_rule_number == 228)
        variable_assign_stat_exit(node);
      else if (node_rule_number == 229)
        wait_stat_exit(node);
      else if (node_rule_number == 230)
        sensitivity_clause_exit(node);
      else if (node_rule_number == 231)
        condition_clause_exit(node);
      else if (node_rule_number == 232)
        timeout_clause_exit(node);
      else if (node_rule_number == 233)
        comp_decl_exit(node);
      else if (node_rule_number == 234)
        comp_decl_3_exit(node);
      else if (node_rule_number == 235)
        comp_decl_2_exit(node);
      else if (node_rule_number == 236)
        comp_decl_1_exit(node);
      else if (node_rule_number == 237)
        block_config_exit(node);
      else if (node_rule_number == 238)
        subblock_config_exit(node);
      else if (node_rule_number == 239)
        block_config_2_exit(node);
      else if (node_rule_number == 240)
        block_config_1_exit(node);
      else if (node_rule_number == 241)
        block_spec_exit(node);
      else if (node_rule_number == 242)
        block_spec_1_exit(node);
      else if (node_rule_number == 243)
        index_spec_exit(node);
      else if (node_rule_number == 244)
        config_item_exit(node);
      else if (node_rule_number == 245)
        comp_config_exit(node);
      else if (node_rule_number == 246)
        comp_config_2_exit(node);
      else if (node_rule_number == 247)
        comp_config_1_exit(node);
      else if (node_rule_number == 248)
        config_spec_exit(node);
      else if (node_rule_number == 249)
        comp_spec_exit(node);
      else if (node_rule_number == 250)
        inst_list_exit(node);
      else if (node_rule_number == 251)
        binding_indic_exit(node);
      else if (node_rule_number == 252)
        binding_indic_2_exit(node);
      else if (node_rule_number == 253)
        binding_indic_1_exit(node);
      else if (node_rule_number == 254)
        entity_aspect_exit(node);
      else if (node_rule_number == 255)
        entity_aspect_arch_name_exit(node);
      else
        throw AriException("Unknown node : " + node.getName());
    }
}

void ASTTraversalvhdl::print_(AST & node, unsigned int indent)
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
