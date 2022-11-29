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
  int ariFilelex();
  int ariFileerror(const char * message);
  extern unsigned int ariFilecolumn_number;
  extern unsigned int ariFileline_number;
  #include "ASTTraversalariFile.h"
  #define YYSTYPE AST *
  
  std::string read_to_string(const std::string & lookFor,
                        bool consumeLookFor);

%}

%token HIERARCHY INFO END PORT GENERIC SIGNAL CONSTANT XRFP XRF ASSIGN TLN_FROM LIBRARY CONFIGURATION ARCHITECTURE COMPONENT STATEMENTS DECLARATIONS DECLARATIONSTOP RUBY_POST RUBY PYTHON_POST PYTHON REMOVE_PACKAGE ADD_PACKAGE MOVE_PACKAGE EXEC POST_EXEC IN OUT INOUT AUTO VARASSIGN RENAME_PORTS GROUP_COMMENT PORT_COMMENT KEEP_CASE LANGUAGE ADD_HEADER MOVE_HEADER REMOVE_HEADER CREATE SC_METHOD SC_THREAD CONFIG_IN_ARCH ENTITY_COMMENT ARCH_COMMENT INST_COMMENT FILE_HEADER IDENTIFIER




%%

__start__ : syntax
{
  ASTTraversalariFile::ast = *$1;
}
;

syntax : hierarchy info_list 
{
  $$ = new AST;
  $$->setName("syntax");
  $$->setRuleNumber(0);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

hierarchy : HIERARCHY IDENTIFIER opt_module_list opt_semicolon 
{
  $$ = new AST;
  $$->setName("hierarchy");
  $$->setRuleNumber(1);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
;

module_list : module
{
  $$ = new AST;
  $$->setName("module_list");
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->setRuleNumber(2);
}
| module_list  module
{
  $1->addNode($2);
  $$ = $1;
}
;
module : IDENTIFIER ':' IDENTIFIER opt_module_list ';' 
{
  $$ = new AST;
  $$->setName("module");
  $$->setRuleNumber(3);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(':'));
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode(new AST(';'));
}
;

opt_module_list : 
{
  $$ = new AST;
  $$->setName("opt_module_list");
  $$->setRuleNumber(4);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
}
| '{' module_list '}' 
{
  $$ = new AST;
  $$->setName("opt_module_list");
  $$->setRuleNumber(4);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode(new AST('{'));
  $$->addNode($2);
  $$->addNode(new AST('}'));
}
;

info_list : 
{
  $$ = new AST;
  $$->setName("info_list");
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  ;
  $$->setRuleNumber(5);
}
| info_list  info
{
  $1->addNode($2);
  $$ = $1;
}
;
info : INFO IDENTIFIER '{' info_line_list '}' opt_semicolon 
{
  $$ = new AST;
  $$->setName("info");
  $$->setRuleNumber(6);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST('{'));
  $$->addNode($4);
  $$->addNode(new AST('}'));
  $$->addNode($6);
}
;

opt_semicolon : ';' 
{
  $$ = new AST;
  $$->setName("opt_semicolon");
  $$->setRuleNumber(7);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode(new AST(';'));
}
| 
{
  $$ = new AST;
  $$->setName("opt_semicolon");
  $$->setRuleNumber(7);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
}
;

info_line_list : 
{
  $$ = new AST;
  $$->setName("info_line_list");
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  ;
  $$->setRuleNumber(8);
}
| info_line_list  info_line
{
  $1->addNode($2);
  $$ = $1;
}
;
info_line : port 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| tln_from 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| xrf 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| library 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| generic 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| signal 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| constant 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| configuration 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| architecture 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| statements 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| declarations 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| remove_package 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| add_package 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| move_package 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| exec_script 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| assign 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| declarationstop 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| component 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| rename_ports 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| group_comment 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| keep_case 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| language 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| create 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| add_header 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| move_header 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| post_exec_script 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| rubycode 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| sc_method 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| rubypostcode 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| xrfp 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| port_comment 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| entity_comment 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| arch_comment 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| inst_comment 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| sc_thread 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| config_in_arch 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| pythoncode 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| pythonpostcode 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| fileheader 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| remove_header 
{
  $$ = new AST;
  $$->setName("info_line");
  $$->setRuleNumber(9);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
;

statements : STATEMENTS { $$ = new AST(read_to_string("end statements", false)); } END STATEMENTS ';' 
{
  $$ = new AST;
  $$->setName("statements");
  $$->setRuleNumber(10);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode(new AST(';'));
}
;

declarations : DECLARATIONS { $$ = new AST(read_to_string("end declarations", false)); } END DECLARATIONS ';' 
{
  $$ = new AST;
  $$->setName("declarations");
  $$->setRuleNumber(11);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode(new AST(';'));
}
;

declarationstop : DECLARATIONSTOP { $$ = new AST(read_to_string("end declarationstop", false)); } END DECLARATIONSTOP ';' 
{
  $$ = new AST;
  $$->setName("declarationstop");
  $$->setRuleNumber(12);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode(new AST(';'));
}
;

signal : SIGNAL IDENTIFIER ':' { $$ = new AST(read_to_string(";", false)); } ';' 
{
  $$ = new AST;
  $$->setName("signal");
  $$->setRuleNumber(13);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST(':'));
  $$->addNode($4);
  $$->addNode(new AST(';'));
}
| SIGNAL IDENTIFIER ';' 
{
  $$ = new AST;
  $$->setName("signal");
  $$->setRuleNumber(13);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST(';'));
}
;

port : PORT opt_group_comment IDENTIFIER ':' direction { $$ = new AST(read_to_string(";", false)); } ';' 
{
  $$ = new AST;
  $$->setName("port");
  $$->setRuleNumber(14);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode(new AST(':'));
  $$->addNode($5);
  $$->addNode($6);
  $$->addNode(new AST(';'));
}
| PORT opt_group_comment IDENTIFIER ';' 
{
  $$ = new AST;
  $$->setName("port");
  $$->setRuleNumber(14);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode(new AST(';'));
}
;

opt_group_comment : 
{
  $$ = new AST;
  $$->setName("opt_group_comment");
  $$->setRuleNumber(15);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
}
| '[' { $$ = new AST(read_to_string("]", false)); } ']' 
{
  $$ = new AST;
  $$->setName("opt_group_comment");
  $$->setRuleNumber(15);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($2);
}
;

direction : IN 
{
  $$ = new AST;
  $$->setName("direction");
  $$->setRuleNumber(16);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| OUT 
{
  $$ = new AST;
  $$->setName("direction");
  $$->setRuleNumber(16);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| INOUT 
{
  $$ = new AST;
  $$->setName("direction");
  $$->setRuleNumber(16);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| AUTO 
{
  $$ = new AST;
  $$->setName("direction");
  $$->setRuleNumber(16);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
;

library : LIBRARY ':' IDENTIFIER ';' 
{
  $$ = new AST;
  $$->setName("library");
  $$->setRuleNumber(17);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(':'));
  $$->addNode($3);
  $$->addNode(new AST(';'));
}
;

configuration : CONFIGURATION IDENTIFIER ':' sub_configs ';' 
{
  $$ = new AST;
  $$->setName("configuration");
  $$->setRuleNumber(18);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST(':'));
  $$->addNode($4);
  $$->addNode(new AST(';'));
}
;

sub_configs : sub_config
{
  $$ = new AST;
  $$->setName("sub_configs");
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->setRuleNumber(19);
}
| sub_configs ',' sub_config
{
  $1->addNode($3);
  $$ = $1;
}
;
sub_config : IDENTIFIER '/' IDENTIFIER 
{
  $$ = new AST;
  $$->setName("sub_config");
  $$->setRuleNumber(20);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('/'));
  $$->addNode($3);
}
| IDENTIFIER '.' IDENTIFIER 
{
  $$ = new AST;
  $$->setName("sub_config");
  $$->setRuleNumber(20);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('.'));
  $$->addNode($3);
}
;

architecture : ARCHITECTURE ':' IDENTIFIER ';' 
{
  $$ = new AST;
  $$->setName("architecture");
  $$->setRuleNumber(21);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(':'));
  $$->addNode($3);
  $$->addNode(new AST(';'));
}
;

tln_from : TLN_FROM ':' { $$ = new AST(read_to_string(";", false)); } ';' 
{
  $$ = new AST;
  $$->setName("tln_from");
  $$->setRuleNumber(22);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(':'));
  $$->addNode($3);
  $$->addNode(new AST(';'));
}
;

constant : CONSTANT IDENTIFIER ':' { $$ = new AST(read_to_string(":=", false)); } VARASSIGN { $$ = new AST(read_to_string(";", false)); } ';' 
{
  $$ = new AST;
  $$->setName("constant");
  $$->setRuleNumber(23);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST(':'));
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
  $$->addNode(new AST(';'));
}
;

xrf : XRF selected_ident ':' componentports ';' 
{
  $$ = new AST;
  $$->setName("xrf");
  $$->setRuleNumber(24);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST(':'));
  $$->addNode($4);
  $$->addNode(new AST(';'));
}
;

componentports : componentport
{
  $$ = new AST;
  $$->setName("componentports");
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->setRuleNumber(25);
}
| componentports ',' componentport
{
  $1->addNode($3);
  $$ = $1;
}
;
componentport : IDENTIFIER '/' selected_ident 
{
  $$ = new AST;
  $$->setName("componentport");
  $$->setRuleNumber(26);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('/'));
  $$->addNode($3);
}
;

selected_ident : ident
{
  $$ = new AST;
  $$->setName("selected_ident");
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->setRuleNumber(27);
}
| selected_ident '.' ident
{
  $1->addNode(new AST('.'));
  $1->addNode($3);
  $$ = $1;
}
;
ident : IDENTIFIER 
{
  $$ = new AST;
  $$->setName("ident");
  $$->setRuleNumber(28);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
}
| IDENTIFIER slice 
{
  $$ = new AST;
  $$->setName("ident");
  $$->setRuleNumber(28);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

slice : '(' { $$ = new AST(read_to_string(")", false)); } ')' 
{
  $$ = new AST;
  $$->setName("slice");
  $$->setRuleNumber(29);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode(new AST('('));
  $$->addNode($2);
  $$->addNode(new AST(')'));
}
;

generic : GENERIC IDENTIFIER ':' { $$ = new AST(read_to_string(";", false)); } ';' 
{
  $$ = new AST;
  $$->setName("generic");
  $$->setRuleNumber(30);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST(':'));
  $$->addNode($4);
  $$->addNode(new AST(';'));
}
;

remove_package : REMOVE_PACKAGE ':' IDENTIFIER '.' selected_ident ';' 
{
  $$ = new AST;
  $$->setName("remove_package");
  $$->setRuleNumber(31);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(':'));
  $$->addNode($3);
  $$->addNode(new AST('.'));
  $$->addNode($5);
  $$->addNode(new AST(';'));
}
;

add_package : ADD_PACKAGE ':' IDENTIFIER '.' selected_ident ';' 
{
  $$ = new AST;
  $$->setName("add_package");
  $$->setRuleNumber(32);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(':'));
  $$->addNode($3);
  $$->addNode(new AST('.'));
  $$->addNode($5);
  $$->addNode(new AST(';'));
}
;

move_package : MOVE_PACKAGE ':' IDENTIFIER '.' selected_ident ';' 
{
  $$ = new AST;
  $$->setName("move_package");
  $$->setRuleNumber(33);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(':'));
  $$->addNode($3);
  $$->addNode(new AST('.'));
  $$->addNode($5);
  $$->addNode(new AST(';'));
}
;

add_header : ADD_HEADER ':' { $$ = new AST(read_to_string(";", false)); } ';' 
{
  $$ = new AST;
  $$->setName("add_header");
  $$->setRuleNumber(34);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(':'));
  $$->addNode($3);
  $$->addNode(new AST(';'));
}
;

move_header : MOVE_HEADER ':' { $$ = new AST(read_to_string(";", false)); } ';' 
{
  $$ = new AST;
  $$->setName("move_header");
  $$->setRuleNumber(35);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(':'));
  $$->addNode($3);
  $$->addNode(new AST(';'));
}
;

remove_header : REMOVE_HEADER ':' { $$ = new AST(read_to_string(";", false)); } ';' 
{
  $$ = new AST;
  $$->setName("remove_header");
  $$->setRuleNumber(36);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(':'));
  $$->addNode($3);
  $$->addNode(new AST(';'));
}
;

exec_script : EXEC ':' { $$ = new AST(read_to_string(";", false)); } ';' 
{
  $$ = new AST;
  $$->setName("exec_script");
  $$->setRuleNumber(37);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(':'));
  $$->addNode($3);
  $$->addNode(new AST(';'));
}
;

assign : ASSIGN { $$ = new AST(read_to_string(":", false)); } ':' componentports ';' 
{
  $$ = new AST;
  $$->setName("assign");
  $$->setRuleNumber(38);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST(':'));
  $$->addNode($4);
  $$->addNode(new AST(';'));
}
;

component : COMPONENT ':' IDENTIFIER '.' selected_ident ';' 
{
  $$ = new AST;
  $$->setName("component");
  $$->setRuleNumber(39);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(':'));
  $$->addNode($3);
  $$->addNode(new AST('.'));
  $$->addNode($5);
  $$->addNode(new AST(';'));
}
;

rename_ports : RENAME_PORTS IDENTIFIER opt_match ':' { $$ = new AST(read_to_string("=", false)); } '=' { $$ = new AST(read_to_string(";", false)); } ';' 
{
  $$ = new AST;
  $$->setName("rename_ports");
  $$->setRuleNumber(40);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode(new AST(':'));
  $$->addNode($5);
  $$->addNode(new AST('='));
  $$->addNode($7);
  $$->addNode(new AST(';'));
}
;

opt_match : '/' { $$ = new AST(read_to_string("/", false)); } '/' 
{
  $$ = new AST;
  $$->setName("opt_match");
  $$->setRuleNumber(41);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode(new AST('/'));
  $$->addNode($2);
  $$->addNode(new AST('/'));
}
| 
{
  $$ = new AST;
  $$->setName("opt_match");
  $$->setRuleNumber(41);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
}
;

group_comment : GROUP_COMMENT { $$ = new AST(read_to_string(":", false)); } ':' { $$ = new AST(read_to_string(";", false)); } ';' 
{
  $$ = new AST;
  $$->setName("group_comment");
  $$->setRuleNumber(42);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST(':'));
  $$->addNode($4);
  $$->addNode(new AST(';'));
}
;

port_comment : PORT_COMMENT { $$ = new AST(read_to_string(":", false)); } ':' { $$ = new AST(read_to_string(";", false)); } ';' 
{
  $$ = new AST;
  $$->setName("port_comment");
  $$->setRuleNumber(43);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST(':'));
  $$->addNode($4);
  $$->addNode(new AST(';'));
}
;

keep_case : KEEP_CASE ';' 
{
  $$ = new AST;
  $$->setName("keep_case");
  $$->setRuleNumber(44);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(';'));
}
;

language : LANGUAGE ':' IDENTIFIER ';' 
{
  $$ = new AST;
  $$->setName("language");
  $$->setRuleNumber(45);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(':'));
  $$->addNode($3);
  $$->addNode(new AST(';'));
}
;

create : CREATE IDENTIFIER { $$ = new AST(read_to_string("end create", false)); } END CREATE ';' 
{
  $$ = new AST;
  $$->setName("create");
  $$->setRuleNumber(46);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode(new AST(';'));
}
;

post_exec_script : POST_EXEC ':' { $$ = new AST(read_to_string(";", false)); } ';' 
{
  $$ = new AST;
  $$->setName("post_exec_script");
  $$->setRuleNumber(47);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(':'));
  $$->addNode($3);
  $$->addNode(new AST(';'));
}
;

rubycode : RUBY { $$ = new AST(read_to_string("end ruby", false)); } END RUBY ';' 
{
  $$ = new AST;
  $$->setName("rubycode");
  $$->setRuleNumber(48);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode(new AST(';'));
}
;

rubypostcode : RUBY_POST { $$ = new AST(read_to_string("end ruby", false)); } END RUBY ';' 
{
  $$ = new AST;
  $$->setName("rubypostcode");
  $$->setRuleNumber(49);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode(new AST(';'));
}
;

pythoncode : PYTHON { $$ = new AST(read_to_string("end python", false)); } END PYTHON ';' 
{
  $$ = new AST;
  $$->setName("pythoncode");
  $$->setRuleNumber(50);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode(new AST(';'));
}
;

pythonpostcode : PYTHON_POST { $$ = new AST(read_to_string("end python", false)); } END PYTHON ';' 
{
  $$ = new AST;
  $$->setName("pythonpostcode");
  $$->setRuleNumber(51);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode(new AST(';'));
}
;

fileheader : FILE_HEADER ':' { $$ = new AST(read_to_string(";", false)); } ';' 
{
  $$ = new AST;
  $$->setName("fileheader");
  $$->setRuleNumber(52);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(':'));
  $$->addNode($3);
  $$->addNode(new AST(';'));
}
;

sc_method : SC_METHOD IDENTIFIER '(' identifier_list ')' { $$ = new AST(read_to_string("end sc_method", false)); } END SC_METHOD ';' 
{
  $$ = new AST;
  $$->setName("sc_method");
  $$->setRuleNumber(53);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST('('));
  $$->addNode($4);
  $$->addNode(new AST(')'));
  $$->addNode($6);
  $$->addNode($7);
  $$->addNode($8);
  $$->addNode(new AST(';'));
}
;

identifier_list : 
{
  $$ = new AST;
  $$->setName("identifier_list");
  $$->setRuleNumber(54);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
}
| IDENTIFIER
{
  $$ = new AST;
  $$->setName("identifier_list");
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->setRuleNumber(54);
}
| identifier_list ',' IDENTIFIER
{
  $1->addNode($3);
  $$ = $1;
}
;
xrfp : XRFP selected_ident ':' componentports ';' 
{
  $$ = new AST;
  $$->setName("xrfp");
  $$->setRuleNumber(55);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST(':'));
  $$->addNode($4);
  $$->addNode(new AST(';'));
}
;

entity_comment : ENTITY_COMMENT ':' { $$ = new AST(read_to_string(";", false)); } ';' 
{
  $$ = new AST;
  $$->setName("entity_comment");
  $$->setRuleNumber(56);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(':'));
  $$->addNode($3);
  $$->addNode(new AST(';'));
}
;

arch_comment : ARCH_COMMENT ':' { $$ = new AST(read_to_string(";", false)); } ';' 
{
  $$ = new AST;
  $$->setName("arch_comment");
  $$->setRuleNumber(57);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(':'));
  $$->addNode($3);
  $$->addNode(new AST(';'));
}
;

inst_comment : INST_COMMENT IDENTIFIER ':' { $$ = new AST(read_to_string(";", false)); } ';' 
{
  $$ = new AST;
  $$->setName("inst_comment");
  $$->setRuleNumber(58);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST(':'));
  $$->addNode($4);
  $$->addNode(new AST(';'));
}
;

sc_thread : SC_THREAD IDENTIFIER '(' identifier_list ')' { $$ = new AST(read_to_string("end sc_thread", false)); } END SC_THREAD ';' 
{
  $$ = new AST;
  $$->setName("sc_thread");
  $$->setRuleNumber(59);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST('('));
  $$->addNode($4);
  $$->addNode(new AST(')'));
  $$->addNode($6);
  $$->addNode($7);
  $$->addNode($8);
  $$->addNode(new AST(';'));
}
;

config_in_arch : CONFIG_IN_ARCH ';' 
{
  $$ = new AST;
  $$->setName("config_in_arch");
  $$->setRuleNumber(60);
  $$->line_number = ariFileline_number;
  $$->column_number = ariFilecolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(';'));
}
;



%%
