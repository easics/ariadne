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
  int veriloglex();
  int verilogerror(const char * message);
  extern unsigned int verilogcolumn_number;
  extern unsigned int verilogline_number;
  #include "ASTTraversalverilog.h"
  #define YYSTYPE AST *
  #define YYDEBUG 1
  
%}

%token K_LS K_RS K_LE K_GE K_EG K_SG K_EQ K_NE K_CEQ K_CNE K_LOR K_LAND K_NXOR K_TRIGGER K_AT K_ALWAYS K_AND K_ASSIGN K_AUTOMATIC K_BIT K_BEGIN K_BOOL K_BUF K_BUFIF0 K_BUFIF1 K_CASE K_CASEX K_CASEZ K_CMOS K_DEASSIGN K_DEFAULT K_DEFPARAM K_DISABLE K_ELSE K_END K_ENDCASE K_ENDFUNCTION K_ENDMODULE K_ENDPRIMITIVE K_ENDSPECIFY K_ENDTABLE K_ENDTASK K_EVENT K_FOR K_FORCE K_FOREVER K_FORK K_FUNCTION K_GENVAR K_GENERATE K_ENDGENERATE K_HIGHZ0 K_HIGHZ1 K_IF K_INITIAL K_INOUT K_INPUT K_INTEGER K_JOIN K_LARGE K_LOCALPARAM K_LOGIC K_MEDIUM K_MODULE K_NAND K_NEGEDGE K_NMOS K_NOR K_NOT K_NOTIF0 K_NOTIF1 K_OR K_OUTPUT K_PARAMETER K_PMOS K_POSEDGE K_PRIMITIVE K_PULL0 K_PULL1 K_PULLDOWN K_PULLUP K_RCMOS K_REAL K_REALTIME K_REG K_RELEASE K_REPEAT K_RNMOS K_RPMOS K_RTRAN K_RTRANIF0 K_RTRANIF1 K_SIGNED K_UNSIGNED K_SMALL K_SPECIFY K_SPECPARAM K_STRONG0 K_STRONG1 K_SUPPLY0 K_SUPPLY1 K_TABLE K_TASK K_TIME K_TRAN K_TRANIF0 K_TRANIF1 K_TRI K_TRI0 K_TRI1 K_TRIAND K_TRIOR K_TRIREG K_WAIT K_WAND K_WEAK0 K_WEAK1 K_WHILE K_WIRE K_WREAL K_WOR K_XNOR K_XOR HIDENTIFIER IDENTIFIER PORTNAME KK_ATTRIBUTE SYSTEM_IDENTIFIER STRING NUMBER REALTIME
%token WISENT_LITERAL_STRING_0 "(*"
%token WISENT_LITERAL_STRING_1 "*)"
%token WISENT_LITERAL_STRING_2 "+:"
%token WISENT_LITERAL_STRING_3 "-:"


%right '?' ':'
%left K_LOR
%left K_LAND
%left '|'
%left '^' K_NXOR K_NOR
%left '&' K_NAND
%left K_EQ K_NE K_CEQ K_CNE
%left K_GE K_LE '<' '>'
%left K_LS K_RS
%left '+' '-'
%left '*' '/' '%'
%left UNARY_PREC
%nonassoc LESS_THAN_K_ELSE
%nonassoc K_ELSE


%%

__start__ : main
{
  ASTTraversalverilog::ast = *$1;
}
;

main : source_file 
{
  $$ = new AST;
  $$->setName("main");
  $$->setRuleNumber(0);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
;

source_file : 
{
  $$ = new AST;
  $$->setName("source_file");
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  ;
  $$->setRuleNumber(1);
}
| source_file  description
{
  $1->addNode($2);
  $$ = $1;
}
;
attribute_instance : "(*" attr_spec_list "*)" 
{
  $$ = new AST;
  $$->setName("attribute_instance");
  $$->setRuleNumber(2);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST("(*"));
  $$->addNode($2);
  $$->addNode(new AST("*)"));
}
;

attr_spec_list : attr_spec
{
  $$ = new AST;
  $$->setName("attr_spec_list");
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->setRuleNumber(3);
}
| attr_spec_list ',' attr_spec
{
  $1->addNode(new AST(','));
  $1->addNode($3);
  $$ = $1;
}
;
attr_spec : IDENTIFIER '=' expression 
{
  $$ = new AST;
  $$->setName("attr_spec");
  $$->setRuleNumber(4);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('='));
  $$->addNode($3);
}
;

attribute_instance_opt : 
{
  $$ = new AST;
  $$->setName("attribute_instance_opt");
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  ;
  $$->setRuleNumber(5);
}
| attribute_instance_opt  attribute_instance
{
  $1->addNode($2);
  $$ = $1;
}
;
block_item_decl : K_REG range register_variable_list ';' 
{
  $$ = new AST;
  $$->setName("block_item_decl");
  $$->setRuleNumber(6);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode(new AST(';'));
}
| K_REG register_variable_list ';' 
{
  $$ = new AST;
  $$->setName("block_item_decl");
  $$->setRuleNumber(6);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST(';'));
}
| K_REG K_SIGNED range register_variable_list ';' 
{
  $$ = new AST;
  $$->setName("block_item_decl");
  $$->setRuleNumber(6);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode(new AST(';'));
}
| K_REG K_SIGNED register_variable_list ';' 
{
  $$ = new AST;
  $$->setName("block_item_decl");
  $$->setRuleNumber(6);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode(new AST(';'));
}
| K_INTEGER register_variable_list ';' 
{
  $$ = new AST;
  $$->setName("block_item_decl");
  $$->setRuleNumber(6);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST(';'));
}
| K_TIME register_variable_list ';' 
{
  $$ = new AST;
  $$->setName("block_item_decl");
  $$->setRuleNumber(6);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST(';'));
}
| K_REAL list_of_variables ';' 
{
  $$ = new AST;
  $$->setName("block_item_decl");
  $$->setRuleNumber(6);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST(';'));
}
| K_REALTIME list_of_variables ';' 
{
  $$ = new AST;
  $$->setName("block_item_decl");
  $$->setRuleNumber(6);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST(';'));
}
| K_PARAMETER parameter_assign_list ';' 
{
  $$ = new AST;
  $$->setName("block_item_decl");
  $$->setRuleNumber(6);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST(';'));
}
| K_LOCALPARAM localparam_assign_list ';' 
{
  $$ = new AST;
  $$->setName("block_item_decl");
  $$->setRuleNumber(6);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST(';'));
}
;

block_item_decls : block_item_decl 
{
  $$ = new AST;
  $$->setName("block_item_decls");
  $$->setRuleNumber(7);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| block_item_decls block_item_decl 
{
  $$ = new AST;
  $$->setName("block_item_decls");
  $$->setRuleNumber(7);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

block_item_decls_opt : block_item_decls 
{
  $$ = new AST;
  $$->setName("block_item_decls_opt");
  $$->setRuleNumber(8);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| 
{
  $$ = new AST;
  $$->setName("block_item_decls_opt");
  $$->setRuleNumber(8);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
}
;

case_item : expression_list ':' statement_opt 
{
  $$ = new AST;
  $$->setName("case_item");
  $$->setRuleNumber(9);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(':'));
  $$->addNode($3);
}
| K_DEFAULT ':' statement_opt 
{
  $$ = new AST;
  $$->setName("case_item");
  $$->setRuleNumber(9);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(':'));
  $$->addNode($3);
}
| K_DEFAULT statement_opt 
{
  $$ = new AST;
  $$->setName("case_item");
  $$->setRuleNumber(9);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

case_items : case_items case_item 
{
  $$ = new AST;
  $$->setName("case_items");
  $$->setRuleNumber(10);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| case_item 
{
  $$ = new AST;
  $$->setName("case_items");
  $$->setRuleNumber(10);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
;

charge_strength : '(' K_SMALL ')' 
{
  $$ = new AST;
  $$->setName("charge_strength");
  $$->setRuleNumber(11);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('('));
  $$->addNode($2);
  $$->addNode(new AST(')'));
}
| '(' K_MEDIUM ')' 
{
  $$ = new AST;
  $$->setName("charge_strength");
  $$->setRuleNumber(11);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('('));
  $$->addNode($2);
  $$->addNode(new AST(')'));
}
| '(' K_LARGE ')' 
{
  $$ = new AST;
  $$->setName("charge_strength");
  $$->setRuleNumber(11);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('('));
  $$->addNode($2);
  $$->addNode(new AST(')'));
}
;

charge_strength_opt : charge_strength 
{
  $$ = new AST;
  $$->setName("charge_strength_opt");
  $$->setRuleNumber(12);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| 
{
  $$ = new AST;
  $$->setName("charge_strength_opt");
  $$->setRuleNumber(12);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
}
;

defparam_assign : identifier '=' expression 
{
  $$ = new AST;
  $$->setName("defparam_assign");
  $$->setRuleNumber(13);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('='));
  $$->addNode($3);
}
;

defparam_assign_list : defparam_assign 
{
  $$ = new AST;
  $$->setName("defparam_assign_list");
  $$->setRuleNumber(14);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| range defparam_assign 
{
  $$ = new AST;
  $$->setName("defparam_assign_list");
  $$->setRuleNumber(14);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| defparam_assign_list ',' defparam_assign 
{
  $$ = new AST;
  $$->setName("defparam_assign_list");
  $$->setRuleNumber(14);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(','));
  $$->addNode($3);
}
;

delay1 : '#' delay_value_simple 
{
  $$ = new AST;
  $$->setName("delay1");
  $$->setRuleNumber(15);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('#'));
  $$->addNode($2);
}
| '#' '(' delay_value ')' 
{
  $$ = new AST;
  $$->setName("delay1");
  $$->setRuleNumber(15);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('#'));
  $$->addNode(new AST('('));
  $$->addNode($3);
  $$->addNode(new AST(')'));
}
;

delay3 : '#' delay_value_simple 
{
  $$ = new AST;
  $$->setName("delay3");
  $$->setRuleNumber(16);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('#'));
  $$->addNode($2);
}
| '#' '(' delay_value ')' 
{
  $$ = new AST;
  $$->setName("delay3");
  $$->setRuleNumber(16);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('#'));
  $$->addNode(new AST('('));
  $$->addNode($3);
  $$->addNode(new AST(')'));
}
| '#' '(' delay_value ',' delay_value ')' 
{
  $$ = new AST;
  $$->setName("delay3");
  $$->setRuleNumber(16);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('#'));
  $$->addNode(new AST('('));
  $$->addNode($3);
  $$->addNode(new AST(','));
  $$->addNode($5);
  $$->addNode(new AST(')'));
}
| '#' '(' delay_value ',' delay_value ',' delay_value ')' 
{
  $$ = new AST;
  $$->setName("delay3");
  $$->setRuleNumber(16);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('#'));
  $$->addNode(new AST('('));
  $$->addNode($3);
  $$->addNode(new AST(','));
  $$->addNode($5);
  $$->addNode(new AST(','));
  $$->addNode($7);
  $$->addNode(new AST(')'));
}
;

delay3_opt : delay3 
{
  $$ = new AST;
  $$->setName("delay3_opt");
  $$->setRuleNumber(17);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| 
{
  $$ = new AST;
  $$->setName("delay3_opt");
  $$->setRuleNumber(17);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
}
;

delay_value : expression 
{
  $$ = new AST;
  $$->setName("delay_value");
  $$->setRuleNumber(18);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| expression ':' expression ':' expression 
{
  $$ = new AST;
  $$->setName("delay_value");
  $$->setRuleNumber(18);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(':'));
  $$->addNode($3);
  $$->addNode(new AST(':'));
  $$->addNode($5);
}
;

delay_value_simple : NUMBER 
{
  $$ = new AST;
  $$->setName("delay_value_simple");
  $$->setRuleNumber(19);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| REALTIME 
{
  $$ = new AST;
  $$->setName("delay_value_simple");
  $$->setRuleNumber(19);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| IDENTIFIER 
{
  $$ = new AST;
  $$->setName("delay_value_simple");
  $$->setRuleNumber(19);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
;

description : module 
{
  $$ = new AST;
  $$->setName("description");
  $$->setRuleNumber(20);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| udp_primitive 
{
  $$ = new AST;
  $$->setName("description");
  $$->setRuleNumber(20);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
;

drive_strength : '(' dr_strength0 ',' dr_strength1 ')' 
{
  $$ = new AST;
  $$->setName("drive_strength");
  $$->setRuleNumber(21);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('('));
  $$->addNode($2);
  $$->addNode(new AST(','));
  $$->addNode($4);
  $$->addNode(new AST(')'));
}
| '(' dr_strength1 ',' dr_strength0 ')' 
{
  $$ = new AST;
  $$->setName("drive_strength");
  $$->setRuleNumber(21);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('('));
  $$->addNode($2);
  $$->addNode(new AST(','));
  $$->addNode($4);
  $$->addNode(new AST(')'));
}
| '(' dr_strength0 ',' K_HIGHZ1 ')' 
{
  $$ = new AST;
  $$->setName("drive_strength");
  $$->setRuleNumber(21);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('('));
  $$->addNode($2);
  $$->addNode(new AST(','));
  $$->addNode($4);
  $$->addNode(new AST(')'));
}
| '(' dr_strength1 ',' K_HIGHZ0 ')' 
{
  $$ = new AST;
  $$->setName("drive_strength");
  $$->setRuleNumber(21);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('('));
  $$->addNode($2);
  $$->addNode(new AST(','));
  $$->addNode($4);
  $$->addNode(new AST(')'));
}
| '(' K_HIGHZ1 ',' dr_strength0 ')' 
{
  $$ = new AST;
  $$->setName("drive_strength");
  $$->setRuleNumber(21);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('('));
  $$->addNode($2);
  $$->addNode(new AST(','));
  $$->addNode($4);
  $$->addNode(new AST(')'));
}
| '(' K_HIGHZ0 ',' dr_strength1 ')' 
{
  $$ = new AST;
  $$->setName("drive_strength");
  $$->setRuleNumber(21);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('('));
  $$->addNode($2);
  $$->addNode(new AST(','));
  $$->addNode($4);
  $$->addNode(new AST(')'));
}
;

drive_strength_opt : drive_strength 
{
  $$ = new AST;
  $$->setName("drive_strength_opt");
  $$->setRuleNumber(22);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| 
{
  $$ = new AST;
  $$->setName("drive_strength_opt");
  $$->setRuleNumber(22);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
}
;

dr_strength0 : K_SUPPLY0 
{
  $$ = new AST;
  $$->setName("dr_strength0");
  $$->setRuleNumber(23);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_STRONG0 
{
  $$ = new AST;
  $$->setName("dr_strength0");
  $$->setRuleNumber(23);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_PULL0 
{
  $$ = new AST;
  $$->setName("dr_strength0");
  $$->setRuleNumber(23);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_WEAK0 
{
  $$ = new AST;
  $$->setName("dr_strength0");
  $$->setRuleNumber(23);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
;

dr_strength1 : K_SUPPLY1 
{
  $$ = new AST;
  $$->setName("dr_strength1");
  $$->setRuleNumber(24);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_STRONG1 
{
  $$ = new AST;
  $$->setName("dr_strength1");
  $$->setRuleNumber(24);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_PULL1 
{
  $$ = new AST;
  $$->setName("dr_strength1");
  $$->setRuleNumber(24);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_WEAK1 
{
  $$ = new AST;
  $$->setName("dr_strength1");
  $$->setRuleNumber(24);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
;

event_control : K_AT IDENTIFIER 
{
  $$ = new AST;
  $$->setName("event_control");
  $$->setRuleNumber(25);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| K_AT '(' event_expression_list ')' 
{
  $$ = new AST;
  $$->setName("event_control");
  $$->setRuleNumber(25);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('('));
  $$->addNode($3);
  $$->addNode(new AST(')'));
}
| K_AT '*' 
{
  $$ = new AST;
  $$->setName("event_control");
  $$->setRuleNumber(25);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('*'));
}
| K_AT '(' '*' ')' 
{
  $$ = new AST;
  $$->setName("event_control");
  $$->setRuleNumber(25);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('('));
  $$->addNode(new AST('*'));
  $$->addNode(new AST(')'));
}
| K_AT "(*" ')' 
{
  $$ = new AST;
  $$->setName("event_control");
  $$->setRuleNumber(25);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST("(*"));
  $$->addNode(new AST(')'));
}
;

event_expression_list : event_expression 
{
  $$ = new AST;
  $$->setName("event_expression_list");
  $$->setRuleNumber(26);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| event_expression_list K_OR event_expression 
{
  $$ = new AST;
  $$->setName("event_expression_list");
  $$->setRuleNumber(26);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| event_expression_list ',' event_expression 
{
  $$ = new AST;
  $$->setName("event_expression_list");
  $$->setRuleNumber(26);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(','));
  $$->addNode($3);
}
;

event_expression : K_POSEDGE expression 
{
  $$ = new AST;
  $$->setName("event_expression");
  $$->setRuleNumber(27);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| K_NEGEDGE expression 
{
  $$ = new AST;
  $$->setName("event_expression");
  $$->setRuleNumber(27);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| expression 
{
  $$ = new AST;
  $$->setName("event_expression");
  $$->setRuleNumber(27);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
;

expression : expr_primary 
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| '+' expr_primary %prec UNARY_PREC
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('+'));
  $$->addNode($2);
}
| '-' expr_primary %prec UNARY_PREC
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('-'));
  $$->addNode($2);
}
| '~' expr_primary %prec UNARY_PREC
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('~'));
  $$->addNode($2);
}
| '&' expr_primary %prec UNARY_PREC
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('&'));
  $$->addNode($2);
}
| '!' expr_primary %prec UNARY_PREC
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('!'));
  $$->addNode($2);
}
| '|' expr_primary %prec UNARY_PREC
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('|'));
  $$->addNode($2);
}
| '^' expr_primary %prec UNARY_PREC
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('^'));
  $$->addNode($2);
}
| K_NAND expr_primary %prec UNARY_PREC
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| K_NOR expr_primary %prec UNARY_PREC
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| K_NXOR expr_primary %prec UNARY_PREC
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| expression '^' expression 
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('^'));
  $$->addNode($3);
}
| expression '*' expression 
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('*'));
  $$->addNode($3);
}
| expression '/' expression 
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('/'));
  $$->addNode($3);
}
| expression '%' expression 
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('%'));
  $$->addNode($3);
}
| expression '+' expression 
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('+'));
  $$->addNode($3);
}
| expression '-' expression 
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('-'));
  $$->addNode($3);
}
| expression '&' expression 
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('&'));
  $$->addNode($3);
}
| expression '|' expression 
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('|'));
  $$->addNode($3);
}
| expression K_NOR expression 
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| expression K_NXOR expression 
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| expression '<' expression 
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('<'));
  $$->addNode($3);
}
| expression '>' expression 
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('>'));
  $$->addNode($3);
}
| expression K_LS expression 
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| expression K_RS expression 
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| expression K_EQ expression 
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| expression K_CEQ expression 
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| expression K_LE expression 
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| expression K_GE expression 
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| expression K_NE expression 
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| expression K_CNE expression 
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| expression K_LOR expression 
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| expression K_LAND expression 
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| expression '?' expression ':' expression 
{
  $$ = new AST;
  $$->setName("expression");
  $$->setRuleNumber(28);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('?'));
  $$->addNode($3);
  $$->addNode(new AST(':'));
  $$->addNode($5);
}
;

expression_list : expression_list ',' expression 
{
  $$ = new AST;
  $$->setName("expression_list");
  $$->setRuleNumber(29);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(','));
  $$->addNode($3);
}
| expression 
{
  $$ = new AST;
  $$->setName("expression_list");
  $$->setRuleNumber(29);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| 
{
  $$ = new AST;
  $$->setName("expression_list");
  $$->setRuleNumber(29);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
}
| expression_list ',' 
{
  $$ = new AST;
  $$->setName("expression_list");
  $$->setRuleNumber(29);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(','));
}
;

expr_primary : NUMBER 
{
  $$ = new AST;
  $$->setName("expr_primary");
  $$->setRuleNumber(30);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| REALTIME 
{
  $$ = new AST;
  $$->setName("expr_primary");
  $$->setRuleNumber(30);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| STRING 
{
  $$ = new AST;
  $$->setName("expr_primary");
  $$->setRuleNumber(30);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| identifier 
{
  $$ = new AST;
  $$->setName("expr_primary");
  $$->setRuleNumber(30);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| SYSTEM_IDENTIFIER 
{
  $$ = new AST;
  $$->setName("expr_primary");
  $$->setRuleNumber(30);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| identifier braced_expression_list 
{
  $$ = new AST;
  $$->setName("expr_primary");
  $$->setRuleNumber(30);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| identifier braced_expression_list '[' range_expression ']' 
{
  $$ = new AST;
  $$->setName("expr_primary");
  $$->setRuleNumber(30);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST('['));
  $$->addNode($4);
  $$->addNode(new AST(']'));
}
| identifier '[' range_expression ']' 
{
  $$ = new AST;
  $$->setName("expr_primary");
  $$->setRuleNumber(30);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('['));
  $$->addNode($3);
  $$->addNode(new AST(']'));
}
| identifier '(' expression_list ')' 
{
  $$ = new AST;
  $$->setName("expr_primary");
  $$->setRuleNumber(30);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('('));
  $$->addNode($3);
  $$->addNode(new AST(')'));
}
| SYSTEM_IDENTIFIER '(' expression_list ')' 
{
  $$ = new AST;
  $$->setName("expr_primary");
  $$->setRuleNumber(30);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('('));
  $$->addNode($3);
  $$->addNode(new AST(')'));
}
| '(' expression ')' 
{
  $$ = new AST;
  $$->setName("expr_primary");
  $$->setRuleNumber(30);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('('));
  $$->addNode($2);
  $$->addNode(new AST(')'));
}
| '{' expression_list '}' 
{
  $$ = new AST;
  $$->setName("expr_primary");
  $$->setRuleNumber(30);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('{'));
  $$->addNode($2);
  $$->addNode(new AST('}'));
}
| '{' expression '{' expression_list '}' '}' 
{
  $$ = new AST;
  $$->setName("expr_primary");
  $$->setRuleNumber(30);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('{'));
  $$->addNode($2);
  $$->addNode(new AST('{'));
  $$->addNode($4);
  $$->addNode(new AST('}'));
  $$->addNode(new AST('}'));
}
| '`' IDENTIFIER 
{
  $$ = new AST;
  $$->setName("expr_primary");
  $$->setRuleNumber(30);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('`'));
  $$->addNode($2);
}
| '`' IDENTIFIER '(' expression_list ')' 
{
  $$ = new AST;
  $$->setName("expr_primary");
  $$->setRuleNumber(30);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('`'));
  $$->addNode($2);
  $$->addNode(new AST('('));
  $$->addNode($4);
  $$->addNode(new AST(')'));
}
;

range_expression : expression ':' expression 
{
  $$ = new AST;
  $$->setName("range_expression");
  $$->setRuleNumber(31);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(':'));
  $$->addNode($3);
}
| expression "+:" expression 
{
  $$ = new AST;
  $$->setName("range_expression");
  $$->setRuleNumber(31);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST("+:"));
  $$->addNode($3);
}
| expression "-:" expression 
{
  $$ = new AST;
  $$->setName("range_expression");
  $$->setRuleNumber(31);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST("-:"));
  $$->addNode($3);
}
;

function_item : K_INPUT range_or_type_opt list_of_variables ';' 
{
  $$ = new AST;
  $$->setName("function_item");
  $$->setRuleNumber(32);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode(new AST(';'));
}
| block_item_decl 
{
  $$ = new AST;
  $$->setName("function_item");
  $$->setRuleNumber(32);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
;

function_item_list : 
{
  $$ = new AST;
  $$->setName("function_item_list");
  $$->setRuleNumber(33);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
}
| function_item_list function_item 
{
  $$ = new AST;
  $$->setName("function_item_list");
  $$->setRuleNumber(33);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

gate_instance : IDENTIFIER '(' expression_list ')' 
{
  $$ = new AST;
  $$->setName("gate_instance");
  $$->setRuleNumber(34);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('('));
  $$->addNode($3);
  $$->addNode(new AST(')'));
}
| IDENTIFIER range '(' expression_list ')' 
{
  $$ = new AST;
  $$->setName("gate_instance");
  $$->setRuleNumber(34);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST('('));
  $$->addNode($4);
  $$->addNode(new AST(')'));
}
| '(' expression_list ')' 
{
  $$ = new AST;
  $$->setName("gate_instance");
  $$->setRuleNumber(34);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('('));
  $$->addNode($2);
  $$->addNode(new AST(')'));
}
| IDENTIFIER '(' port_name_list ')' 
{
  $$ = new AST;
  $$->setName("gate_instance");
  $$->setRuleNumber(34);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('('));
  $$->addNode($3);
  $$->addNode(new AST(')'));
}
;

gate_instance_list : gate_instance_list ',' gate_instance 
{
  $$ = new AST;
  $$->setName("gate_instance_list");
  $$->setRuleNumber(35);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(','));
  $$->addNode($3);
}
| gate_instance 
{
  $$ = new AST;
  $$->setName("gate_instance_list");
  $$->setRuleNumber(35);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
;

gatetype : K_AND 
{
  $$ = new AST;
  $$->setName("gatetype");
  $$->setRuleNumber(36);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_NAND 
{
  $$ = new AST;
  $$->setName("gatetype");
  $$->setRuleNumber(36);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_OR 
{
  $$ = new AST;
  $$->setName("gatetype");
  $$->setRuleNumber(36);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_NOR 
{
  $$ = new AST;
  $$->setName("gatetype");
  $$->setRuleNumber(36);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_XOR 
{
  $$ = new AST;
  $$->setName("gatetype");
  $$->setRuleNumber(36);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_XNOR 
{
  $$ = new AST;
  $$->setName("gatetype");
  $$->setRuleNumber(36);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_BUF 
{
  $$ = new AST;
  $$->setName("gatetype");
  $$->setRuleNumber(36);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_BUFIF0 
{
  $$ = new AST;
  $$->setName("gatetype");
  $$->setRuleNumber(36);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_BUFIF1 
{
  $$ = new AST;
  $$->setName("gatetype");
  $$->setRuleNumber(36);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_NOT 
{
  $$ = new AST;
  $$->setName("gatetype");
  $$->setRuleNumber(36);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_NOTIF0 
{
  $$ = new AST;
  $$->setName("gatetype");
  $$->setRuleNumber(36);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_NOTIF1 
{
  $$ = new AST;
  $$->setName("gatetype");
  $$->setRuleNumber(36);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_NMOS 
{
  $$ = new AST;
  $$->setName("gatetype");
  $$->setRuleNumber(36);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_RNMOS 
{
  $$ = new AST;
  $$->setName("gatetype");
  $$->setRuleNumber(36);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_PMOS 
{
  $$ = new AST;
  $$->setName("gatetype");
  $$->setRuleNumber(36);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_RPMOS 
{
  $$ = new AST;
  $$->setName("gatetype");
  $$->setRuleNumber(36);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_CMOS 
{
  $$ = new AST;
  $$->setName("gatetype");
  $$->setRuleNumber(36);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_RCMOS 
{
  $$ = new AST;
  $$->setName("gatetype");
  $$->setRuleNumber(36);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_TRAN 
{
  $$ = new AST;
  $$->setName("gatetype");
  $$->setRuleNumber(36);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_RTRAN 
{
  $$ = new AST;
  $$->setName("gatetype");
  $$->setRuleNumber(36);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_TRANIF0 
{
  $$ = new AST;
  $$->setName("gatetype");
  $$->setRuleNumber(36);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_TRANIF1 
{
  $$ = new AST;
  $$->setName("gatetype");
  $$->setRuleNumber(36);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_RTRANIF0 
{
  $$ = new AST;
  $$->setName("gatetype");
  $$->setRuleNumber(36);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_RTRANIF1 
{
  $$ = new AST;
  $$->setName("gatetype");
  $$->setRuleNumber(36);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
;

identifier : IDENTIFIER 
{
  $$ = new AST;
  $$->setName("identifier");
  $$->setRuleNumber(37);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| HIDENTIFIER 
{
  $$ = new AST;
  $$->setName("identifier");
  $$->setRuleNumber(37);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
;

list_of_ports : port_opt
{
  $$ = new AST;
  $$->setName("list_of_ports");
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->setRuleNumber(38);
}
| list_of_ports ',' port_opt
{
  $1->addNode(new AST(','));
  $1->addNode($3);
  $$ = $1;
}
;
list_of_port_declarations : port_declaration 
{
  $$ = new AST;
  $$->setName("list_of_port_declarations");
  $$->setRuleNumber(39);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| list_of_port_declarations ',' port_declaration 
{
  $$ = new AST;
  $$->setName("list_of_port_declarations");
  $$->setRuleNumber(39);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($3);
}
| list_of_port_declarations ',' IDENTIFIER 
{
  $$ = new AST;
  $$->setName("list_of_port_declarations");
  $$->setRuleNumber(39);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($3);
}
;

port_declaration : attribute_instance_opt K_INPUT net_type_opt data_type_or_implicit IDENTIFIER dimensions_opt 
{
  $$ = new AST;
  $$->setName("port_declaration");
  $$->setRuleNumber(40);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
}
| attribute_instance_opt K_INPUT K_WREAL IDENTIFIER 
{
  $$ = new AST;
  $$->setName("port_declaration");
  $$->setRuleNumber(40);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
| attribute_instance_opt K_INOUT net_type_opt data_type_or_implicit IDENTIFIER dimensions_opt 
{
  $$ = new AST;
  $$->setName("port_declaration");
  $$->setRuleNumber(40);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
}
| attribute_instance_opt K_INOUT K_WREAL IDENTIFIER 
{
  $$ = new AST;
  $$->setName("port_declaration");
  $$->setRuleNumber(40);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
| attribute_instance_opt K_OUTPUT net_type_opt data_type_or_implicit IDENTIFIER dimensions_opt 
{
  $$ = new AST;
  $$->setName("port_declaration");
  $$->setRuleNumber(40);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
}
| attribute_instance_opt K_OUTPUT K_WREAL IDENTIFIER 
{
  $$ = new AST;
  $$->setName("port_declaration");
  $$->setRuleNumber(40);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
| attribute_instance_opt K_OUTPUT net_type_opt data_type_or_implicit IDENTIFIER '=' expression 
{
  $$ = new AST;
  $$->setName("port_declaration");
  $$->setRuleNumber(40);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode(new AST('='));
  $$->addNode($7);
}
;

module_port_declaration : attribute_instance_opt K_INPUT net_type_opt data_type_or_implicit list_of_variables dimensions_opt 
{
  $$ = new AST;
  $$->setName("module_port_declaration");
  $$->setRuleNumber(41);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
}
| attribute_instance_opt K_INPUT K_WREAL list_of_variables 
{
  $$ = new AST;
  $$->setName("module_port_declaration");
  $$->setRuleNumber(41);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
| attribute_instance_opt K_INOUT net_type_opt data_type_or_implicit list_of_variables dimensions_opt 
{
  $$ = new AST;
  $$->setName("module_port_declaration");
  $$->setRuleNumber(41);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
}
| attribute_instance_opt K_INOUT K_WREAL list_of_variables 
{
  $$ = new AST;
  $$->setName("module_port_declaration");
  $$->setRuleNumber(41);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
| attribute_instance_opt K_OUTPUT net_type_opt data_type_or_implicit list_of_variables dimensions_opt 
{
  $$ = new AST;
  $$->setName("module_port_declaration");
  $$->setRuleNumber(41);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
}
| attribute_instance_opt K_OUTPUT K_WREAL list_of_variables 
{
  $$ = new AST;
  $$->setName("module_port_declaration");
  $$->setRuleNumber(41);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
| attribute_instance_opt K_OUTPUT net_type_opt data_type_or_implicit list_of_variables '=' expression 
{
  $$ = new AST;
  $$->setName("module_port_declaration");
  $$->setRuleNumber(41);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode(new AST('='));
  $$->addNode($7);
}
;

data_type_or_implicit : data_type 
{
  $$ = new AST;
  $$->setName("data_type_or_implicit");
  $$->setRuleNumber(42);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| signing dimensions_opt 
{
  $$ = new AST;
  $$->setName("data_type_or_implicit");
  $$->setRuleNumber(42);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| dimensions 
{
  $$ = new AST;
  $$->setName("data_type_or_implicit");
  $$->setRuleNumber(42);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| 
{
  $$ = new AST;
  $$->setName("data_type_or_implicit");
  $$->setRuleNumber(42);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
}
;

data_type : integer_vector_type signed_opt dimensions_opt 
{
  $$ = new AST;
  $$->setName("data_type");
  $$->setRuleNumber(43);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| non_integer_type 
{
  $$ = new AST;
  $$->setName("data_type");
  $$->setRuleNumber(43);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_INTEGER signed_opt 
{
  $$ = new AST;
  $$->setName("data_type");
  $$->setRuleNumber(43);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

integer_vector_type : K_REG 
{
  $$ = new AST;
  $$->setName("integer_vector_type");
  $$->setRuleNumber(44);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_BIT 
{
  $$ = new AST;
  $$->setName("integer_vector_type");
  $$->setRuleNumber(44);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_LOGIC 
{
  $$ = new AST;
  $$->setName("integer_vector_type");
  $$->setRuleNumber(44);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_BOOL 
{
  $$ = new AST;
  $$->setName("integer_vector_type");
  $$->setRuleNumber(44);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
;

non_integer_type : K_REAL 
{
  $$ = new AST;
  $$->setName("non_integer_type");
  $$->setRuleNumber(45);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_REALTIME 
{
  $$ = new AST;
  $$->setName("non_integer_type");
  $$->setRuleNumber(45);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
;

signing : K_SIGNED 
{
  $$ = new AST;
  $$->setName("signing");
  $$->setRuleNumber(46);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_UNSIGNED 
{
  $$ = new AST;
  $$->setName("signing");
  $$->setRuleNumber(46);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
;

signed_opt : K_SIGNED 
{
  $$ = new AST;
  $$->setName("signed_opt");
  $$->setRuleNumber(47);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_UNSIGNED 
{
  $$ = new AST;
  $$->setName("signed_opt");
  $$->setRuleNumber(47);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| 
{
  $$ = new AST;
  $$->setName("signed_opt");
  $$->setRuleNumber(47);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
}
;

list_of_variables : IDENTIFIER
{
  $$ = new AST;
  $$->setName("list_of_variables");
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->setRuleNumber(48);
}
| list_of_variables ',' IDENTIFIER
{
  $1->addNode($3);
  $$ = $1;
}
;
net_variable_list : net_variable
{
  $$ = new AST;
  $$->setName("net_variable_list");
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->setRuleNumber(49);
}
| net_variable_list ',' net_variable
{
  $1->addNode(new AST(','));
  $1->addNode($3);
  $$ = $1;
}
;
net_variable : IDENTIFIER dimensions_opt 
{
  $$ = new AST;
  $$->setName("net_variable");
  $$->setRuleNumber(50);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

dimensions_opt : 
{
  $$ = new AST;
  $$->setName("dimensions_opt");
  $$->setRuleNumber(51);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
}
| dimensions 
{
  $$ = new AST;
  $$->setName("dimensions_opt");
  $$->setRuleNumber(51);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
;

dimensions : variable_dimension
{
  $$ = new AST;
  $$->setName("dimensions");
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->setRuleNumber(52);
}
| dimensions  variable_dimension
{
  $1->addNode($2);
  $$ = $1;
}
;
variable_dimension : '[' expression ':' expression ']' 
{
  $$ = new AST;
  $$->setName("variable_dimension");
  $$->setRuleNumber(53);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('['));
  $$->addNode($2);
  $$->addNode(new AST(':'));
  $$->addNode($4);
  $$->addNode(new AST(']'));
}
;

lavalue : identifier 
{
  $$ = new AST;
  $$->setName("lavalue");
  $$->setRuleNumber(54);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| identifier braced_expression_list 
{
  $$ = new AST;
  $$->setName("lavalue");
  $$->setRuleNumber(54);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| identifier braced_expression_list '[' constant_range ']' 
{
  $$ = new AST;
  $$->setName("lavalue");
  $$->setRuleNumber(54);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST('['));
  $$->addNode($4);
  $$->addNode(new AST(']'));
}
| identifier '[' constant_range ']' 
{
  $$ = new AST;
  $$->setName("lavalue");
  $$->setRuleNumber(54);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('['));
  $$->addNode($3);
  $$->addNode(new AST(']'));
}
| '{' expression_list '}' 
{
  $$ = new AST;
  $$->setName("lavalue");
  $$->setRuleNumber(54);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('{'));
  $$->addNode($2);
  $$->addNode(new AST('}'));
}
;

braced_expression : '[' expression ']' 
{
  $$ = new AST;
  $$->setName("braced_expression");
  $$->setRuleNumber(55);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('['));
  $$->addNode($2);
  $$->addNode(new AST(']'));
}
;

braced_expression_list : braced_expression
{
  $$ = new AST;
  $$->setName("braced_expression_list");
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->setRuleNumber(56);
}
| braced_expression_list  braced_expression
{
  $1->addNode($2);
  $$ = $1;
}
;
constant_range : expression ':' expression 
{
  $$ = new AST;
  $$->setName("constant_range");
  $$->setRuleNumber(57);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(':'));
  $$->addNode($3);
}
| expression "+:" expression 
{
  $$ = new AST;
  $$->setName("constant_range");
  $$->setRuleNumber(57);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST("+:"));
  $$->addNode($3);
}
| expression "-:" expression 
{
  $$ = new AST;
  $$->setName("constant_range");
  $$->setRuleNumber(57);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST("-:"));
  $$->addNode($3);
}
;

lpvalue : identifier 
{
  $$ = new AST;
  $$->setName("lpvalue");
  $$->setRuleNumber(58);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| identifier braced_expression_list 
{
  $$ = new AST;
  $$->setName("lpvalue");
  $$->setRuleNumber(58);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| identifier braced_expression_list '[' constant_range ']' 
{
  $$ = new AST;
  $$->setName("lpvalue");
  $$->setRuleNumber(58);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST('['));
  $$->addNode($4);
  $$->addNode(new AST(']'));
}
| identifier '[' constant_range ']' 
{
  $$ = new AST;
  $$->setName("lpvalue");
  $$->setRuleNumber(58);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('['));
  $$->addNode($3);
  $$->addNode(new AST(']'));
}
| '{' expression_list '}' 
{
  $$ = new AST;
  $$->setName("lpvalue");
  $$->setRuleNumber(58);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('{'));
  $$->addNode($2);
  $$->addNode(new AST('}'));
}
;

assign : lavalue '=' expression 
{
  $$ = new AST;
  $$->setName("assign");
  $$->setRuleNumber(59);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('='));
  $$->addNode($3);
}
;

assign_list : assign_list ',' assign 
{
  $$ = new AST;
  $$->setName("assign_list");
  $$->setRuleNumber(60);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(','));
  $$->addNode($3);
}
| assign 
{
  $$ = new AST;
  $$->setName("assign_list");
  $$->setRuleNumber(60);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
;

module : module_start module_end 
{
  $$ = new AST;
  $$->setName("module");
  $$->setRuleNumber(61);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

module_start : attribute_instance_opt K_MODULE IDENTIFIER module_parameter_port_list module_port_list_opt ';' 
{
  $$ = new AST;
  $$->setName("module_start");
  $$->setRuleNumber(62);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode(new AST(';'));
}
;

module_port_list_opt : '(' list_of_ports ')' 
{
  $$ = new AST;
  $$->setName("module_port_list_opt");
  $$->setRuleNumber(63);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($2);
}
| '(' list_of_port_declarations ')' 
{
  $$ = new AST;
  $$->setName("module_port_list_opt");
  $$->setRuleNumber(63);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($2);
}
| 
{
  $$ = new AST;
  $$->setName("module_port_list_opt");
  $$->setRuleNumber(63);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
}
;

module_end : module_item_list K_ENDMODULE 
{
  $$ = new AST;
  $$->setName("module_end");
  $$->setRuleNumber(64);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

module_parameter_port_list : '#' '(' parameter_declaration ')' 
{
  $$ = new AST;
  $$->setName("module_parameter_port_list");
  $$->setRuleNumber(65);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('#'));
  $$->addNode(new AST('('));
  $$->addNode($3);
  $$->addNode(new AST(')'));
}
| 
{
  $$ = new AST;
  $$->setName("module_parameter_port_list");
  $$->setRuleNumber(65);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
}
;

parameter_declaration : K_PARAMETER parameter_type parameter_assign 
{
  $$ = new AST;
  $$->setName("parameter_declaration");
  $$->setRuleNumber(66);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| parameter_declaration ',' parameter_assign 
{
  $$ = new AST;
  $$->setName("parameter_declaration");
  $$->setRuleNumber(66);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(','));
  $$->addNode($3);
}
| parameter_declaration ',' K_PARAMETER parameter_type parameter_assign 
{
  $$ = new AST;
  $$->setName("parameter_declaration");
  $$->setRuleNumber(66);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(','));
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
}
;

parameter_type : bit_logic_opt signed_opt range_opt 
{
  $$ = new AST;
  $$->setName("parameter_type");
  $$->setRuleNumber(67);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| K_INTEGER 
{
  $$ = new AST;
  $$->setName("parameter_type");
  $$->setRuleNumber(67);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_REAL 
{
  $$ = new AST;
  $$->setName("parameter_type");
  $$->setRuleNumber(67);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_REALTIME 
{
  $$ = new AST;
  $$->setName("parameter_type");
  $$->setRuleNumber(67);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_TIME 
{
  $$ = new AST;
  $$->setName("parameter_type");
  $$->setRuleNumber(67);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
;

bit_logic_opt : bit_logic 
{
  $$ = new AST;
  $$->setName("bit_logic_opt");
  $$->setRuleNumber(68);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| 
{
  $$ = new AST;
  $$->setName("bit_logic_opt");
  $$->setRuleNumber(68);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
}
;

bit_logic : K_LOGIC 
{
  $$ = new AST;
  $$->setName("bit_logic");
  $$->setRuleNumber(69);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_BOOL 
{
  $$ = new AST;
  $$->setName("bit_logic");
  $$->setRuleNumber(69);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_BIT 
{
  $$ = new AST;
  $$->setName("bit_logic");
  $$->setRuleNumber(69);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
;

module_item : net_type signed_opt range_opt net_variable_list ';' 
{
  $$ = new AST;
  $$->setName("module_item");
  $$->setRuleNumber(70);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode(new AST(';'));
}
| net_type signed_opt range_opt net_decl_assigns ';' 
{
  $$ = new AST;
  $$->setName("module_item");
  $$->setRuleNumber(70);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode(new AST(';'));
}
| net_type drive_strength net_decl_assigns ';' 
{
  $$ = new AST;
  $$->setName("module_item");
  $$->setRuleNumber(70);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode(new AST(';'));
}
| K_TRIREG charge_strength_opt range_opt delay3_opt list_of_variables ';' 
{
  $$ = new AST;
  $$->setName("module_item");
  $$->setRuleNumber(70);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode(new AST(';'));
}
| module_port_declaration ';' 
{
  $$ = new AST;
  $$->setName("module_item");
  $$->setRuleNumber(70);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(';'));
}
| block_item_decl 
{
  $$ = new AST;
  $$->setName("module_item");
  $$->setRuleNumber(70);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_DEFPARAM defparam_assign_list ';' 
{
  $$ = new AST;
  $$->setName("module_item");
  $$->setRuleNumber(70);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST(';'));
}
| K_EVENT list_of_variables ';' 
{
  $$ = new AST;
  $$->setName("module_item");
  $$->setRuleNumber(70);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST(';'));
}
| gatetype gate_instance_list ';' 
{
  $$ = new AST;
  $$->setName("module_item");
  $$->setRuleNumber(70);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST(';'));
}
| gatetype delay3 gate_instance_list ';' 
{
  $$ = new AST;
  $$->setName("module_item");
  $$->setRuleNumber(70);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode(new AST(';'));
}
| gatetype drive_strength gate_instance_list ';' 
{
  $$ = new AST;
  $$->setName("module_item");
  $$->setRuleNumber(70);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode(new AST(';'));
}
| gatetype drive_strength delay3 gate_instance_list ';' 
{
  $$ = new AST;
  $$->setName("module_item");
  $$->setRuleNumber(70);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode(new AST(';'));
}
| K_PULLUP gate_instance_list ';' 
{
  $$ = new AST;
  $$->setName("module_item");
  $$->setRuleNumber(70);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST(';'));
}
| K_PULLDOWN gate_instance_list ';' 
{
  $$ = new AST;
  $$->setName("module_item");
  $$->setRuleNumber(70);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST(';'));
}
| IDENTIFIER parameter_value_opt gate_instance_list ';' 
{
  $$ = new AST;
  $$->setName("module_item");
  $$->setRuleNumber(70);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode(new AST(';'));
}
| K_ASSIGN drive_strength_opt delay3_opt assign_list ';' 
{
  $$ = new AST;
  $$->setName("module_item");
  $$->setRuleNumber(70);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode(new AST(';'));
}
| K_ALWAYS statement 
{
  $$ = new AST;
  $$->setName("module_item");
  $$->setRuleNumber(70);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| K_INITIAL statement 
{
  $$ = new AST;
  $$->setName("module_item");
  $$->setRuleNumber(70);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| K_TASK automatic_opt IDENTIFIER module_port_list_opt ';' task_item_list_opt statement_opt K_ENDTASK 
{
  $$ = new AST;
  $$->setName("module_item");
  $$->setRuleNumber(70);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode(new AST(';'));
  $$->addNode($6);
  $$->addNode($7);
  $$->addNode($8);
}
| K_FUNCTION automatic_opt range_or_type_opt IDENTIFIER module_port_list_opt ';' function_item_list statement K_ENDFUNCTION 
{
  $$ = new AST;
  $$->setName("module_item");
  $$->setRuleNumber(70);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode(new AST(';'));
  $$->addNode($7);
  $$->addNode($8);
  $$->addNode($9);
}
| K_SPECIFY specify_item_list K_ENDSPECIFY 
{
  $$ = new AST;
  $$->setName("module_item");
  $$->setRuleNumber(70);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| KK_ATTRIBUTE '(' IDENTIFIER ',' STRING ',' STRING ')' ';' 
{
  $$ = new AST;
  $$->setName("module_item");
  $$->setRuleNumber(70);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('('));
  $$->addNode($3);
  $$->addNode(new AST(','));
  $$->addNode($5);
  $$->addNode(new AST(','));
  $$->addNode($7);
  $$->addNode(new AST(')'));
  $$->addNode(new AST(';'));
}
| genvar_declaration 
{
  $$ = new AST;
  $$->setName("module_item");
  $$->setRuleNumber(70);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| generated_instantiation 
{
  $$ = new AST;
  $$->setName("module_item");
  $$->setRuleNumber(70);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| generate_loop_statement 
{
  $$ = new AST;
  $$->setName("module_item");
  $$->setRuleNumber(70);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| generate_conditional_statement 
{
  $$ = new AST;
  $$->setName("module_item");
  $$->setRuleNumber(70);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| generate_case_statement 
{
  $$ = new AST;
  $$->setName("module_item");
  $$->setRuleNumber(70);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
;

module_item_list : 
{
  $$ = new AST;
  $$->setName("module_item_list");
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  ;
  $$->setRuleNumber(71);
}
| module_item_list  module_item
{
  $1->addNode($2);
  $$ = $1;
}
;
net_decl_assign : IDENTIFIER '=' expression 
{
  $$ = new AST;
  $$->setName("net_decl_assign");
  $$->setRuleNumber(72);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('='));
  $$->addNode($3);
}
| delay1 IDENTIFIER '=' expression 
{
  $$ = new AST;
  $$->setName("net_decl_assign");
  $$->setRuleNumber(72);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST('='));
  $$->addNode($4);
}
;

net_decl_assigns : net_decl_assigns ',' net_decl_assign 
{
  $$ = new AST;
  $$->setName("net_decl_assigns");
  $$->setRuleNumber(73);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(','));
  $$->addNode($3);
}
| net_decl_assign 
{
  $$ = new AST;
  $$->setName("net_decl_assigns");
  $$->setRuleNumber(73);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
;

net_type : K_WIRE 
{
  $$ = new AST;
  $$->setName("net_type");
  $$->setRuleNumber(74);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_TRI 
{
  $$ = new AST;
  $$->setName("net_type");
  $$->setRuleNumber(74);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_TRI1 
{
  $$ = new AST;
  $$->setName("net_type");
  $$->setRuleNumber(74);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_SUPPLY0 
{
  $$ = new AST;
  $$->setName("net_type");
  $$->setRuleNumber(74);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_WAND 
{
  $$ = new AST;
  $$->setName("net_type");
  $$->setRuleNumber(74);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_TRIAND 
{
  $$ = new AST;
  $$->setName("net_type");
  $$->setRuleNumber(74);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_TRI0 
{
  $$ = new AST;
  $$->setName("net_type");
  $$->setRuleNumber(74);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_SUPPLY1 
{
  $$ = new AST;
  $$->setName("net_type");
  $$->setRuleNumber(74);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_WOR 
{
  $$ = new AST;
  $$->setName("net_type");
  $$->setRuleNumber(74);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_TRIOR 
{
  $$ = new AST;
  $$->setName("net_type");
  $$->setRuleNumber(74);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
;

net_type_opt : net_type 
{
  $$ = new AST;
  $$->setName("net_type_opt");
  $$->setRuleNumber(75);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| 
{
  $$ = new AST;
  $$->setName("net_type_opt");
  $$->setRuleNumber(75);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
}
;

parameter_assign : IDENTIFIER '=' expression 
{
  $$ = new AST;
  $$->setName("parameter_assign");
  $$->setRuleNumber(76);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('='));
  $$->addNode($3);
}
;

parameter_assign_list : parameter_assign 
{
  $$ = new AST;
  $$->setName("parameter_assign_list");
  $$->setRuleNumber(77);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| range parameter_assign 
{
  $$ = new AST;
  $$->setName("parameter_assign_list");
  $$->setRuleNumber(77);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| parameter_type parameter_assign 
{
  $$ = new AST;
  $$->setName("parameter_assign_list");
  $$->setRuleNumber(77);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| parameter_assign_list ',' parameter_assign 
{
  $$ = new AST;
  $$->setName("parameter_assign_list");
  $$->setRuleNumber(77);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(','));
  $$->addNode($3);
}
;

localparam_assign : IDENTIFIER '=' expression 
{
  $$ = new AST;
  $$->setName("localparam_assign");
  $$->setRuleNumber(78);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('='));
  $$->addNode($3);
}
;

localparam_assign_list : localparam_assign 
{
  $$ = new AST;
  $$->setName("localparam_assign_list");
  $$->setRuleNumber(79);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| range localparam_assign 
{
  $$ = new AST;
  $$->setName("localparam_assign_list");
  $$->setRuleNumber(79);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| localparam_assign_list ',' localparam_assign 
{
  $$ = new AST;
  $$->setName("localparam_assign_list");
  $$->setRuleNumber(79);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(','));
  $$->addNode($3);
}
;

parameter_value_opt : '#' '(' expression_list ')' 
{
  $$ = new AST;
  $$->setName("parameter_value_opt");
  $$->setRuleNumber(80);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('#'));
  $$->addNode(new AST('('));
  $$->addNode($3);
  $$->addNode(new AST(')'));
}
| '#' '(' parameter_value_byname_list ')' 
{
  $$ = new AST;
  $$->setName("parameter_value_opt");
  $$->setRuleNumber(80);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('#'));
  $$->addNode(new AST('('));
  $$->addNode($3);
  $$->addNode(new AST(')'));
}
| '#' NUMBER 
{
  $$ = new AST;
  $$->setName("parameter_value_opt");
  $$->setRuleNumber(80);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('#'));
  $$->addNode($2);
}
| 
{
  $$ = new AST;
  $$->setName("parameter_value_opt");
  $$->setRuleNumber(80);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
}
;

parameter_value_byname : PORTNAME '(' expression ')' 
{
  $$ = new AST;
  $$->setName("parameter_value_byname");
  $$->setRuleNumber(81);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('('));
  $$->addNode($3);
  $$->addNode(new AST(')'));
}
| PORTNAME '(' ')' 
{
  $$ = new AST;
  $$->setName("parameter_value_byname");
  $$->setRuleNumber(81);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('('));
  $$->addNode(new AST(')'));
}
;

parameter_value_byname_list : parameter_value_byname
{
  $$ = new AST;
  $$->setName("parameter_value_byname_list");
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->setRuleNumber(82);
}
| parameter_value_byname_list ',' parameter_value_byname
{
  $1->addNode(new AST(','));
  $1->addNode($3);
  $$ = $1;
}
;
port : port_reference 
{
  $$ = new AST;
  $$->setName("port");
  $$->setRuleNumber(83);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| PORTNAME '(' port_reference ')' 
{
  $$ = new AST;
  $$->setName("port");
  $$->setRuleNumber(83);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('('));
  $$->addNode($3);
  $$->addNode(new AST(')'));
}
| '{' port_reference_list '}' 
{
  $$ = new AST;
  $$->setName("port");
  $$->setRuleNumber(83);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('{'));
  $$->addNode($2);
  $$->addNode(new AST('}'));
}
| PORTNAME '(' '{' port_reference_list '}' ')' 
{
  $$ = new AST;
  $$->setName("port");
  $$->setRuleNumber(83);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('('));
  $$->addNode(new AST('{'));
  $$->addNode($4);
  $$->addNode(new AST('}'));
  $$->addNode(new AST(')'));
}
;

port_opt : port 
{
  $$ = new AST;
  $$->setName("port_opt");
  $$->setRuleNumber(84);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| 
{
  $$ = new AST;
  $$->setName("port_opt");
  $$->setRuleNumber(84);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
}
;

port_reference : IDENTIFIER 
{
  $$ = new AST;
  $$->setName("port_reference");
  $$->setRuleNumber(85);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| IDENTIFIER '[' expression ':' expression ']' 
{
  $$ = new AST;
  $$->setName("port_reference");
  $$->setRuleNumber(85);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('['));
  $$->addNode($3);
  $$->addNode(new AST(':'));
  $$->addNode($5);
  $$->addNode(new AST(']'));
}
| IDENTIFIER '[' expression ']' 
{
  $$ = new AST;
  $$->setName("port_reference");
  $$->setRuleNumber(85);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('['));
  $$->addNode($3);
  $$->addNode(new AST(']'));
}
;

port_reference_list : port_reference 
{
  $$ = new AST;
  $$->setName("port_reference_list");
  $$->setRuleNumber(86);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| port_reference_list ',' port_reference 
{
  $$ = new AST;
  $$->setName("port_reference_list");
  $$->setRuleNumber(86);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(','));
  $$->addNode($3);
}
;

port_name : PORTNAME '(' expression ')' 
{
  $$ = new AST;
  $$->setName("port_name");
  $$->setRuleNumber(87);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('('));
  $$->addNode($3);
  $$->addNode(new AST(')'));
}
| PORTNAME '(' ')' 
{
  $$ = new AST;
  $$->setName("port_name");
  $$->setRuleNumber(87);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('('));
  $$->addNode(new AST(')'));
}
;

port_name_list : port_name_list ',' port_name 
{
  $$ = new AST;
  $$->setName("port_name_list");
  $$->setRuleNumber(88);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(','));
  $$->addNode($3);
}
| port_name 
{
  $$ = new AST;
  $$->setName("port_name_list");
  $$->setRuleNumber(88);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
;

range : '[' expression ':' expression ']' 
{
  $$ = new AST;
  $$->setName("range");
  $$->setRuleNumber(89);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('['));
  $$->addNode($2);
  $$->addNode(new AST(':'));
  $$->addNode($4);
  $$->addNode(new AST(']'));
}
;

range_opt : range 
{
  $$ = new AST;
  $$->setName("range_opt");
  $$->setRuleNumber(90);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_REG range 
{
  $$ = new AST;
  $$->setName("range_opt");
  $$->setRuleNumber(90);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| 
{
  $$ = new AST;
  $$->setName("range_opt");
  $$->setRuleNumber(90);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
}
;

range_or_type_opt : range_opt 
{
  $$ = new AST;
  $$->setName("range_or_type_opt");
  $$->setRuleNumber(91);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_INTEGER 
{
  $$ = new AST;
  $$->setName("range_or_type_opt");
  $$->setRuleNumber(91);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_REAL 
{
  $$ = new AST;
  $$->setName("range_or_type_opt");
  $$->setRuleNumber(91);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_REALTIME 
{
  $$ = new AST;
  $$->setName("range_or_type_opt");
  $$->setRuleNumber(91);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_TIME 
{
  $$ = new AST;
  $$->setName("range_or_type_opt");
  $$->setRuleNumber(91);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_REG 
{
  $$ = new AST;
  $$->setName("range_or_type_opt");
  $$->setRuleNumber(91);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
;

register_variable : IDENTIFIER 
{
  $$ = new AST;
  $$->setName("register_variable");
  $$->setRuleNumber(92);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| IDENTIFIER '=' expression 
{
  $$ = new AST;
  $$->setName("register_variable");
  $$->setRuleNumber(92);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('='));
  $$->addNode($3);
}
| IDENTIFIER '[' expression ':' expression ']' 
{
  $$ = new AST;
  $$->setName("register_variable");
  $$->setRuleNumber(92);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('['));
  $$->addNode($3);
  $$->addNode(new AST(':'));
  $$->addNode($5);
  $$->addNode(new AST(']'));
}
;

register_variable_list : register_variable 
{
  $$ = new AST;
  $$->setName("register_variable_list");
  $$->setRuleNumber(93);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| register_variable_list ',' register_variable 
{
  $$ = new AST;
  $$->setName("register_variable_list");
  $$->setRuleNumber(93);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(','));
  $$->addNode($3);
}
;

specify_item : K_SPECPARAM specparam_list ';' 
{
  $$ = new AST;
  $$->setName("specify_item");
  $$->setRuleNumber(94);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST(';'));
}
| specify_simple_path '=' '(' delay_value ')' ';' 
{
  $$ = new AST;
  $$->setName("specify_item");
  $$->setRuleNumber(94);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('='));
  $$->addNode(new AST('('));
  $$->addNode($4);
  $$->addNode(new AST(')'));
  $$->addNode(new AST(';'));
}
| specify_simple_path '=' '(' delay_value ',' delay_value ')' ';' 
{
  $$ = new AST;
  $$->setName("specify_item");
  $$->setRuleNumber(94);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('='));
  $$->addNode(new AST('('));
  $$->addNode($4);
  $$->addNode(new AST(','));
  $$->addNode($6);
  $$->addNode(new AST(')'));
  $$->addNode(new AST(';'));
}
| specify_simple_path '=' '(' delay_value ',' delay_value ',' delay_value ')' ';' 
{
  $$ = new AST;
  $$->setName("specify_item");
  $$->setRuleNumber(94);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('='));
  $$->addNode(new AST('('));
  $$->addNode($4);
  $$->addNode(new AST(','));
  $$->addNode($6);
  $$->addNode(new AST(','));
  $$->addNode($8);
  $$->addNode(new AST(')'));
  $$->addNode(new AST(';'));
}
| specify_simple_path '=' delay_value_simple ';' 
{
  $$ = new AST;
  $$->setName("specify_item");
  $$->setRuleNumber(94);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('='));
  $$->addNode($3);
  $$->addNode(new AST(';'));
}
;

specify_item_list : specify_item 
{
  $$ = new AST;
  $$->setName("specify_item_list");
  $$->setRuleNumber(95);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| specify_item_list specify_item 
{
  $$ = new AST;
  $$->setName("specify_item_list");
  $$->setRuleNumber(95);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

specify_simple_path : '(' IDENTIFIER spec_polarity K_EG IDENTIFIER ')' 
{
  $$ = new AST;
  $$->setName("specify_simple_path");
  $$->setRuleNumber(96);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('('));
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode(new AST(')'));
}
| '(' IDENTIFIER spec_polarity K_SG IDENTIFIER ')' 
{
  $$ = new AST;
  $$->setName("specify_simple_path");
  $$->setRuleNumber(96);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('('));
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode(new AST(')'));
}
;

specparam : IDENTIFIER '=' expression 
{
  $$ = new AST;
  $$->setName("specparam");
  $$->setRuleNumber(97);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('='));
  $$->addNode($3);
}
;

specparam_list : specparam 
{
  $$ = new AST;
  $$->setName("specparam_list");
  $$->setRuleNumber(98);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| specparam_list ',' specparam 
{
  $$ = new AST;
  $$->setName("specparam_list");
  $$->setRuleNumber(98);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(','));
  $$->addNode($3);
}
;

spec_polarity : '+' 
{
  $$ = new AST;
  $$->setName("spec_polarity");
  $$->setRuleNumber(99);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('+'));
}
| '-' 
{
  $$ = new AST;
  $$->setName("spec_polarity");
  $$->setRuleNumber(99);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('-'));
}
| 
{
  $$ = new AST;
  $$->setName("spec_polarity");
  $$->setRuleNumber(99);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
}
;

statement : K_ASSIGN lavalue '=' expression ';' 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST('='));
  $$->addNode($4);
  $$->addNode(new AST(';'));
}
| K_DEASSIGN lavalue ';' 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST(';'));
}
| K_FORCE lavalue '=' expression ';' 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST('='));
  $$->addNode($4);
  $$->addNode(new AST(';'));
}
| K_RELEASE lavalue ';' 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST(';'));
}
| K_BEGIN statement_list K_END 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| K_BEGIN ':' IDENTIFIER block_item_decls_opt statement_list K_END 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(':'));
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
}
| K_BEGIN K_END 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| K_BEGIN ':' IDENTIFIER K_END 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(':'));
  $$->addNode($3);
  $$->addNode($4);
}
| K_FORK ':' IDENTIFIER block_item_decls_opt statement_list K_JOIN 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(':'));
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
  $$->addNode($6);
}
| K_FORK K_JOIN 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| K_FORK ':' IDENTIFIER K_JOIN 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(':'));
  $$->addNode($3);
  $$->addNode($4);
}
| K_DISABLE identifier ';' 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST(';'));
}
| K_TRIGGER IDENTIFIER ';' 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST(';'));
}
| K_FOREVER statement 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| K_FORK statement_list K_JOIN 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| K_REPEAT '(' expression ')' statement 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('('));
  $$->addNode($3);
  $$->addNode(new AST(')'));
  $$->addNode($5);
}
| K_CASE '(' expression ')' case_items K_ENDCASE 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('('));
  $$->addNode($3);
  $$->addNode(new AST(')'));
  $$->addNode($5);
  $$->addNode($6);
}
| K_CASEX '(' expression ')' case_items K_ENDCASE 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('('));
  $$->addNode($3);
  $$->addNode(new AST(')'));
  $$->addNode($5);
  $$->addNode($6);
}
| K_CASEZ '(' expression ')' case_items K_ENDCASE 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('('));
  $$->addNode($3);
  $$->addNode(new AST(')'));
  $$->addNode($5);
  $$->addNode($6);
}
| K_IF '(' expression ')' statement_opt %prec LESS_THAN_K_ELSE
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('('));
  $$->addNode($3);
  $$->addNode(new AST(')'));
  $$->addNode($5);
}
| K_IF '(' expression ')' statement_opt K_ELSE statement_opt 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('('));
  $$->addNode($3);
  $$->addNode(new AST(')'));
  $$->addNode($5);
  $$->addNode($6);
  $$->addNode($7);
}
| K_FOR '(' lpvalue '=' expression ';' expression ';' lpvalue '=' expression ')' statement 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('('));
  $$->addNode($3);
  $$->addNode(new AST('='));
  $$->addNode($5);
  $$->addNode(new AST(';'));
  $$->addNode($7);
  $$->addNode(new AST(';'));
  $$->addNode($9);
  $$->addNode(new AST('='));
  $$->addNode($11);
  $$->addNode(new AST(')'));
  $$->addNode($13);
}
| K_WHILE '(' expression ')' statement 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('('));
  $$->addNode($3);
  $$->addNode(new AST(')'));
  $$->addNode($5);
}
| delay1 statement_opt 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| event_control statement_opt 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| lpvalue '=' expression ';' 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('='));
  $$->addNode($3);
  $$->addNode(new AST(';'));
}
| lpvalue K_LE expression ';' 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode(new AST(';'));
}
| lpvalue '=' delay1 expression ';' 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('='));
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode(new AST(';'));
}
| lpvalue K_LE delay1 expression ';' 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode(new AST(';'));
}
| lpvalue '=' event_control expression ';' 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('='));
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode(new AST(';'));
}
| lpvalue '=' K_REPEAT '(' expression ')' event_control expression ';' 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('='));
  $$->addNode($3);
  $$->addNode(new AST('('));
  $$->addNode($5);
  $$->addNode(new AST(')'));
  $$->addNode($7);
  $$->addNode($8);
  $$->addNode(new AST(';'));
}
| lpvalue K_LE event_control expression ';' 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode(new AST(';'));
}
| lpvalue K_LE K_REPEAT '(' expression ')' event_control expression ';' 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode(new AST('('));
  $$->addNode($5);
  $$->addNode(new AST(')'));
  $$->addNode($7);
  $$->addNode($8);
  $$->addNode(new AST(';'));
}
| K_WAIT '(' expression ')' statement_opt 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('('));
  $$->addNode($3);
  $$->addNode(new AST(')'));
  $$->addNode($5);
}
| SYSTEM_IDENTIFIER '(' expression_list ')' ';' 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('('));
  $$->addNode($3);
  $$->addNode(new AST(')'));
  $$->addNode(new AST(';'));
}
| SYSTEM_IDENTIFIER ';' 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(';'));
}
| identifier '(' expression_list ')' ';' 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('('));
  $$->addNode($3);
  $$->addNode(new AST(')'));
  $$->addNode(new AST(';'));
}
| identifier ';' 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(';'));
}
| '`' IDENTIFIER '(' expression_list ')' ';' 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('`'));
  $$->addNode($2);
  $$->addNode(new AST('('));
  $$->addNode($4);
  $$->addNode(new AST(')'));
  $$->addNode(new AST(';'));
}
| '`' IDENTIFIER '(' expression_list ')' 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('`'));
  $$->addNode($2);
  $$->addNode(new AST('('));
  $$->addNode($4);
  $$->addNode(new AST(')'));
}
| '`' IDENTIFIER ';' 
{
  $$ = new AST;
  $$->setName("statement");
  $$->setRuleNumber(100);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('`'));
  $$->addNode($2);
  $$->addNode(new AST(';'));
}
;

statement_list : statement_list statement 
{
  $$ = new AST;
  $$->setName("statement_list");
  $$->setRuleNumber(101);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| statement 
{
  $$ = new AST;
  $$->setName("statement_list");
  $$->setRuleNumber(101);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
;

statement_opt : statement 
{
  $$ = new AST;
  $$->setName("statement_opt");
  $$->setRuleNumber(102);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| ';' 
{
  $$ = new AST;
  $$->setName("statement_opt");
  $$->setRuleNumber(102);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST(';'));
}
;

task_item : block_item_decl 
{
  $$ = new AST;
  $$->setName("task_item");
  $$->setRuleNumber(103);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_INPUT range_or_type_opt list_of_variables ';' 
{
  $$ = new AST;
  $$->setName("task_item");
  $$->setRuleNumber(103);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode(new AST(';'));
}
| K_OUTPUT range_or_type_opt list_of_variables ';' 
{
  $$ = new AST;
  $$->setName("task_item");
  $$->setRuleNumber(103);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode(new AST(';'));
}
| K_INOUT range_or_type_opt list_of_variables ';' 
{
  $$ = new AST;
  $$->setName("task_item");
  $$->setRuleNumber(103);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode(new AST(';'));
}
;

task_item_list : task_item_list task_item 
{
  $$ = new AST;
  $$->setName("task_item_list");
  $$->setRuleNumber(104);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| task_item 
{
  $$ = new AST;
  $$->setName("task_item_list");
  $$->setRuleNumber(104);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
;

task_item_list_opt : task_item_list 
{
  $$ = new AST;
  $$->setName("task_item_list_opt");
  $$->setRuleNumber(105);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| 
{
  $$ = new AST;
  $$->setName("task_item_list_opt");
  $$->setRuleNumber(105);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
}
;

udp_body : K_TABLE udp_entry_list K_ENDTABLE 
{
  $$ = new AST;
  $$->setName("udp_body");
  $$->setRuleNumber(106);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

udp_entry_list : udp_comb_entry_list 
{
  $$ = new AST;
  $$->setName("udp_entry_list");
  $$->setRuleNumber(107);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| udp_sequ_entry_list 
{
  $$ = new AST;
  $$->setName("udp_entry_list");
  $$->setRuleNumber(107);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
;

udp_comb_entry : udp_input_list ':' udp_output_sym ';' 
{
  $$ = new AST;
  $$->setName("udp_comb_entry");
  $$->setRuleNumber(108);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(':'));
  $$->addNode($3);
  $$->addNode(new AST(';'));
}
;

udp_comb_entry_list : udp_comb_entry 
{
  $$ = new AST;
  $$->setName("udp_comb_entry_list");
  $$->setRuleNumber(109);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| udp_comb_entry_list udp_comb_entry 
{
  $$ = new AST;
  $$->setName("udp_comb_entry_list");
  $$->setRuleNumber(109);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

udp_sequ_entry_list : udp_sequ_entry 
{
  $$ = new AST;
  $$->setName("udp_sequ_entry_list");
  $$->setRuleNumber(110);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| udp_sequ_entry_list udp_sequ_entry 
{
  $$ = new AST;
  $$->setName("udp_sequ_entry_list");
  $$->setRuleNumber(110);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

udp_sequ_entry : udp_input_list ':' udp_input_sym ':' udp_output_sym ';' 
{
  $$ = new AST;
  $$->setName("udp_sequ_entry");
  $$->setRuleNumber(111);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(':'));
  $$->addNode($3);
  $$->addNode(new AST(':'));
  $$->addNode($5);
  $$->addNode(new AST(';'));
}
;

udp_initial : K_INITIAL IDENTIFIER '=' NUMBER ';' 
{
  $$ = new AST;
  $$->setName("udp_initial");
  $$->setRuleNumber(112);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST('='));
  $$->addNode($4);
  $$->addNode(new AST(';'));
}
;

udp_init_opt : udp_initial 
{
  $$ = new AST;
  $$->setName("udp_init_opt");
  $$->setRuleNumber(113);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| 
{
  $$ = new AST;
  $$->setName("udp_init_opt");
  $$->setRuleNumber(113);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
}
;

udp_input_list : udp_input_sym 
{
  $$ = new AST;
  $$->setName("udp_input_list");
  $$->setRuleNumber(114);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| udp_input_list udp_input_sym 
{
  $$ = new AST;
  $$->setName("udp_input_list");
  $$->setRuleNumber(114);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

udp_input_sym : '0' 
{
  $$ = new AST;
  $$->setName("udp_input_sym");
  $$->setRuleNumber(115);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('0'));
}
| '1' 
{
  $$ = new AST;
  $$->setName("udp_input_sym");
  $$->setRuleNumber(115);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('1'));
}
| 'x' 
{
  $$ = new AST;
  $$->setName("udp_input_sym");
  $$->setRuleNumber(115);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('x'));
}
| '?' 
{
  $$ = new AST;
  $$->setName("udp_input_sym");
  $$->setRuleNumber(115);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('?'));
}
| 'b' 
{
  $$ = new AST;
  $$->setName("udp_input_sym");
  $$->setRuleNumber(115);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('b'));
}
| '*' 
{
  $$ = new AST;
  $$->setName("udp_input_sym");
  $$->setRuleNumber(115);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('*'));
}
| '%' 
{
  $$ = new AST;
  $$->setName("udp_input_sym");
  $$->setRuleNumber(115);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('%'));
}
| 'f' 
{
  $$ = new AST;
  $$->setName("udp_input_sym");
  $$->setRuleNumber(115);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('f'));
}
| 'F' 
{
  $$ = new AST;
  $$->setName("udp_input_sym");
  $$->setRuleNumber(115);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('F'));
}
| 'r' 
{
  $$ = new AST;
  $$->setName("udp_input_sym");
  $$->setRuleNumber(115);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('r'));
}
| 'R' 
{
  $$ = new AST;
  $$->setName("udp_input_sym");
  $$->setRuleNumber(115);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('R'));
}
| 'n' 
{
  $$ = new AST;
  $$->setName("udp_input_sym");
  $$->setRuleNumber(115);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('n'));
}
| 'N' 
{
  $$ = new AST;
  $$->setName("udp_input_sym");
  $$->setRuleNumber(115);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('N'));
}
| 'p' 
{
  $$ = new AST;
  $$->setName("udp_input_sym");
  $$->setRuleNumber(115);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('p'));
}
| 'P' 
{
  $$ = new AST;
  $$->setName("udp_input_sym");
  $$->setRuleNumber(115);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('P'));
}
| '_' 
{
  $$ = new AST;
  $$->setName("udp_input_sym");
  $$->setRuleNumber(115);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('_'));
}
| '+' 
{
  $$ = new AST;
  $$->setName("udp_input_sym");
  $$->setRuleNumber(115);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('+'));
}
;

udp_output_sym : '0' 
{
  $$ = new AST;
  $$->setName("udp_output_sym");
  $$->setRuleNumber(116);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('0'));
}
| '1' 
{
  $$ = new AST;
  $$->setName("udp_output_sym");
  $$->setRuleNumber(116);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('1'));
}
| 'x' 
{
  $$ = new AST;
  $$->setName("udp_output_sym");
  $$->setRuleNumber(116);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('x'));
}
| '-' 
{
  $$ = new AST;
  $$->setName("udp_output_sym");
  $$->setRuleNumber(116);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST('-'));
}
;

udp_port_decl : K_INPUT list_of_variables ';' 
{
  $$ = new AST;
  $$->setName("udp_port_decl");
  $$->setRuleNumber(117);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST(';'));
}
| K_OUTPUT IDENTIFIER ';' 
{
  $$ = new AST;
  $$->setName("udp_port_decl");
  $$->setRuleNumber(117);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST(';'));
}
| K_REG IDENTIFIER ';' 
{
  $$ = new AST;
  $$->setName("udp_port_decl");
  $$->setRuleNumber(117);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST(';'));
}
;

udp_port_decls : udp_port_decl 
{
  $$ = new AST;
  $$->setName("udp_port_decls");
  $$->setRuleNumber(118);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| udp_port_decls udp_port_decl 
{
  $$ = new AST;
  $$->setName("udp_port_decls");
  $$->setRuleNumber(118);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
;

udp_port_list : IDENTIFIER 
{
  $$ = new AST;
  $$->setName("udp_port_list");
  $$->setRuleNumber(119);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| udp_port_list ',' IDENTIFIER 
{
  $$ = new AST;
  $$->setName("udp_port_list");
  $$->setRuleNumber(119);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(','));
  $$->addNode($3);
}
;

udp_primitive : K_PRIMITIVE IDENTIFIER '(' udp_port_list ')' ';' udp_port_decls udp_init_opt udp_body K_ENDPRIMITIVE 
{
  $$ = new AST;
  $$->setName("udp_primitive");
  $$->setRuleNumber(120);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST('('));
  $$->addNode($4);
  $$->addNode(new AST(')'));
  $$->addNode(new AST(';'));
  $$->addNode($7);
  $$->addNode($8);
  $$->addNode($9);
  $$->addNode($10);
}
;

genvar_declaration : K_GENVAR list_of_genvar_identifiers ';' 
{
  $$ = new AST;
  $$->setName("genvar_declaration");
  $$->setRuleNumber(121);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode(new AST(';'));
}
;

list_of_genvar_identifiers : IDENTIFIER
{
  $$ = new AST;
  $$->setName("list_of_genvar_identifiers");
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->setRuleNumber(122);
}
| list_of_genvar_identifiers ',' IDENTIFIER
{
  $1->addNode(new AST(','));
  $1->addNode($3);
  $$ = $1;
}
;
generated_instantiation : K_GENERATE generate_item_list K_ENDGENERATE 
{
  $$ = new AST;
  $$->setName("generated_instantiation");
  $$->setRuleNumber(123);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

generate_item_list : 
{
  $$ = new AST;
  $$->setName("generate_item_list");
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  ;
  $$->setRuleNumber(124);
}
| generate_item_list  generate_item
{
  $1->addNode($2);
  $$ = $1;
}
;
generate_item : module_item 
{
  $$ = new AST;
  $$->setName("generate_item");
  $$->setRuleNumber(125);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_BEGIN generate_item_list K_END 
{
  $$ = new AST;
  $$->setName("generate_item");
  $$->setRuleNumber(125);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| K_BEGIN ':' IDENTIFIER generate_item_list K_END 
{
  $$ = new AST;
  $$->setName("generate_item");
  $$->setRuleNumber(125);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(':'));
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
}
;

generate_if : K_IF '(' expression ')' 
{
  $$ = new AST;
  $$->setName("generate_if");
  $$->setRuleNumber(126);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('('));
  $$->addNode($3);
  $$->addNode(new AST(')'));
}
;

generate_conditional_statement : generate_if generate_block_opt %prec LESS_THAN_K_ELSE
{
  $$ = new AST;
  $$->setName("generate_conditional_statement");
  $$->setRuleNumber(127);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
}
| generate_if generate_block_opt K_ELSE generate_block 
{
  $$ = new AST;
  $$->setName("generate_conditional_statement");
  $$->setRuleNumber(127);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
  $$->addNode($4);
}
;

generate_case_statement : K_CASE '(' expression ')' generate_case_item_list K_ENDCASE 
{
  $$ = new AST;
  $$->setName("generate_case_statement");
  $$->setRuleNumber(128);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('('));
  $$->addNode($3);
  $$->addNode(new AST(')'));
  $$->addNode($5);
  $$->addNode($6);
}
;

generate_case_item_list : generate_case_item
{
  $$ = new AST;
  $$->setName("generate_case_item_list");
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->setRuleNumber(129);
}
| generate_case_item_list  generate_case_item
{
  $1->addNode($2);
  $$ = $1;
}
;
generate_case_item : expression_list2 ':' generate_block_opt 
{
  $$ = new AST;
  $$->setName("generate_case_item");
  $$->setRuleNumber(130);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(':'));
  $$->addNode($3);
}
| K_DEFAULT colon_opt generate_block_opt 
{
  $$ = new AST;
  $$->setName("generate_case_item");
  $$->setRuleNumber(130);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
;

generate_loop_statement : K_FOR '(' genvar_assignment ';' expression ';' genvar_assignment ')' generate_block 
{
  $$ = new AST;
  $$->setName("generate_loop_statement");
  $$->setRuleNumber(131);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('('));
  $$->addNode($3);
  $$->addNode(new AST(';'));
  $$->addNode($5);
  $$->addNode(new AST(';'));
  $$->addNode($7);
  $$->addNode(new AST(')'));
  $$->addNode($9);
}
;

genvar_assignment : IDENTIFIER '=' expression 
{
  $$ = new AST;
  $$->setName("genvar_assignment");
  $$->setRuleNumber(132);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST('='));
  $$->addNode($3);
}
;

generate_block : module_item 
{
  $$ = new AST;
  $$->setName("generate_block");
  $$->setRuleNumber(133);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| K_BEGIN generate_item_list K_END 
{
  $$ = new AST;
  $$->setName("generate_block");
  $$->setRuleNumber(133);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode($2);
  $$->addNode($3);
}
| K_BEGIN ':' IDENTIFIER generate_item_list K_END 
{
  $$ = new AST;
  $$->setName("generate_block");
  $$->setRuleNumber(133);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->addNode(new AST(':'));
  $$->addNode($3);
  $$->addNode($4);
  $$->addNode($5);
}
;

generate_block_opt : generate_block 
{
  $$ = new AST;
  $$->setName("generate_block_opt");
  $$->setRuleNumber(134);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| ';' 
{
  $$ = new AST;
  $$->setName("generate_block_opt");
  $$->setRuleNumber(134);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST(';'));
}
;

expression_list2 : expression
{
  $$ = new AST;
  $$->setName("expression_list2");
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
  $$->setRuleNumber(135);
}
| expression_list2 ',' expression
{
  $1->addNode(new AST(','));
  $1->addNode($3);
  $$ = $1;
}
;
colon_opt : ':' 
{
  $$ = new AST;
  $$->setName("colon_opt");
  $$->setRuleNumber(136);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode(new AST(':'));
}
| 
{
  $$ = new AST;
  $$->setName("colon_opt");
  $$->setRuleNumber(136);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
}
;

automatic_opt : K_AUTOMATIC 
{
  $$ = new AST;
  $$->setName("automatic_opt");
  $$->setRuleNumber(137);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
  $$->addNode($1);
}
| 
{
  $$ = new AST;
  $$->setName("automatic_opt");
  $$->setRuleNumber(137);
  $$->line_number = verilogline_number;
  $$->column_number = verilogcolumn_number;
}
;



%%
