/* This file is part of ariadne. */
/*  */
/* ariadne is free software: you can redistribute it and/or modify it under */
/* the terms of the GNU General Public License as published by the Free Software */
/* Foundation, either version 3 of the License, or (at your option) any later */
/* version. */
/*  */
/* ariadne is distributed in the hope that it will be useful, but WITHOUT ANY */
/* WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A */
/* PARTICULAR PURPOSE. See the GNU General Public License for more details. */
/*  */
/* You should have received a copy of the GNU General Public License along with */
/* ariadne. If not, see <https://www.gnu.org/licenses/>. */

%{
  int vhdllex();
  int vhdlerror(const char * message);
  extern unsigned int vhdlcolumn_number;
  extern unsigned int vhdlline_number;
  #include "ASTTraversalvhdl.h"
  #define YYSTYPE AST *
  
  
%}

%token ABS ACCESS AFTER ALIAS ALL AND ARCHITECTURE ARRAY ASSERT ATTRIBUTE VHDL_BEGIN BLOCK BODY BUFFER BUS CASE COMPONENT CONFIGURATION CONSTANT DISCONNECT DOWNTO ELSE ELSIF END ENTITY EXIT VHDL_FILE FOR FUNCTION GENERATE GENERIC GUARDED IF IMPURE IN INOUT IS LABEL LIBRARY LINKAGE LOOP MAP MOD NAND NEW NEXT NOR NOT VHDL_NULL OF ON OPEN OR OTHERS OUT PACKAGE PORT PROCEDURE PROCESS PURE RANGE RECORD REGISTER REM REPORT RETURN SELECT SEVERITY SHARED SIGNAL SUBTYPE THEN TO TRANSPORT TYPE UNITS UNTIL USE VARIABLE WAIT WHEN WHILE WITH XOR XNOR AMPERSAND TICK COMMA ARROW BOX EQUAL GREATER_EQUAL GREATER LEFT_PAREN LESS_EQUAL LESS MINUS NOT_EQUAL PLUS POW RIGHT_PAREN SEMICOLON STAR VAR_ASSIGN COLON BAR DOT SLASH SLL SRL SLA SRA ROL ROR LEFT_BRACKET RIGHT_BRACKET IDENTIFIER ABSTRACT_LIT CHARACTER_LIT STRING_LIT BIT_STRING_LIT

%glr-parser

%nonassoc EQUAL NOT_EQUAL LESS LESS_EQUAL GREATER GREATER_EQUAL
%left SLL SRL SLA SRA ROL ROR
%left PLUS MINUS AMPERSAND
%left MED_PRECEDENCE
%left STAR SLASH MOD REM
%nonassoc POW ABS NOT


%%

__start__ : design_file
{
  ASTTraversalvhdl::ast = *$1;
}
;

design_file : design_unit_list 
{
  $$ = new AST;
  $$->setName("design_file");
  $$->setRuleNumber(0);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

design_unit_list : 
{
  $$ = new AST;
  $$->setName("design_unit_list");
  $$->setRuleNumber(1);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| design_unit_list design_unit 
{
  $$ = new AST;
  $$->setName("design_unit_list");
  $$->setRuleNumber(1);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

designator : IDENTIFIER 
{
  $$ = new AST;
  $$->setName("designator");
  $$->setRuleNumber(2);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| STRING_LIT 
{
  $$ = new AST;
  $$->setName("designator");
  $$->setRuleNumber(2);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

character_literal : CHARACTER_LIT 
{
  $$ = new AST;
  $$->setName("character_literal");
  $$->setRuleNumber(3);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| TICK LEFT_PAREN TICK 
{
  $$ = new AST;
  $$->setName("character_literal");
  $$->setRuleNumber(3);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

literal : ABSTRACT_LIT 
{
  $$ = new AST;
  $$->setName("literal");
  $$->setRuleNumber(4);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| character_literal 
{
  $$ = new AST;
  $$->setName("literal");
  $$->setRuleNumber(4);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| BIT_STRING_LIT 
{
  $$ = new AST;
  $$->setName("literal");
  $$->setRuleNumber(4);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| physical_literal_no_default 
{
  $$ = new AST;
  $$->setName("literal");
  $$->setRuleNumber(4);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| VHDL_NULL 
{
  $$ = new AST;
  $$->setName("literal");
  $$->setRuleNumber(4);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

enumeration_literal : character_literal 
{
  $$ = new AST;
  $$->setName("enumeration_literal");
  $$->setRuleNumber(5);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| IDENTIFIER 
{
  $$ = new AST;
  $$->setName("enumeration_literal");
  $$->setRuleNumber(5);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

physical_literal : IDENTIFIER 
{
  $$ = new AST;
  $$->setName("physical_literal");
  $$->setRuleNumber(6);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| ABSTRACT_LIT IDENTIFIER 
{
  $$ = new AST;
  $$->setName("physical_literal");
  $$->setRuleNumber(6);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

physical_literal_no_default : ABSTRACT_LIT IDENTIFIER 
{
  $$ = new AST;
  $$->setName("physical_literal_no_default");
  $$->setRuleNumber(7);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

idf_list : IDENTIFIER
{
  $$ = new AST;
  $$->setName("idf_list");
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->setRuleNumber(8);
}
| idf_list COMMA IDENTIFIER
{
  $1->addNode($2);
  $1->addNode($3);
  $$ = $1;
}
;
design_unit : context_list lib_unit 
{
  $$ = new AST;
  $$->setName("design_unit");
  $$->setRuleNumber(9);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

context_list : 
{
  $$ = new AST;
  $$->setName("context_list");
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  ;
  $$->setRuleNumber(10);
}
| context_list  context_item
{
  $1->addNode($2);
  $$ = $1;
}
;
lib_unit : entity_decl 
{
  $$ = new AST;
  $$->setName("lib_unit");
  $$->setRuleNumber(11);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| config_decl 
{
  $$ = new AST;
  $$->setName("lib_unit");
  $$->setRuleNumber(11);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| package_decl 
{
  $$ = new AST;
  $$->setName("lib_unit");
  $$->setRuleNumber(11);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| arch_body 
{
  $$ = new AST;
  $$->setName("lib_unit");
  $$->setRuleNumber(11);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| package_body 
{
  $$ = new AST;
  $$->setName("lib_unit");
  $$->setRuleNumber(11);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

context_item : lib_clause 
{
  $$ = new AST;
  $$->setName("context_item");
  $$->setRuleNumber(12);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| use_clause 
{
  $$ = new AST;
  $$->setName("context_item");
  $$->setRuleNumber(12);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

lib_clause : LIBRARY idf_list SEMICOLON 
{
  $$ = new AST;
  $$->setName("lib_clause");
  $$->setRuleNumber(13);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

use_clause : USE use_clause_list SEMICOLON 
{
  $$ = new AST;
  $$->setName("use_clause");
  $$->setRuleNumber(14);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

use_clause_list : use_clause_item
{
  $$ = new AST;
  $$->setName("use_clause_list");
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->setRuleNumber(15);
}
| use_clause_list COMMA use_clause_item
{
  $1->addNode($2);
  $1->addNode($3);
  $$ = $1;
}
;
use_clause_item : IDENTIFIER DOT IDENTIFIER DOT package_selection 
{
  $$ = new AST;
  $$->setName("use_clause_item");
  $$->setRuleNumber(16);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
}
| IDENTIFIER DOT package_selection 
{
  $$ = new AST;
  $$->setName("use_clause_item");
  $$->setRuleNumber(16);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

package_selection : IDENTIFIER 
{
  $$ = new AST;
  $$->setName("package_selection");
  $$->setRuleNumber(17);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| STRING_LIT 
{
  $$ = new AST;
  $$->setName("package_selection");
  $$->setRuleNumber(17);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| ALL 
{
  $$ = new AST;
  $$->setName("package_selection");
  $$->setRuleNumber(17);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

entity_decl : entity_start entity_decl_1 entity_decl_2 entity_decl_3 entity_decl_4 END entity_decl_5 SEMICOLON 
{
  $$ = new AST;
  $$->setName("entity_decl");
  $$->setRuleNumber(18);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
  $$->addNode($7);
  $$->addNode($8);
}
;

entity_start : ENTITY IDENTIFIER IS 
{
  $$ = new AST;
  $$->setName("entity_start");
  $$->setRuleNumber(19);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

entity_decl_5 : 
{
  $$ = new AST;
  $$->setName("entity_decl_5");
  $$->setRuleNumber(20);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| ENTITY IDENTIFIER 
{
  $$ = new AST;
  $$->setName("entity_decl_5");
  $$->setRuleNumber(20);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| IDENTIFIER 
{
  $$ = new AST;
  $$->setName("entity_decl_5");
  $$->setRuleNumber(20);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| ENTITY 
{
  $$ = new AST;
  $$->setName("entity_decl_5");
  $$->setRuleNumber(20);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

entity_decl_4 : 
{
  $$ = new AST;
  $$->setName("entity_decl_4");
  $$->setRuleNumber(21);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| VHDL_BEGIN concurrent_stats 
{
  $$ = new AST;
  $$->setName("entity_decl_4");
  $$->setRuleNumber(21);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

entity_decl_3 : 
{
  $$ = new AST;
  $$->setName("entity_decl_3");
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  ;
  $$->setRuleNumber(22);
}
| entity_decl_3  entity_decltve_item
{
  $1->addNode($2);
  $$ = $1;
}
;
entity_decl_2 : 
{
  $$ = new AST;
  $$->setName("entity_decl_2");
  $$->setRuleNumber(23);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| PORT interf_list SEMICOLON 
{
  $$ = new AST;
  $$->setName("entity_decl_2");
  $$->setRuleNumber(23);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

entity_decl_1 : 
{
  $$ = new AST;
  $$->setName("entity_decl_1");
  $$->setRuleNumber(24);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| GENERIC interf_list SEMICOLON 
{
  $$ = new AST;
  $$->setName("entity_decl_1");
  $$->setRuleNumber(24);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

arch_body : arch_start arch_body_1 VHDL_BEGIN concurrent_stats END arch_body_2 SEMICOLON 
{
  $$ = new AST;
  $$->setName("arch_body");
  $$->setRuleNumber(25);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
  $$->addNode($7);
}
;

arch_start : ARCHITECTURE IDENTIFIER OF IDENTIFIER IS 
{
  $$ = new AST;
  $$->setName("arch_start");
  $$->setRuleNumber(26);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
}
;

arch_body_2 : 
{
  $$ = new AST;
  $$->setName("arch_body_2");
  $$->setRuleNumber(27);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| ARCHITECTURE IDENTIFIER 
{
  $$ = new AST;
  $$->setName("arch_body_2");
  $$->setRuleNumber(27);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| ARCHITECTURE 
{
  $$ = new AST;
  $$->setName("arch_body_2");
  $$->setRuleNumber(27);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| IDENTIFIER 
{
  $$ = new AST;
  $$->setName("arch_body_2");
  $$->setRuleNumber(27);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

arch_body_1 : 
{
  $$ = new AST;
  $$->setName("arch_body_1");
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  ;
  $$->setRuleNumber(28);
}
| arch_body_1  block_decltve_item
{
  $1->addNode($2);
  $$ = $1;
}
;
config_decl : config_start config_decl_1 block_config END config_decl_2 SEMICOLON 
{
  $$ = new AST;
  $$->setName("config_decl");
  $$->setRuleNumber(29);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
}
;

config_start : CONFIGURATION IDENTIFIER OF IDENTIFIER IS 
{
  $$ = new AST;
  $$->setName("config_start");
  $$->setRuleNumber(30);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
}
;

config_decl_2 : 
{
  $$ = new AST;
  $$->setName("config_decl_2");
  $$->setRuleNumber(31);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| CONFIGURATION IDENTIFIER 
{
  $$ = new AST;
  $$->setName("config_decl_2");
  $$->setRuleNumber(31);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| IDENTIFIER 
{
  $$ = new AST;
  $$->setName("config_decl_2");
  $$->setRuleNumber(31);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| CONFIGURATION 
{
  $$ = new AST;
  $$->setName("config_decl_2");
  $$->setRuleNumber(31);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

config_decl_1 : 
{
  $$ = new AST;
  $$->setName("config_decl_1");
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  ;
  $$->setRuleNumber(32);
}
| config_decl_1  config_decl_3
{
  $1->addNode($2);
  $$ = $1;
}
;
config_decl_3 : config_decltve_item 
{
  $$ = new AST;
  $$->setName("config_decl_3");
  $$->setRuleNumber(33);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

package_decl : package_start package_decl_1 END package_decl_2 SEMICOLON 
{
  $$ = new AST;
  $$->setName("package_decl");
  $$->setRuleNumber(34);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
}
;

package_start : PACKAGE IDENTIFIER IS 
{
  $$ = new AST;
  $$->setName("package_start");
  $$->setRuleNumber(35);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

package_decl_2 : 
{
  $$ = new AST;
  $$->setName("package_decl_2");
  $$->setRuleNumber(36);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| IDENTIFIER 
{
  $$ = new AST;
  $$->setName("package_decl_2");
  $$->setRuleNumber(36);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| PACKAGE IDENTIFIER 
{
  $$ = new AST;
  $$->setName("package_decl_2");
  $$->setRuleNumber(36);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| PACKAGE 
{
  $$ = new AST;
  $$->setName("package_decl_2");
  $$->setRuleNumber(36);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

package_decl_1 : 
{
  $$ = new AST;
  $$->setName("package_decl_1");
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  ;
  $$->setRuleNumber(37);
}
| package_decl_1  package_decltve_item
{
  $1->addNode($2);
  $$ = $1;
}
;
package_body : pack_body_start package_body_1 END package_body_2 SEMICOLON 
{
  $$ = new AST;
  $$->setName("package_body");
  $$->setRuleNumber(38);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
}
;

pack_body_start : PACKAGE BODY IDENTIFIER IS 
{
  $$ = new AST;
  $$->setName("pack_body_start");
  $$->setRuleNumber(39);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
;

package_body_2 : 
{
  $$ = new AST;
  $$->setName("package_body_2");
  $$->setRuleNumber(40);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| IDENTIFIER 
{
  $$ = new AST;
  $$->setName("package_body_2");
  $$->setRuleNumber(40);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| PACKAGE BODY IDENTIFIER 
{
  $$ = new AST;
  $$->setName("package_body_2");
  $$->setRuleNumber(40);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| PACKAGE BODY 
{
  $$ = new AST;
  $$->setName("package_body_2");
  $$->setRuleNumber(40);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

package_body_1 : 
{
  $$ = new AST;
  $$->setName("package_body_1");
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  ;
  $$->setRuleNumber(41);
}
| package_body_1  package_body_decltve_item
{
  $1->addNode($2);
  $$ = $1;
}
;
common_decltve_item : type_decl 
{
  $$ = new AST;
  $$->setName("common_decltve_item");
  $$->setRuleNumber(42);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| subtype_decl 
{
  $$ = new AST;
  $$->setName("common_decltve_item");
  $$->setRuleNumber(42);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| constant_decl 
{
  $$ = new AST;
  $$->setName("common_decltve_item");
  $$->setRuleNumber(42);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| file_decl 
{
  $$ = new AST;
  $$->setName("common_decltve_item");
  $$->setRuleNumber(42);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| alias_decl 
{
  $$ = new AST;
  $$->setName("common_decltve_item");
  $$->setRuleNumber(42);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| subprog_decl 
{
  $$ = new AST;
  $$->setName("common_decltve_item");
  $$->setRuleNumber(42);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| use_clause 
{
  $$ = new AST;
  $$->setName("common_decltve_item");
  $$->setRuleNumber(42);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

entity_decltve_item : common_decltve_item 
{
  $$ = new AST;
  $$->setName("entity_decltve_item");
  $$->setRuleNumber(43);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| subprog_body 
{
  $$ = new AST;
  $$->setName("entity_decltve_item");
  $$->setRuleNumber(43);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| attribute_decl 
{
  $$ = new AST;
  $$->setName("entity_decltve_item");
  $$->setRuleNumber(43);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| attribute_spec 
{
  $$ = new AST;
  $$->setName("entity_decltve_item");
  $$->setRuleNumber(43);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| disconnection_spec 
{
  $$ = new AST;
  $$->setName("entity_decltve_item");
  $$->setRuleNumber(43);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| signal_decl 
{
  $$ = new AST;
  $$->setName("entity_decltve_item");
  $$->setRuleNumber(43);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

block_decltve_item : common_decltve_item 
{
  $$ = new AST;
  $$->setName("block_decltve_item");
  $$->setRuleNumber(44);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| subprog_body 
{
  $$ = new AST;
  $$->setName("block_decltve_item");
  $$->setRuleNumber(44);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| comp_decl 
{
  $$ = new AST;
  $$->setName("block_decltve_item");
  $$->setRuleNumber(44);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| attribute_decl 
{
  $$ = new AST;
  $$->setName("block_decltve_item");
  $$->setRuleNumber(44);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| attribute_spec 
{
  $$ = new AST;
  $$->setName("block_decltve_item");
  $$->setRuleNumber(44);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| config_spec 
{
  $$ = new AST;
  $$->setName("block_decltve_item");
  $$->setRuleNumber(44);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| disconnection_spec 
{
  $$ = new AST;
  $$->setName("block_decltve_item");
  $$->setRuleNumber(44);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| signal_decl 
{
  $$ = new AST;
  $$->setName("block_decltve_item");
  $$->setRuleNumber(44);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| shared_var_decl 
{
  $$ = new AST;
  $$->setName("block_decltve_item");
  $$->setRuleNumber(44);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

package_decltve_item : common_decltve_item 
{
  $$ = new AST;
  $$->setName("package_decltve_item");
  $$->setRuleNumber(45);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| comp_decl 
{
  $$ = new AST;
  $$->setName("package_decltve_item");
  $$->setRuleNumber(45);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| attribute_decl 
{
  $$ = new AST;
  $$->setName("package_decltve_item");
  $$->setRuleNumber(45);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| attribute_spec 
{
  $$ = new AST;
  $$->setName("package_decltve_item");
  $$->setRuleNumber(45);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| disconnection_spec 
{
  $$ = new AST;
  $$->setName("package_decltve_item");
  $$->setRuleNumber(45);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| signal_decl 
{
  $$ = new AST;
  $$->setName("package_decltve_item");
  $$->setRuleNumber(45);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

package_body_decltve_item : common_decltve_item 
{
  $$ = new AST;
  $$->setName("package_body_decltve_item");
  $$->setRuleNumber(46);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| subprog_body 
{
  $$ = new AST;
  $$->setName("package_body_decltve_item");
  $$->setRuleNumber(46);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

subprog_decltve_item : common_decltve_item 
{
  $$ = new AST;
  $$->setName("subprog_decltve_item");
  $$->setRuleNumber(47);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| subprog_body 
{
  $$ = new AST;
  $$->setName("subprog_decltve_item");
  $$->setRuleNumber(47);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| attribute_decl 
{
  $$ = new AST;
  $$->setName("subprog_decltve_item");
  $$->setRuleNumber(47);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| attribute_spec 
{
  $$ = new AST;
  $$->setName("subprog_decltve_item");
  $$->setRuleNumber(47);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| variable_decl 
{
  $$ = new AST;
  $$->setName("subprog_decltve_item");
  $$->setRuleNumber(47);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

procs_decltve_item : common_decltve_item 
{
  $$ = new AST;
  $$->setName("procs_decltve_item");
  $$->setRuleNumber(48);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| subprog_body 
{
  $$ = new AST;
  $$->setName("procs_decltve_item");
  $$->setRuleNumber(48);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| attribute_decl 
{
  $$ = new AST;
  $$->setName("procs_decltve_item");
  $$->setRuleNumber(48);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| attribute_spec 
{
  $$ = new AST;
  $$->setName("procs_decltve_item");
  $$->setRuleNumber(48);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| variable_decl 
{
  $$ = new AST;
  $$->setName("procs_decltve_item");
  $$->setRuleNumber(48);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

config_decltve_item : attribute_spec 
{
  $$ = new AST;
  $$->setName("config_decltve_item");
  $$->setRuleNumber(49);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| use_clause 
{
  $$ = new AST;
  $$->setName("config_decltve_item");
  $$->setRuleNumber(49);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

constant_decl : CONSTANT idf_list COLON subtype_indic constant_decl_1 SEMICOLON 
{
  $$ = new AST;
  $$->setName("constant_decl");
  $$->setRuleNumber(50);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
}
;

constant_decl_1 : 
{
  $$ = new AST;
  $$->setName("constant_decl_1");
  $$->setRuleNumber(51);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| VAR_ASSIGN expr 
{
  $$ = new AST;
  $$->setName("constant_decl_1");
  $$->setRuleNumber(51);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

signal_decl : SIGNAL idf_list COLON subtype_indic signal_decl_1 signal_decl_2 SEMICOLON 
{
  $$ = new AST;
  $$->setName("signal_decl");
  $$->setRuleNumber(52);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
  $$->addNode($7);
}
;

signal_decl_2 : 
{
  $$ = new AST;
  $$->setName("signal_decl_2");
  $$->setRuleNumber(53);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| VAR_ASSIGN expr 
{
  $$ = new AST;
  $$->setName("signal_decl_2");
  $$->setRuleNumber(53);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

signal_decl_1 : 
{
  $$ = new AST;
  $$->setName("signal_decl_1");
  $$->setRuleNumber(54);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| signal_kind 
{
  $$ = new AST;
  $$->setName("signal_decl_1");
  $$->setRuleNumber(54);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

shared_var_decl : SHARED variable_decl 
{
  $$ = new AST;
  $$->setName("shared_var_decl");
  $$->setRuleNumber(55);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

variable_decl : VARIABLE idf_list COLON subtype_indic variable_decl_1 SEMICOLON 
{
  $$ = new AST;
  $$->setName("variable_decl");
  $$->setRuleNumber(56);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
}
;

variable_decl_1 : 
{
  $$ = new AST;
  $$->setName("variable_decl_1");
  $$->setRuleNumber(57);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| VAR_ASSIGN expr 
{
  $$ = new AST;
  $$->setName("variable_decl_1");
  $$->setRuleNumber(57);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

subprog_decl : subprog_spec SEMICOLON 
{
  $$ = new AST;
  $$->setName("subprog_decl");
  $$->setRuleNumber(58);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

subprog_spec : PROCEDURE IDENTIFIER subprog_spec_2 
{
  $$ = new AST;
  $$->setName("subprog_spec");
  $$->setRuleNumber(59);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| FUNCTION designator subprog_spec_2 RETURN mark 
{
  $$ = new AST;
  $$->setName("subprog_spec");
  $$->setRuleNumber(59);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
}
| IMPURE FUNCTION designator subprog_spec_2 RETURN mark 
{
  $$ = new AST;
  $$->setName("subprog_spec");
  $$->setRuleNumber(59);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
}
| PURE FUNCTION designator subprog_spec_2 RETURN mark 
{
  $$ = new AST;
  $$->setName("subprog_spec");
  $$->setRuleNumber(59);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
}
;

subprog_spec_2 : 
{
  $$ = new AST;
  $$->setName("subprog_spec_2");
  $$->setRuleNumber(60);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| subprog_interf_list 
{
  $$ = new AST;
  $$->setName("subprog_spec_2");
  $$->setRuleNumber(60);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

subprog_body : subprog_spec IS subprog_body_1 VHDL_BEGIN seq_stats END subprog_body_2 SEMICOLON 
{
  $$ = new AST;
  $$->setName("subprog_body");
  $$->setRuleNumber(61);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
  $$->addNode($7);
  $$->addNode($8);
}
| subprog_spec IS subprog_body_1 VHDL_BEGIN seq_stats END PROCEDURE subprog_body_2 SEMICOLON 
{
  $$ = new AST;
  $$->setName("subprog_body");
  $$->setRuleNumber(61);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
  $$->addNode($7);
  $$->addNode($8);
  $$->addNode($9);
}
| subprog_spec IS subprog_body_1 VHDL_BEGIN seq_stats END FUNCTION subprog_body_2 SEMICOLON 
{
  $$ = new AST;
  $$->setName("subprog_body");
  $$->setRuleNumber(61);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
  $$->addNode($7);
  $$->addNode($8);
  $$->addNode($9);
}
;

subprog_body_2 : 
{
  $$ = new AST;
  $$->setName("subprog_body_2");
  $$->setRuleNumber(62);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| designator 
{
  $$ = new AST;
  $$->setName("subprog_body_2");
  $$->setRuleNumber(62);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

subprog_body_1 : 
{
  $$ = new AST;
  $$->setName("subprog_body_1");
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  ;
  $$->setRuleNumber(63);
}
| subprog_body_1  subprog_decltve_item
{
  $1->addNode($2);
  $$ = $1;
}
;
interf_list : LEFT_PAREN interf_list_1 RIGHT_PAREN 
{
  $$ = new AST;
  $$->setName("interf_list");
  $$->setRuleNumber(64);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

interf_list_1 : 
{
  $$ = new AST;
  $$->setName("interf_list_1");
  $$->setRuleNumber(65);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| interf_element
{
  $$ = new AST;
  $$->setName("interf_list_1");
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->setRuleNumber(65);
}
| interf_list_1 SEMICOLON interf_element
{
  $1->addNode($2);
  $1->addNode($3);
  $$ = $1;
}
;
interf_element : interf_element_1 idf_list COLON interf_element_2 subtype_indic interf_element_3 interf_element_4 
{
  $$ = new AST;
  $$->setName("interf_element");
  $$->setRuleNumber(66);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
  $$->addNode($7);
}
;

subprog_interf_list : LEFT_PAREN subprog_interf_list_1 RIGHT_PAREN 
{
  $$ = new AST;
  $$->setName("subprog_interf_list");
  $$->setRuleNumber(67);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

subprog_interf_list_1 : subprog_interf_element
{
  $$ = new AST;
  $$->setName("subprog_interf_list_1");
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->setRuleNumber(68);
}
| subprog_interf_list_1 SEMICOLON subprog_interf_element
{
  $1->addNode($2);
  $1->addNode($3);
  $$ = $1;
}
;
subprog_interf_element : interf_element 
{
  $$ = new AST;
  $$->setName("subprog_interf_element");
  $$->setRuleNumber(69);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| VHDL_FILE IDENTIFIER COLON subtype_indic 
{
  $$ = new AST;
  $$->setName("subprog_interf_element");
  $$->setRuleNumber(69);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
;

interf_element_4 : 
{
  $$ = new AST;
  $$->setName("interf_element_4");
  $$->setRuleNumber(70);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| VAR_ASSIGN expr 
{
  $$ = new AST;
  $$->setName("interf_element_4");
  $$->setRuleNumber(70);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

interf_element_3 : 
{
  $$ = new AST;
  $$->setName("interf_element_3");
  $$->setRuleNumber(71);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| BUFFER 
{
  $$ = new AST;
  $$->setName("interf_element_3");
  $$->setRuleNumber(71);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

interf_element_2 : 
{
  $$ = new AST;
  $$->setName("interf_element_2");
  $$->setRuleNumber(72);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| mode 
{
  $$ = new AST;
  $$->setName("interf_element_2");
  $$->setRuleNumber(72);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

interf_element_1 : 
{
  $$ = new AST;
  $$->setName("interf_element_1");
  $$->setRuleNumber(73);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| object_class 
{
  $$ = new AST;
  $$->setName("interf_element_1");
  $$->setRuleNumber(73);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

mode : IN 
{
  $$ = new AST;
  $$->setName("mode");
  $$->setRuleNumber(74);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| OUT 
{
  $$ = new AST;
  $$->setName("mode");
  $$->setRuleNumber(74);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| INOUT 
{
  $$ = new AST;
  $$->setName("mode");
  $$->setRuleNumber(74);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| BUFFER 
{
  $$ = new AST;
  $$->setName("mode");
  $$->setRuleNumber(74);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| LINKAGE 
{
  $$ = new AST;
  $$->setName("mode");
  $$->setRuleNumber(74);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

association_list : LEFT_PAREN association_list_1 RIGHT_PAREN 
{
  $$ = new AST;
  $$->setName("association_list");
  $$->setRuleNumber(75);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

association_list_1 : association_element
{
  $$ = new AST;
  $$->setName("association_list_1");
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->setRuleNumber(76);
}
| association_list_1 COMMA association_element
{
  $1->addNode($2);
  $1->addNode($3);
  $$ = $1;
}
;
association_element : formal_part ARROW actual_part 
{
  $$ = new AST;
  $$->setName("association_element");
  $$->setRuleNumber(77);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| actual_part 
{
  $$ = new AST;
  $$->setName("association_element");
  $$->setRuleNumber(77);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

formal_part : name 
{
  $$ = new AST;
  $$->setName("formal_part");
  $$->setRuleNumber(78);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

actual_part : expr 
{
  $$ = new AST;
  $$->setName("actual_part");
  $$->setRuleNumber(79);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| OPEN 
{
  $$ = new AST;
  $$->setName("actual_part");
  $$->setRuleNumber(79);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

gen_association_list : LEFT_PAREN gen_association_list_1 RIGHT_PAREN 
{
  $$ = new AST;
  $$->setName("gen_association_list");
  $$->setRuleNumber(80);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

gen_association_list_1 : gen_association_element
{
  $$ = new AST;
  $$->setName("gen_association_list_1");
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->setRuleNumber(81);
}
| gen_association_list_1 COMMA gen_association_element
{
  $1->addNode($2);
  $1->addNode($3);
  $$ = $1;
}
;
gen_association_element : expr 
{
  $$ = new AST;
  $$->setName("gen_association_element");
  $$->setRuleNumber(82);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| discrete_range1 
{
  $$ = new AST;
  $$->setName("gen_association_element");
  $$->setRuleNumber(82);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| name ARROW expr 
{
  $$ = new AST;
  $$->setName("gen_association_element");
  $$->setRuleNumber(82);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| OPEN 
{
  $$ = new AST;
  $$->setName("gen_association_element");
  $$->setRuleNumber(82);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

element_association_list : element_association
{
  $$ = new AST;
  $$->setName("element_association_list");
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->setRuleNumber(83);
}
| element_association_list COMMA element_association
{
  $1->addNode($2);
  $1->addNode($3);
  $$ = $1;
}
;
element_association : choices ARROW expr 
{
  $$ = new AST;
  $$->setName("element_association");
  $$->setRuleNumber(84);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| expr 
{
  $$ = new AST;
  $$->setName("element_association");
  $$->setRuleNumber(84);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

choices : choice 
{
  $$ = new AST;
  $$->setName("choices");
  $$->setRuleNumber(85);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| choice BAR choices 
{
  $$ = new AST;
  $$->setName("choices");
  $$->setRuleNumber(85);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

choice : expr 
{
  $$ = new AST;
  $$->setName("choice");
  $$->setRuleNumber(86);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| discrete_range1 
{
  $$ = new AST;
  $$->setName("choice");
  $$->setRuleNumber(86);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| OTHERS 
{
  $$ = new AST;
  $$->setName("choice");
  $$->setRuleNumber(86);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

mark : IDENTIFIER 
{
  $$ = new AST;
  $$->setName("mark");
  $$->setRuleNumber(87);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| sel_name 
{
  $$ = new AST;
  $$->setName("mark");
  $$->setRuleNumber(87);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

expr : and_relation 
{
  $$ = new AST;
  $$->setName("expr");
  $$->setRuleNumber(88);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| or_relation 
{
  $$ = new AST;
  $$->setName("expr");
  $$->setRuleNumber(88);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| xor_relation 
{
  $$ = new AST;
  $$->setName("expr");
  $$->setRuleNumber(88);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| xnor_relation 
{
  $$ = new AST;
  $$->setName("expr");
  $$->setRuleNumber(88);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| relation 
{
  $$ = new AST;
  $$->setName("expr");
  $$->setRuleNumber(88);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| relation NAND relation 
{
  $$ = new AST;
  $$->setName("expr");
  $$->setRuleNumber(88);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| relation NOR relation 
{
  $$ = new AST;
  $$->setName("expr");
  $$->setRuleNumber(88);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

and_relation : relation AND relation 
{
  $$ = new AST;
  $$->setName("and_relation");
  $$->setRuleNumber(89);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| and_relation AND relation 
{
  $$ = new AST;
  $$->setName("and_relation");
  $$->setRuleNumber(89);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

or_relation : relation OR relation 
{
  $$ = new AST;
  $$->setName("or_relation");
  $$->setRuleNumber(90);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| or_relation OR relation 
{
  $$ = new AST;
  $$->setName("or_relation");
  $$->setRuleNumber(90);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

xor_relation : relation XOR relation 
{
  $$ = new AST;
  $$->setName("xor_relation");
  $$->setRuleNumber(91);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| xor_relation XOR relation 
{
  $$ = new AST;
  $$->setName("xor_relation");
  $$->setRuleNumber(91);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

xnor_relation : relation XNOR relation 
{
  $$ = new AST;
  $$->setName("xnor_relation");
  $$->setRuleNumber(92);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| xnor_relation XNOR relation 
{
  $$ = new AST;
  $$->setName("xnor_relation");
  $$->setRuleNumber(92);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

relation : primary 
{
  $$ = new AST;
  $$->setName("relation");
  $$->setRuleNumber(93);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| PLUS primary %prec MED_PRECEDENCE
{
  $$ = new AST;
  $$->setName("relation");
  $$->setRuleNumber(93);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| MINUS primary %prec MED_PRECEDENCE
{
  $$ = new AST;
  $$->setName("relation");
  $$->setRuleNumber(93);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| ABS primary 
{
  $$ = new AST;
  $$->setName("relation");
  $$->setRuleNumber(93);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| NOT primary 
{
  $$ = new AST;
  $$->setName("relation");
  $$->setRuleNumber(93);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| relation MOD relation 
{
  $$ = new AST;
  $$->setName("relation");
  $$->setRuleNumber(93);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| relation REM relation 
{
  $$ = new AST;
  $$->setName("relation");
  $$->setRuleNumber(93);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| relation AMPERSAND relation 
{
  $$ = new AST;
  $$->setName("relation");
  $$->setRuleNumber(93);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| relation STAR relation 
{
  $$ = new AST;
  $$->setName("relation");
  $$->setRuleNumber(93);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| relation PLUS relation 
{
  $$ = new AST;
  $$->setName("relation");
  $$->setRuleNumber(93);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| relation MINUS relation 
{
  $$ = new AST;
  $$->setName("relation");
  $$->setRuleNumber(93);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| relation LESS_EQUAL relation 
{
  $$ = new AST;
  $$->setName("relation");
  $$->setRuleNumber(93);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| relation GREATER_EQUAL relation 
{
  $$ = new AST;
  $$->setName("relation");
  $$->setRuleNumber(93);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| relation LESS relation 
{
  $$ = new AST;
  $$->setName("relation");
  $$->setRuleNumber(93);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| relation GREATER relation 
{
  $$ = new AST;
  $$->setName("relation");
  $$->setRuleNumber(93);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| relation EQUAL relation 
{
  $$ = new AST;
  $$->setName("relation");
  $$->setRuleNumber(93);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| relation NOT_EQUAL relation 
{
  $$ = new AST;
  $$->setName("relation");
  $$->setRuleNumber(93);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| relation SLASH relation 
{
  $$ = new AST;
  $$->setName("relation");
  $$->setRuleNumber(93);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| relation SLL relation 
{
  $$ = new AST;
  $$->setName("relation");
  $$->setRuleNumber(93);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| relation SRL relation 
{
  $$ = new AST;
  $$->setName("relation");
  $$->setRuleNumber(93);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| relation SLA relation 
{
  $$ = new AST;
  $$->setName("relation");
  $$->setRuleNumber(93);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| relation SRA relation 
{
  $$ = new AST;
  $$->setName("relation");
  $$->setRuleNumber(93);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| relation ROL relation 
{
  $$ = new AST;
  $$->setName("relation");
  $$->setRuleNumber(93);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| relation ROR relation 
{
  $$ = new AST;
  $$->setName("relation");
  $$->setRuleNumber(93);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

primary : name 
{
  $$ = new AST;
  $$->setName("primary");
  $$->setRuleNumber(94);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| literal 
{
  $$ = new AST;
  $$->setName("primary");
  $$->setRuleNumber(94);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| aggregate 
{
  $$ = new AST;
  $$->setName("primary");
  $$->setRuleNumber(94);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| qualified_expr 
{
  $$ = new AST;
  $$->setName("primary");
  $$->setRuleNumber(94);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| allocator 
{
  $$ = new AST;
  $$->setName("primary");
  $$->setRuleNumber(94);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| LEFT_PAREN expr RIGHT_PAREN 
{
  $$ = new AST;
  $$->setName("primary");
  $$->setRuleNumber(94);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| primary POW primary 
{
  $$ = new AST;
  $$->setName("primary");
  $$->setRuleNumber(94);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

name : mark 
{
  $$ = new AST;
  $$->setName("name");
  $$->setRuleNumber(95);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| name2 
{
  $$ = new AST;
  $$->setName("name");
  $$->setRuleNumber(95);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

name2 : STRING_LIT 
{
  $$ = new AST;
  $$->setName("name2");
  $$->setRuleNumber(96);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| attribute_name 
{
  $$ = new AST;
  $$->setName("name2");
  $$->setRuleNumber(96);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| ifts_name 
{
  $$ = new AST;
  $$->setName("name2");
  $$->setRuleNumber(96);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

sel_name : name DOT suffix 
{
  $$ = new AST;
  $$->setName("sel_name");
  $$->setRuleNumber(97);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

ifts_name : mark gen_association_list 
{
  $$ = new AST;
  $$->setName("ifts_name");
  $$->setRuleNumber(98);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| name2 gen_association_list 
{
  $$ = new AST;
  $$->setName("ifts_name");
  $$->setRuleNumber(98);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

attribute_name : mark TICK IDENTIFIER 
{
  $$ = new AST;
  $$->setName("attribute_name");
  $$->setRuleNumber(99);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| name2 TICK IDENTIFIER 
{
  $$ = new AST;
  $$->setName("attribute_name");
  $$->setRuleNumber(99);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| mark TICK RANGE 
{
  $$ = new AST;
  $$->setName("attribute_name");
  $$->setRuleNumber(99);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| name2 TICK RANGE 
{
  $$ = new AST;
  $$->setName("attribute_name");
  $$->setRuleNumber(99);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

suffix : designator 
{
  $$ = new AST;
  $$->setName("suffix");
  $$->setRuleNumber(100);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| character_literal 
{
  $$ = new AST;
  $$->setName("suffix");
  $$->setRuleNumber(100);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| ALL 
{
  $$ = new AST;
  $$->setName("suffix");
  $$->setRuleNumber(100);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

aggregate : LEFT_PAREN element_association COMMA element_association_list RIGHT_PAREN 
{
  $$ = new AST;
  $$->setName("aggregate");
  $$->setRuleNumber(101);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
}
| LEFT_PAREN choices ARROW expr RIGHT_PAREN 
{
  $$ = new AST;
  $$->setName("aggregate");
  $$->setRuleNumber(101);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
}
;

qualified_expr : mark TICK LEFT_PAREN expr RIGHT_PAREN 
{
  $$ = new AST;
  $$->setName("qualified_expr");
  $$->setRuleNumber(102);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
}
| mark TICK aggregate 
{
  $$ = new AST;
  $$->setName("qualified_expr");
  $$->setRuleNumber(102);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

allocator : NEW mark mark allocator_1 
{
  $$ = new AST;
  $$->setName("allocator");
  $$->setRuleNumber(103);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
| NEW mark allocator_2 
{
  $$ = new AST;
  $$->setName("allocator");
  $$->setRuleNumber(103);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| NEW qualified_expr 
{
  $$ = new AST;
  $$->setName("allocator");
  $$->setRuleNumber(103);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

allocator_2 : 
{
  $$ = new AST;
  $$->setName("allocator_2");
  $$->setRuleNumber(104);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| gen_association_list 
{
  $$ = new AST;
  $$->setName("allocator_2");
  $$->setRuleNumber(104);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

allocator_1 : 
{
  $$ = new AST;
  $$->setName("allocator_1");
  $$->setRuleNumber(105);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| gen_association_list 
{
  $$ = new AST;
  $$->setName("allocator_1");
  $$->setRuleNumber(105);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

type_decl : TYPE IDENTIFIER type_decl_1 SEMICOLON 
{
  $$ = new AST;
  $$->setName("type_decl");
  $$->setRuleNumber(106);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
;

type_decl_1 : 
{
  $$ = new AST;
  $$->setName("type_decl_1");
  $$->setRuleNumber(107);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| IS type_definition 
{
  $$ = new AST;
  $$->setName("type_decl_1");
  $$->setRuleNumber(107);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

type_definition : enumeration_type_definition 
{
  $$ = new AST;
  $$->setName("type_definition");
  $$->setRuleNumber(108);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| range_constraint 
{
  $$ = new AST;
  $$->setName("type_definition");
  $$->setRuleNumber(108);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| physical_type_definition 
{
  $$ = new AST;
  $$->setName("type_definition");
  $$->setRuleNumber(108);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| unconstrained_array_definition 
{
  $$ = new AST;
  $$->setName("type_definition");
  $$->setRuleNumber(108);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| constrained_array_definition 
{
  $$ = new AST;
  $$->setName("type_definition");
  $$->setRuleNumber(108);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| record_type_definition 
{
  $$ = new AST;
  $$->setName("type_definition");
  $$->setRuleNumber(108);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| access_type_definition 
{
  $$ = new AST;
  $$->setName("type_definition");
  $$->setRuleNumber(108);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| file_type_definition 
{
  $$ = new AST;
  $$->setName("type_definition");
  $$->setRuleNumber(108);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

enumeration_type_definition : LEFT_PAREN enumeration_type_definition_1 RIGHT_PAREN 
{
  $$ = new AST;
  $$->setName("enumeration_type_definition");
  $$->setRuleNumber(109);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

enumeration_type_definition_1 : enumeration_literal
{
  $$ = new AST;
  $$->setName("enumeration_type_definition_1");
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->setRuleNumber(110);
}
| enumeration_type_definition_1 COMMA enumeration_literal
{
  $1->addNode($2);
  $1->addNode($3);
  $$ = $1;
}
;
physical_type_definition : range_constraint UNITS base_unit_decl physical_type_definition_1 END UNITS 
{
  $$ = new AST;
  $$->setName("physical_type_definition");
  $$->setRuleNumber(111);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
}
;

physical_type_definition_1 : 
{
  $$ = new AST;
  $$->setName("physical_type_definition_1");
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  ;
  $$->setRuleNumber(112);
}
| physical_type_definition_1  secondary_unit_decl
{
  $1->addNode($2);
  $$ = $1;
}
;
base_unit_decl : IDENTIFIER SEMICOLON 
{
  $$ = new AST;
  $$->setName("base_unit_decl");
  $$->setRuleNumber(113);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

secondary_unit_decl : IDENTIFIER EQUAL physical_literal SEMICOLON 
{
  $$ = new AST;
  $$->setName("secondary_unit_decl");
  $$->setRuleNumber(114);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
;

unconstrained_array_definition : ARRAY LEFT_PAREN unconstrained_array_definition_1 RIGHT_PAREN OF subtype_indic 
{
  $$ = new AST;
  $$->setName("unconstrained_array_definition");
  $$->setRuleNumber(115);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
}
;

unconstrained_array_definition_1 : index_subtype_definition
{
  $$ = new AST;
  $$->setName("unconstrained_array_definition_1");
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->setRuleNumber(116);
}
| unconstrained_array_definition_1 COMMA index_subtype_definition
{
  $1->addNode($2);
  $1->addNode($3);
  $$ = $1;
}
;
index_subtype_definition : mark RANGE BOX 
{
  $$ = new AST;
  $$->setName("index_subtype_definition");
  $$->setRuleNumber(117);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

constrained_array_definition : ARRAY index_constraint OF subtype_indic 
{
  $$ = new AST;
  $$->setName("constrained_array_definition");
  $$->setRuleNumber(118);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
;

record_type_definition : RECORD record_type_definition_1 record_type_definition_2 
{
  $$ = new AST;
  $$->setName("record_type_definition");
  $$->setRuleNumber(119);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

record_type_definition_2 : END RECORD 
{
  $$ = new AST;
  $$->setName("record_type_definition_2");
  $$->setRuleNumber(120);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| END RECORD IDENTIFIER 
{
  $$ = new AST;
  $$->setName("record_type_definition_2");
  $$->setRuleNumber(120);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

record_type_definition_1 : element_decl 
{
  $$ = new AST;
  $$->setName("record_type_definition_1");
  $$->setRuleNumber(121);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| record_type_definition_1 element_decl 
{
  $$ = new AST;
  $$->setName("record_type_definition_1");
  $$->setRuleNumber(121);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

element_decl : idf_list COLON subtype_indic SEMICOLON 
{
  $$ = new AST;
  $$->setName("element_decl");
  $$->setRuleNumber(122);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
;

access_type_definition : ACCESS subtype_indic 
{
  $$ = new AST;
  $$->setName("access_type_definition");
  $$->setRuleNumber(123);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

file_type_definition : VHDL_FILE OF mark 
{
  $$ = new AST;
  $$->setName("file_type_definition");
  $$->setRuleNumber(124);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

subtype_decl : SUBTYPE IDENTIFIER IS subtype_indic SEMICOLON 
{
  $$ = new AST;
  $$->setName("subtype_decl");
  $$->setRuleNumber(125);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
}
;

subtype_indic : mark gen_association_list_array 
{
  $$ = new AST;
  $$->setName("subtype_indic");
  $$->setRuleNumber(126);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| mark 
{
  $$ = new AST;
  $$->setName("subtype_indic");
  $$->setRuleNumber(126);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| subtype_indic1 
{
  $$ = new AST;
  $$->setName("subtype_indic");
  $$->setRuleNumber(126);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

gen_association_list_array : gen_association_list
{
  $$ = new AST;
  $$->setName("gen_association_list_array");
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->setRuleNumber(127);
}
| gen_association_list_array  gen_association_list
{
  $1->addNode($2);
  $$ = $1;
}
;
subtype_indic1 : mark mark range_constraint 
{
  $$ = new AST;
  $$->setName("subtype_indic1");
  $$->setRuleNumber(128);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| mark range_constraint 
{
  $$ = new AST;
  $$->setName("subtype_indic1");
  $$->setRuleNumber(128);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| mark mark gen_association_list 
{
  $$ = new AST;
  $$->setName("subtype_indic1");
  $$->setRuleNumber(128);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| mark mark 
{
  $$ = new AST;
  $$->setName("subtype_indic1");
  $$->setRuleNumber(128);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

range_constraint : RANGE range_spec 
{
  $$ = new AST;
  $$->setName("range_constraint");
  $$->setRuleNumber(129);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

index_constraint : LEFT_PAREN index_constraint_1 RIGHT_PAREN 
{
  $$ = new AST;
  $$->setName("index_constraint");
  $$->setRuleNumber(130);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

index_constraint_1 : discrete_range
{
  $$ = new AST;
  $$->setName("index_constraint_1");
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->setRuleNumber(131);
}
| index_constraint_1 COMMA discrete_range
{
  $1->addNode($2);
  $1->addNode($3);
  $$ = $1;
}
;
discrete_range : subtype_indic 
{
  $$ = new AST;
  $$->setName("discrete_range");
  $$->setRuleNumber(132);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| range_spec_discrete 
{
  $$ = new AST;
  $$->setName("discrete_range");
  $$->setRuleNumber(132);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

discrete_range1 : subtype_indic1 
{
  $$ = new AST;
  $$->setName("discrete_range1");
  $$->setRuleNumber(133);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| expr direction expr 
{
  $$ = new AST;
  $$->setName("discrete_range1");
  $$->setRuleNumber(133);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

range_spec_discrete : attribute_name 
{
  $$ = new AST;
  $$->setName("range_spec_discrete");
  $$->setRuleNumber(134);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| expr direction expr 
{
  $$ = new AST;
  $$->setName("range_spec_discrete");
  $$->setRuleNumber(134);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

range_spec : attribute_name 
{
  $$ = new AST;
  $$->setName("range_spec");
  $$->setRuleNumber(135);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| expr direction expr 
{
  $$ = new AST;
  $$->setName("range_spec");
  $$->setRuleNumber(135);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

direction : TO 
{
  $$ = new AST;
  $$->setName("direction");
  $$->setRuleNumber(136);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| DOWNTO 
{
  $$ = new AST;
  $$->setName("direction");
  $$->setRuleNumber(136);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

object_class : CONSTANT 
{
  $$ = new AST;
  $$->setName("object_class");
  $$->setRuleNumber(137);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| SIGNAL 
{
  $$ = new AST;
  $$->setName("object_class");
  $$->setRuleNumber(137);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| VARIABLE 
{
  $$ = new AST;
  $$->setName("object_class");
  $$->setRuleNumber(137);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

signal_kind : BUS 
{
  $$ = new AST;
  $$->setName("signal_kind");
  $$->setRuleNumber(138);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| REGISTER 
{
  $$ = new AST;
  $$->setName("signal_kind");
  $$->setRuleNumber(138);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

alias_decl : ALIAS IDENTIFIER alias_opt_subtype_indic IS name alias_opt_signature SEMICOLON 
{
  $$ = new AST;
  $$->setName("alias_decl");
  $$->setRuleNumber(139);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
  $$->addNode($7);
}
;

alias_opt_subtype_indic : COLON subtype_indic 
{
  $$ = new AST;
  $$->setName("alias_opt_subtype_indic");
  $$->setRuleNumber(140);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| 
{
  $$ = new AST;
  $$->setName("alias_opt_subtype_indic");
  $$->setRuleNumber(140);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
;

alias_opt_signature : LEFT_BRACKET opt_mark_list alias_opt_return RIGHT_BRACKET 
{
  $$ = new AST;
  $$->setName("alias_opt_signature");
  $$->setRuleNumber(141);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
| 
{
  $$ = new AST;
  $$->setName("alias_opt_signature");
  $$->setRuleNumber(141);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
;

mark_list : mark 
{
  $$ = new AST;
  $$->setName("mark_list");
  $$->setRuleNumber(142);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| mark_list COMMA mark 
{
  $$ = new AST;
  $$->setName("mark_list");
  $$->setRuleNumber(142);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

opt_mark_list : mark_list 
{
  $$ = new AST;
  $$->setName("opt_mark_list");
  $$->setRuleNumber(143);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| 
{
  $$ = new AST;
  $$->setName("opt_mark_list");
  $$->setRuleNumber(143);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
;

alias_opt_return : RETURN mark 
{
  $$ = new AST;
  $$->setName("alias_opt_return");
  $$->setRuleNumber(144);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| 
{
  $$ = new AST;
  $$->setName("alias_opt_return");
  $$->setRuleNumber(144);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
;

file_decl : file_decl87 
{
  $$ = new AST;
  $$->setName("file_decl");
  $$->setRuleNumber(145);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| file_decl93 
{
  $$ = new AST;
  $$->setName("file_decl");
  $$->setRuleNumber(145);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

file_decl_common : VHDL_FILE IDENTIFIER COLON subtype_indic 
{
  $$ = new AST;
  $$->setName("file_decl_common");
  $$->setRuleNumber(146);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
;

file_decl87 : file_decl_common IS file_decl_1 expr SEMICOLON 
{
  $$ = new AST;
  $$->setName("file_decl87");
  $$->setRuleNumber(147);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
}
;

file_decl93 : file_decl_common file_open_info 
{
  $$ = new AST;
  $$->setName("file_decl93");
  $$->setRuleNumber(148);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

file_open_info : SEMICOLON 
{
  $$ = new AST;
  $$->setName("file_open_info");
  $$->setRuleNumber(149);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| IS expr SEMICOLON 
{
  $$ = new AST;
  $$->setName("file_open_info");
  $$->setRuleNumber(149);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| OPEN enumeration_literal IS expr SEMICOLON 
{
  $$ = new AST;
  $$->setName("file_open_info");
  $$->setRuleNumber(149);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
}
;

file_decl_1 : mode 
{
  $$ = new AST;
  $$->setName("file_decl_1");
  $$->setRuleNumber(150);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

disconnection_spec : DISCONNECT signal_list COLON mark AFTER expr SEMICOLON 
{
  $$ = new AST;
  $$->setName("disconnection_spec");
  $$->setRuleNumber(151);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
  $$->addNode($7);
}
;

signal_list : signal_list_1 
{
  $$ = new AST;
  $$->setName("signal_list");
  $$->setRuleNumber(152);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| OTHERS 
{
  $$ = new AST;
  $$->setName("signal_list");
  $$->setRuleNumber(152);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| ALL 
{
  $$ = new AST;
  $$->setName("signal_list");
  $$->setRuleNumber(152);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

signal_list_1 : name
{
  $$ = new AST;
  $$->setName("signal_list_1");
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->setRuleNumber(153);
}
| signal_list_1 COMMA name
{
  $1->addNode($2);
  $1->addNode($3);
  $$ = $1;
}
;
attribute_decl : ATTRIBUTE IDENTIFIER COLON mark SEMICOLON 
{
  $$ = new AST;
  $$->setName("attribute_decl");
  $$->setRuleNumber(154);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
}
;

attribute_spec : ATTRIBUTE IDENTIFIER OF entity_spec IS expr SEMICOLON 
{
  $$ = new AST;
  $$->setName("attribute_spec");
  $$->setRuleNumber(155);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
  $$->addNode($7);
}
;

entity_spec : entity_name_list COLON entity_class 
{
  $$ = new AST;
  $$->setName("entity_spec");
  $$->setRuleNumber(156);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

entity_name_list : entity_name_list_1 
{
  $$ = new AST;
  $$->setName("entity_name_list");
  $$->setRuleNumber(157);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| OTHERS 
{
  $$ = new AST;
  $$->setName("entity_name_list");
  $$->setRuleNumber(157);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| ALL 
{
  $$ = new AST;
  $$->setName("entity_name_list");
  $$->setRuleNumber(157);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

entity_name_list_1 : designator
{
  $$ = new AST;
  $$->setName("entity_name_list_1");
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->setRuleNumber(158);
}
| entity_name_list_1 COMMA designator
{
  $1->addNode($2);
  $1->addNode($3);
  $$ = $1;
}
;
entity_class : ENTITY 
{
  $$ = new AST;
  $$->setName("entity_class");
  $$->setRuleNumber(159);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| ARCHITECTURE 
{
  $$ = new AST;
  $$->setName("entity_class");
  $$->setRuleNumber(159);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| PACKAGE 
{
  $$ = new AST;
  $$->setName("entity_class");
  $$->setRuleNumber(159);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| CONFIGURATION 
{
  $$ = new AST;
  $$->setName("entity_class");
  $$->setRuleNumber(159);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| COMPONENT 
{
  $$ = new AST;
  $$->setName("entity_class");
  $$->setRuleNumber(159);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| LABEL 
{
  $$ = new AST;
  $$->setName("entity_class");
  $$->setRuleNumber(159);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| TYPE 
{
  $$ = new AST;
  $$->setName("entity_class");
  $$->setRuleNumber(159);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| SUBTYPE 
{
  $$ = new AST;
  $$->setName("entity_class");
  $$->setRuleNumber(159);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| PROCEDURE 
{
  $$ = new AST;
  $$->setName("entity_class");
  $$->setRuleNumber(159);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| FUNCTION 
{
  $$ = new AST;
  $$->setName("entity_class");
  $$->setRuleNumber(159);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| SIGNAL 
{
  $$ = new AST;
  $$->setName("entity_class");
  $$->setRuleNumber(159);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| VARIABLE 
{
  $$ = new AST;
  $$->setName("entity_class");
  $$->setRuleNumber(159);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| CONSTANT 
{
  $$ = new AST;
  $$->setName("entity_class");
  $$->setRuleNumber(159);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

generation_scheme : if_scheme 
{
  $$ = new AST;
  $$->setName("generation_scheme");
  $$->setRuleNumber(160);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| for_scheme 
{
  $$ = new AST;
  $$->setName("generation_scheme");
  $$->setRuleNumber(160);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

if_scheme : IF expr 
{
  $$ = new AST;
  $$->setName("if_scheme");
  $$->setRuleNumber(161);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

for_scheme : FOR IDENTIFIER IN discrete_range 
{
  $$ = new AST;
  $$->setName("for_scheme");
  $$->setRuleNumber(162);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
;

concurrent_stats : 
{
  $$ = new AST;
  $$->setName("concurrent_stats");
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  ;
  $$->setRuleNumber(163);
}
| concurrent_stats  concurrent_stat
{
  $1->addNode($2);
  $$ = $1;
}
;
concurrent_stat : block_stat 
{
  $$ = new AST;
  $$->setName("concurrent_stat");
  $$->setRuleNumber(164);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| concurrent_assertion_stat 
{
  $$ = new AST;
  $$->setName("concurrent_stat");
  $$->setRuleNumber(164);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| concurrent_procedure_call 
{
  $$ = new AST;
  $$->setName("concurrent_stat");
  $$->setRuleNumber(164);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| concurrent_signal_assign_stat 
{
  $$ = new AST;
  $$->setName("concurrent_stat");
  $$->setRuleNumber(164);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| comp_inst_stat 
{
  $$ = new AST;
  $$->setName("concurrent_stat");
  $$->setRuleNumber(164);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| generate_stat_0 
{
  $$ = new AST;
  $$->setName("concurrent_stat");
  $$->setRuleNumber(164);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| procs_stat 
{
  $$ = new AST;
  $$->setName("concurrent_stat");
  $$->setRuleNumber(164);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

block_stat : IDENTIFIER COLON BLOCK block_stat_1 block_stat_2 block_stat_3 block_stat_4 VHDL_BEGIN concurrent_stats END BLOCK block_stat_5 SEMICOLON 
{
  $$ = new AST;
  $$->setName("block_stat");
  $$->setRuleNumber(165);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
  $$->addNode($7);
  $$->addNode($8);
  $$->addNode($9);
  $$->addNode($10);
  $$->addNode($11);
  $$->addNode($12);
  $$->addNode($13);
}
;

block_stat_5 : 
{
  $$ = new AST;
  $$->setName("block_stat_5");
  $$->setRuleNumber(166);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| IDENTIFIER 
{
  $$ = new AST;
  $$->setName("block_stat_5");
  $$->setRuleNumber(166);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

block_stat_4 : 
{
  $$ = new AST;
  $$->setName("block_stat_4");
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  ;
  $$->setRuleNumber(167);
}
| block_stat_4  block_decltve_item
{
  $1->addNode($2);
  $$ = $1;
}
;
block_stat_3 : 
{
  $$ = new AST;
  $$->setName("block_stat_3");
  $$->setRuleNumber(168);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| PORT interf_list SEMICOLON block_stat_7 
{
  $$ = new AST;
  $$->setName("block_stat_3");
  $$->setRuleNumber(168);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
;

block_stat_7 : 
{
  $$ = new AST;
  $$->setName("block_stat_7");
  $$->setRuleNumber(169);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| PORT MAP association_list SEMICOLON 
{
  $$ = new AST;
  $$->setName("block_stat_7");
  $$->setRuleNumber(169);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
;

block_stat_2 : 
{
  $$ = new AST;
  $$->setName("block_stat_2");
  $$->setRuleNumber(170);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| GENERIC interf_list SEMICOLON block_stat_8 
{
  $$ = new AST;
  $$->setName("block_stat_2");
  $$->setRuleNumber(170);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
;

block_stat_8 : 
{
  $$ = new AST;
  $$->setName("block_stat_8");
  $$->setRuleNumber(171);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| GENERIC MAP association_list SEMICOLON 
{
  $$ = new AST;
  $$->setName("block_stat_8");
  $$->setRuleNumber(171);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
;

block_stat_1 : 
{
  $$ = new AST;
  $$->setName("block_stat_1");
  $$->setRuleNumber(172);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| LEFT_PAREN expr RIGHT_PAREN 
{
  $$ = new AST;
  $$->setName("block_stat_1");
  $$->setRuleNumber(172);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

comp_inst_stat : comp_inst_stat_2 GENERIC MAP association_list comp_inst_stat_1 SEMICOLON 
{
  $$ = new AST;
  $$->setName("comp_inst_stat");
  $$->setRuleNumber(173);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
}
| comp_inst_stat_2 PORT MAP association_list SEMICOLON 
{
  $$ = new AST;
  $$->setName("comp_inst_stat");
  $$->setRuleNumber(173);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
}
;

comp_inst_stat_2 : IDENTIFIER COLON mark 
{
  $$ = new AST;
  $$->setName("comp_inst_stat_2");
  $$->setRuleNumber(174);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| IDENTIFIER COLON COMPONENT mark 
{
  $$ = new AST;
  $$->setName("comp_inst_stat_2");
  $$->setRuleNumber(174);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
| IDENTIFIER COLON ENTITY mark 
{
  $$ = new AST;
  $$->setName("comp_inst_stat_2");
  $$->setRuleNumber(174);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
;

comp_inst_stat_1 : 
{
  $$ = new AST;
  $$->setName("comp_inst_stat_1");
  $$->setRuleNumber(175);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| PORT MAP association_list 
{
  $$ = new AST;
  $$->setName("comp_inst_stat_1");
  $$->setRuleNumber(175);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

concurrent_assertion_stat : IDENTIFIER COLON assertion_stat 
{
  $$ = new AST;
  $$->setName("concurrent_assertion_stat");
  $$->setRuleNumber(176);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| assertion_stat 
{
  $$ = new AST;
  $$->setName("concurrent_assertion_stat");
  $$->setRuleNumber(176);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

concurrent_procedure_call : IDENTIFIER COLON procedure_call_stat 
{
  $$ = new AST;
  $$->setName("concurrent_procedure_call");
  $$->setRuleNumber(177);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| procedure_call_stat 
{
  $$ = new AST;
  $$->setName("concurrent_procedure_call");
  $$->setRuleNumber(177);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

concurrent_signal_assign_stat : IDENTIFIER COLON condal_signal_assign 
{
  $$ = new AST;
  $$->setName("concurrent_signal_assign_stat");
  $$->setRuleNumber(178);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| condal_signal_assign 
{
  $$ = new AST;
  $$->setName("concurrent_signal_assign_stat");
  $$->setRuleNumber(178);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| IDENTIFIER COLON sel_signal_assign 
{
  $$ = new AST;
  $$->setName("concurrent_signal_assign_stat");
  $$->setRuleNumber(178);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| sel_signal_assign 
{
  $$ = new AST;
  $$->setName("concurrent_signal_assign_stat");
  $$->setRuleNumber(178);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

condal_signal_assign : target LESS_EQUAL opts condal_wavefrms SEMICOLON 
{
  $$ = new AST;
  $$->setName("condal_signal_assign");
  $$->setRuleNumber(179);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
}
;

condal_wavefrms : wavefrm condal_wavefrms_1 
{
  $$ = new AST;
  $$->setName("condal_wavefrms");
  $$->setRuleNumber(180);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

condal_wavefrms_1 : 
{
  $$ = new AST;
  $$->setName("condal_wavefrms_1");
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  ;
  $$->setRuleNumber(181);
}
| condal_wavefrms_1  condal_wavefrms_2
{
  $1->addNode($2);
  $$ = $1;
}
;
condal_wavefrms_2 : WHEN expr ELSE wavefrm 
{
  $$ = new AST;
  $$->setName("condal_wavefrms_2");
  $$->setRuleNumber(182);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
| WHEN expr 
{
  $$ = new AST;
  $$->setName("condal_wavefrms_2");
  $$->setRuleNumber(182);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

wavefrm : wavefrm_element
{
  $$ = new AST;
  $$->setName("wavefrm");
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->setRuleNumber(183);
}
| wavefrm COMMA wavefrm_element
{
  $1->addNode($2);
  $1->addNode($3);
  $$ = $1;
}
;
wavefrm_element : expr wavefrm_element_1 
{
  $$ = new AST;
  $$->setName("wavefrm_element");
  $$->setRuleNumber(184);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

wavefrm_element_1 : 
{
  $$ = new AST;
  $$->setName("wavefrm_element_1");
  $$->setRuleNumber(185);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| AFTER expr 
{
  $$ = new AST;
  $$->setName("wavefrm_element_1");
  $$->setRuleNumber(185);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

target : name 
{
  $$ = new AST;
  $$->setName("target");
  $$->setRuleNumber(186);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| aggregate 
{
  $$ = new AST;
  $$->setName("target");
  $$->setRuleNumber(186);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

opts : opts_1 opts_2 
{
  $$ = new AST;
  $$->setName("opts");
  $$->setRuleNumber(187);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

opts_2 : 
{
  $$ = new AST;
  $$->setName("opts_2");
  $$->setRuleNumber(188);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| TRANSPORT 
{
  $$ = new AST;
  $$->setName("opts_2");
  $$->setRuleNumber(188);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

opts_1 : 
{
  $$ = new AST;
  $$->setName("opts_1");
  $$->setRuleNumber(189);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| GUARDED 
{
  $$ = new AST;
  $$->setName("opts_1");
  $$->setRuleNumber(189);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

sel_signal_assign : WITH expr SELECT target LESS_EQUAL opts sel_wavefrms SEMICOLON 
{
  $$ = new AST;
  $$->setName("sel_signal_assign");
  $$->setRuleNumber(190);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
  $$->addNode($7);
  $$->addNode($8);
}
;

sel_wavefrms : sel_wavefrms_2
{
  $$ = new AST;
  $$->setName("sel_wavefrms");
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->setRuleNumber(191);
}
| sel_wavefrms COMMA sel_wavefrms_2
{
  $1->addNode($2);
  $1->addNode($3);
  $$ = $1;
}
;
sel_wavefrms_2 : wavefrm WHEN choices 
{
  $$ = new AST;
  $$->setName("sel_wavefrms_2");
  $$->setRuleNumber(192);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

generate_label : IDENTIFIER COLON 
{
  $$ = new AST;
  $$->setName("generate_label");
  $$->setRuleNumber(193);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

generate_stat_0 : generate_label generation_scheme GENERATE generate_stat 
{
  $$ = new AST;
  $$->setName("generate_stat_0");
  $$->setRuleNumber(194);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
;

generate_stat : concurrent_stats END GENERATE generate_stat_1 SEMICOLON 
{
  $$ = new AST;
  $$->setName("generate_stat");
  $$->setRuleNumber(195);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
}
| block_stat_4 VHDL_BEGIN concurrent_stats END GENERATE generate_stat_1 SEMICOLON 
{
  $$ = new AST;
  $$->setName("generate_stat");
  $$->setRuleNumber(195);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
  $$->addNode($7);
}
;

generate_stat_1 : 
{
  $$ = new AST;
  $$->setName("generate_stat_1");
  $$->setRuleNumber(196);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| IDENTIFIER 
{
  $$ = new AST;
  $$->setName("generate_stat_1");
  $$->setRuleNumber(196);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

procs_stat : IDENTIFIER COLON procs_stat1 
{
  $$ = new AST;
  $$->setName("procs_stat");
  $$->setRuleNumber(197);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| procs_stat1 
{
  $$ = new AST;
  $$->setName("procs_stat");
  $$->setRuleNumber(197);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

procs_stat1 : PROCESS procs_stat1_1 procs_stat1_2 procs_stat1_3 VHDL_BEGIN seq_stats END PROCESS procs_stat1_4 SEMICOLON 
{
  $$ = new AST;
  $$->setName("procs_stat1");
  $$->setRuleNumber(198);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
  $$->addNode($7);
  $$->addNode($8);
  $$->addNode($9);
  $$->addNode($10);
}
;

procs_stat1_4 : 
{
  $$ = new AST;
  $$->setName("procs_stat1_4");
  $$->setRuleNumber(199);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| IDENTIFIER 
{
  $$ = new AST;
  $$->setName("procs_stat1_4");
  $$->setRuleNumber(199);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

procs_stat1_3 : 
{
  $$ = new AST;
  $$->setName("procs_stat1_3");
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  ;
  $$->setRuleNumber(200);
}
| procs_stat1_3  procs_decltve_item
{
  $1->addNode($2);
  $$ = $1;
}
;
procs_stat1_2 : 
{
  $$ = new AST;
  $$->setName("procs_stat1_2");
  $$->setRuleNumber(201);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| IS 
{
  $$ = new AST;
  $$->setName("procs_stat1_2");
  $$->setRuleNumber(201);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

procs_stat1_1 : 
{
  $$ = new AST;
  $$->setName("procs_stat1_1");
  $$->setRuleNumber(202);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| LEFT_PAREN sensitivity_list RIGHT_PAREN 
{
  $$ = new AST;
  $$->setName("procs_stat1_1");
  $$->setRuleNumber(202);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

sensitivity_list : name
{
  $$ = new AST;
  $$->setName("sensitivity_list");
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->setRuleNumber(203);
}
| sensitivity_list COMMA name
{
  $1->addNode($2);
  $1->addNode($3);
  $$ = $1;
}
;
seq_stats : 
{
  $$ = new AST;
  $$->setName("seq_stats");
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  ;
  $$->setRuleNumber(204);
}
| seq_stats  seq_stat
{
  $1->addNode($2);
  $$ = $1;
}
;
seq_stat : assertion_stat 
{
  $$ = new AST;
  $$->setName("seq_stat");
  $$->setRuleNumber(205);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| case_stat 
{
  $$ = new AST;
  $$->setName("seq_stat");
  $$->setRuleNumber(205);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| exit_stat 
{
  $$ = new AST;
  $$->setName("seq_stat");
  $$->setRuleNumber(205);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| if_stat 
{
  $$ = new AST;
  $$->setName("seq_stat");
  $$->setRuleNumber(205);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| loop_stat 
{
  $$ = new AST;
  $$->setName("seq_stat");
  $$->setRuleNumber(205);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| next_stat 
{
  $$ = new AST;
  $$->setName("seq_stat");
  $$->setRuleNumber(205);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| null_stat 
{
  $$ = new AST;
  $$->setName("seq_stat");
  $$->setRuleNumber(205);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| procedure_call_stat 
{
  $$ = new AST;
  $$->setName("seq_stat");
  $$->setRuleNumber(205);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| return_stat 
{
  $$ = new AST;
  $$->setName("seq_stat");
  $$->setRuleNumber(205);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| report_stat 
{
  $$ = new AST;
  $$->setName("seq_stat");
  $$->setRuleNumber(205);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| signal_assign_stat 
{
  $$ = new AST;
  $$->setName("seq_stat");
  $$->setRuleNumber(205);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| variable_assign_stat 
{
  $$ = new AST;
  $$->setName("seq_stat");
  $$->setRuleNumber(205);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| wait_stat 
{
  $$ = new AST;
  $$->setName("seq_stat");
  $$->setRuleNumber(205);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

assertion_stat : ASSERT expr assertion_stat_1 assertion_stat_2 SEMICOLON 
{
  $$ = new AST;
  $$->setName("assertion_stat");
  $$->setRuleNumber(206);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
}
;

assertion_stat_2 : 
{
  $$ = new AST;
  $$->setName("assertion_stat_2");
  $$->setRuleNumber(207);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| SEVERITY expr 
{
  $$ = new AST;
  $$->setName("assertion_stat_2");
  $$->setRuleNumber(207);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

assertion_stat_1 : 
{
  $$ = new AST;
  $$->setName("assertion_stat_1");
  $$->setRuleNumber(208);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| REPORT expr 
{
  $$ = new AST;
  $$->setName("assertion_stat_1");
  $$->setRuleNumber(208);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

case_stat : CASE expr IS case_stat_1 END CASE SEMICOLON 
{
  $$ = new AST;
  $$->setName("case_stat");
  $$->setRuleNumber(209);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
  $$->addNode($7);
}
;

case_stat_1 : case_stat_alternative 
{
  $$ = new AST;
  $$->setName("case_stat_1");
  $$->setRuleNumber(210);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| case_stat_1 case_stat_alternative 
{
  $$ = new AST;
  $$->setName("case_stat_1");
  $$->setRuleNumber(210);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

case_stat_alternative : WHEN choices ARROW seq_stats 
{
  $$ = new AST;
  $$->setName("case_stat_alternative");
  $$->setRuleNumber(211);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
;

exit_stat : EXIT exit_stat_1 exit_stat_2 SEMICOLON 
{
  $$ = new AST;
  $$->setName("exit_stat");
  $$->setRuleNumber(212);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
;

exit_stat_2 : 
{
  $$ = new AST;
  $$->setName("exit_stat_2");
  $$->setRuleNumber(213);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| WHEN expr 
{
  $$ = new AST;
  $$->setName("exit_stat_2");
  $$->setRuleNumber(213);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

exit_stat_1 : 
{
  $$ = new AST;
  $$->setName("exit_stat_1");
  $$->setRuleNumber(214);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| IDENTIFIER 
{
  $$ = new AST;
  $$->setName("exit_stat_1");
  $$->setRuleNumber(214);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

if_stat : IF expr THEN seq_stats if_stat_1 if_stat_2 END IF SEMICOLON 
{
  $$ = new AST;
  $$->setName("if_stat");
  $$->setRuleNumber(215);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
  $$->addNode($7);
  $$->addNode($8);
  $$->addNode($9);
}
;

if_stat_2 : 
{
  $$ = new AST;
  $$->setName("if_stat_2");
  $$->setRuleNumber(216);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| ELSE seq_stats 
{
  $$ = new AST;
  $$->setName("if_stat_2");
  $$->setRuleNumber(216);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

if_stat_1 : 
{
  $$ = new AST;
  $$->setName("if_stat_1");
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  ;
  $$->setRuleNumber(217);
}
| if_stat_1  if_stat_3
{
  $1->addNode($2);
  $$ = $1;
}
;
if_stat_3 : ELSIF expr THEN seq_stats 
{
  $$ = new AST;
  $$->setName("if_stat_3");
  $$->setRuleNumber(218);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
;

loop_stat : loop_for 
{
  $$ = new AST;
  $$->setName("loop_stat");
  $$->setRuleNumber(219);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| loop_infinite 
{
  $$ = new AST;
  $$->setName("loop_stat");
  $$->setRuleNumber(219);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| loop_while 
{
  $$ = new AST;
  $$->setName("loop_stat");
  $$->setRuleNumber(219);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

loop_for : loop_stat_1 FOR IDENTIFIER IN discrete_range LOOP seq_stats END LOOP loop_stat_3 SEMICOLON 
{
  $$ = new AST;
  $$->setName("loop_for");
  $$->setRuleNumber(220);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
  $$->addNode($7);
  $$->addNode($8);
  $$->addNode($9);
  $$->addNode($10);
  $$->addNode($11);
}
;

loop_infinite : loop_stat_1 LOOP seq_stats END LOOP loop_stat_3 SEMICOLON 
{
  $$ = new AST;
  $$->setName("loop_infinite");
  $$->setRuleNumber(221);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
  $$->addNode($7);
}
;

loop_while : loop_stat_1 WHILE expr LOOP seq_stats END LOOP loop_stat_3 SEMICOLON 
{
  $$ = new AST;
  $$->setName("loop_while");
  $$->setRuleNumber(222);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
  $$->addNode($7);
  $$->addNode($8);
  $$->addNode($9);
}
;

loop_stat_3 : 
{
  $$ = new AST;
  $$->setName("loop_stat_3");
  $$->setRuleNumber(223);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| IDENTIFIER 
{
  $$ = new AST;
  $$->setName("loop_stat_3");
  $$->setRuleNumber(223);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

loop_stat_1 : 
{
  $$ = new AST;
  $$->setName("loop_stat_1");
  $$->setRuleNumber(224);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| IDENTIFIER COLON 
{
  $$ = new AST;
  $$->setName("loop_stat_1");
  $$->setRuleNumber(224);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

next_stat : NEXT next_stat_1 next_stat_2 SEMICOLON 
{
  $$ = new AST;
  $$->setName("next_stat");
  $$->setRuleNumber(225);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
;

next_stat_2 : 
{
  $$ = new AST;
  $$->setName("next_stat_2");
  $$->setRuleNumber(226);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| WHEN expr 
{
  $$ = new AST;
  $$->setName("next_stat_2");
  $$->setRuleNumber(226);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

next_stat_1 : 
{
  $$ = new AST;
  $$->setName("next_stat_1");
  $$->setRuleNumber(227);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| IDENTIFIER 
{
  $$ = new AST;
  $$->setName("next_stat_1");
  $$->setRuleNumber(227);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

null_stat : VHDL_NULL SEMICOLON 
{
  $$ = new AST;
  $$->setName("null_stat");
  $$->setRuleNumber(228);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

procedure_call_stat : name SEMICOLON 
{
  $$ = new AST;
  $$->setName("procedure_call_stat");
  $$->setRuleNumber(229);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

return_stat : RETURN return_stat_1 SEMICOLON 
{
  $$ = new AST;
  $$->setName("return_stat");
  $$->setRuleNumber(230);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

return_stat_1 : 
{
  $$ = new AST;
  $$->setName("return_stat_1");
  $$->setRuleNumber(231);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| expr 
{
  $$ = new AST;
  $$->setName("return_stat_1");
  $$->setRuleNumber(231);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

report_stat : REPORT expr assertion_stat_2 SEMICOLON 
{
  $$ = new AST;
  $$->setName("report_stat");
  $$->setRuleNumber(232);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
| IDENTIFIER COLON REPORT expr assertion_stat_2 SEMICOLON 
{
  $$ = new AST;
  $$->setName("report_stat");
  $$->setRuleNumber(232);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
}
;

signal_assign_stat : target LESS_EQUAL signal_assign_stat_1 wavefrm SEMICOLON 
{
  $$ = new AST;
  $$->setName("signal_assign_stat");
  $$->setRuleNumber(233);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
}
;

signal_assign_stat_1 : 
{
  $$ = new AST;
  $$->setName("signal_assign_stat_1");
  $$->setRuleNumber(234);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| TRANSPORT 
{
  $$ = new AST;
  $$->setName("signal_assign_stat_1");
  $$->setRuleNumber(234);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

variable_assign_stat : target VAR_ASSIGN expr SEMICOLON 
{
  $$ = new AST;
  $$->setName("variable_assign_stat");
  $$->setRuleNumber(235);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
;

wait_stat : WAIT sensitivity_clause condition_clause timeout_clause SEMICOLON 
{
  $$ = new AST;
  $$->setName("wait_stat");
  $$->setRuleNumber(236);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
}
;

sensitivity_clause : 
{
  $$ = new AST;
  $$->setName("sensitivity_clause");
  $$->setRuleNumber(237);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| ON sensitivity_list 
{
  $$ = new AST;
  $$->setName("sensitivity_clause");
  $$->setRuleNumber(237);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

condition_clause : 
{
  $$ = new AST;
  $$->setName("condition_clause");
  $$->setRuleNumber(238);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| UNTIL expr 
{
  $$ = new AST;
  $$->setName("condition_clause");
  $$->setRuleNumber(238);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

timeout_clause : 
{
  $$ = new AST;
  $$->setName("timeout_clause");
  $$->setRuleNumber(239);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| FOR expr 
{
  $$ = new AST;
  $$->setName("timeout_clause");
  $$->setRuleNumber(239);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

comp_decl : COMPONENT IDENTIFIER comp_decl_1 comp_decl_2 comp_decl_3 
{
  $$ = new AST;
  $$->setName("comp_decl");
  $$->setRuleNumber(240);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
}
| COMPONENT IDENTIFIER IS comp_decl_1 comp_decl_2 comp_decl_3 
{
  $$ = new AST;
  $$->setName("comp_decl");
  $$->setRuleNumber(240);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
}
;

comp_decl_3 : END COMPONENT SEMICOLON 
{
  $$ = new AST;
  $$->setName("comp_decl_3");
  $$->setRuleNumber(241);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| END COMPONENT IDENTIFIER SEMICOLON 
{
  $$ = new AST;
  $$->setName("comp_decl_3");
  $$->setRuleNumber(241);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
;

comp_decl_2 : 
{
  $$ = new AST;
  $$->setName("comp_decl_2");
  $$->setRuleNumber(242);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| PORT interf_list SEMICOLON 
{
  $$ = new AST;
  $$->setName("comp_decl_2");
  $$->setRuleNumber(242);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

comp_decl_1 : 
{
  $$ = new AST;
  $$->setName("comp_decl_1");
  $$->setRuleNumber(243);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| GENERIC interf_list SEMICOLON 
{
  $$ = new AST;
  $$->setName("comp_decl_1");
  $$->setRuleNumber(243);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

block_config : FOR block_spec block_config_1 block_config_2 END FOR SEMICOLON 
{
  $$ = new AST;
  $$->setName("block_config");
  $$->setRuleNumber(244);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
  $$->addNode($7);
}
;

subblock_config : FOR block_spec block_config_1 block_config_2 END FOR SEMICOLON 
{
  $$ = new AST;
  $$->setName("subblock_config");
  $$->setRuleNumber(245);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
  $$->addNode($7);
}
;

block_config_2 : 
{
  $$ = new AST;
  $$->setName("block_config_2");
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  ;
  $$->setRuleNumber(246);
}
| block_config_2  config_item
{
  $1->addNode($2);
  $$ = $1;
}
;
block_config_1 : 
{
  $$ = new AST;
  $$->setName("block_config_1");
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  ;
  $$->setRuleNumber(247);
}
| block_config_1  use_clause
{
  $1->addNode($2);
  $$ = $1;
}
;
block_spec : IDENTIFIER block_spec_1 
{
  $$ = new AST;
  $$->setName("block_spec");
  $$->setRuleNumber(248);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| ALL 
{
  $$ = new AST;
  $$->setName("block_spec");
  $$->setRuleNumber(248);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

block_spec_1 : 
{
  $$ = new AST;
  $$->setName("block_spec_1");
  $$->setRuleNumber(249);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| LEFT_PAREN index_spec RIGHT_PAREN 
{
  $$ = new AST;
  $$->setName("block_spec_1");
  $$->setRuleNumber(249);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

index_spec : discrete_range 
{
  $$ = new AST;
  $$->setName("index_spec");
  $$->setRuleNumber(250);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| ABSTRACT_LIT 
{
  $$ = new AST;
  $$->setName("index_spec");
  $$->setRuleNumber(250);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

config_item : subblock_config 
{
  $$ = new AST;
  $$->setName("config_item");
  $$->setRuleNumber(251);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| comp_config 
{
  $$ = new AST;
  $$->setName("config_item");
  $$->setRuleNumber(251);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

comp_config : FOR comp_spec comp_config_1 comp_config_2 END FOR SEMICOLON 
{
  $$ = new AST;
  $$->setName("comp_config");
  $$->setRuleNumber(252);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
  $$->addNode($7);
}
;

comp_config_2 : 
{
  $$ = new AST;
  $$->setName("comp_config_2");
  $$->setRuleNumber(253);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| subblock_config 
{
  $$ = new AST;
  $$->setName("comp_config_2");
  $$->setRuleNumber(253);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

comp_config_1 : 
{
  $$ = new AST;
  $$->setName("comp_config_1");
  $$->setRuleNumber(254);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| USE binding_indic SEMICOLON 
{
  $$ = new AST;
  $$->setName("comp_config_1");
  $$->setRuleNumber(254);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

config_spec : FOR comp_spec USE binding_indic SEMICOLON 
{
  $$ = new AST;
  $$->setName("config_spec");
  $$->setRuleNumber(255);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
}
;

comp_spec : inst_list COLON IDENTIFIER 
{
  $$ = new AST;
  $$->setName("comp_spec");
  $$->setRuleNumber(256);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| inst_list COLON IDENTIFIER DOT IDENTIFIER 
{
  $$ = new AST;
  $$->setName("comp_spec");
  $$->setRuleNumber(256);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
}
| inst_list COLON IDENTIFIER DOT IDENTIFIER DOT IDENTIFIER 
{
  $$ = new AST;
  $$->setName("comp_spec");
  $$->setRuleNumber(256);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
  $$->addNode($7);
}
;

inst_list : idf_list 
{
  $$ = new AST;
  $$->setName("inst_list");
  $$->setRuleNumber(257);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| ALL 
{
  $$ = new AST;
  $$->setName("inst_list");
  $$->setRuleNumber(257);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
| OTHERS 
{
  $$ = new AST;
  $$->setName("inst_list");
  $$->setRuleNumber(257);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

binding_indic : entity_aspect binding_indic_1 binding_indic_2 
{
  $$ = new AST;
  $$->setName("binding_indic");
  $$->setRuleNumber(258);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

binding_indic_2 : 
{
  $$ = new AST;
  $$->setName("binding_indic_2");
  $$->setRuleNumber(259);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| PORT MAP association_list 
{
  $$ = new AST;
  $$->setName("binding_indic_2");
  $$->setRuleNumber(259);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

binding_indic_1 : 
{
  $$ = new AST;
  $$->setName("binding_indic_1");
  $$->setRuleNumber(260);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| GENERIC MAP association_list 
{
  $$ = new AST;
  $$->setName("binding_indic_1");
  $$->setRuleNumber(260);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

entity_aspect : ENTITY IDENTIFIER DOT IDENTIFIER entity_aspect_arch_name 
{
  $$ = new AST;
  $$->setName("entity_aspect");
  $$->setRuleNumber(261);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
}
| CONFIGURATION IDENTIFIER DOT IDENTIFIER 
{
  $$ = new AST;
  $$->setName("entity_aspect");
  $$->setRuleNumber(261);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
| OPEN 
{
  $$ = new AST;
  $$->setName("entity_aspect");
  $$->setRuleNumber(261);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
}
;

entity_aspect_arch_name : 
{
  $$ = new AST;
  $$->setName("entity_aspect_arch_name");
  $$->setRuleNumber(262);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
}
| LEFT_PAREN IDENTIFIER RIGHT_PAREN 
{
  $$ = new AST;
  $$->setName("entity_aspect_arch_name");
  $$->setRuleNumber(262);
  $$->line_number = vhdlline_number;
  $$->column_number = vhdlcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;



%%
