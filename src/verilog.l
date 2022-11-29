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
  #include "AST.h"
  #define YYSTYPE AST *
  #include "verilog.tab.hpp"
  #include <string.h>
  #include <stdio.h>

  extern unsigned int verilogcolumn_number;
  extern unsigned int verilogline_number;
  extern bool verilogFileMode;
  extern std::string verilogString;

  extern void storeVerilogPortComment(const char *,unsigned int, unsigned int);
  extern void storeVerilogDocComment(const char *,unsigned int, unsigned int);

  static unsigned int countLines(const char * text);

#define YY_INPUT(buf,result,max_size) \
  if (verilogFileMode) \
    { \
      if ( ((result = fread( buf, 1, max_size, yyin )) == 0) \
           && ferror( yyin ) ) \
        YY_FATAL_ERROR( "input in flex scanner failed" ); \
    } \
  else \
    { \
      if (verilogString.size() == 0) \
        result = 0; \
      else if (verilogString.size() >= max_size) \
        { \
          strncpy(buf, verilogString.c_str(), max_size); \
          verilogString.erase(0, max_size); \
          result = max_size; \
        } \
      else \
        { \
          result = verilogString.size(); \
          strcpy(buf, verilogString.c_str()); \
          verilogString.erase(); \
        } \
    }

%}

%option noyywrap

sized_decimal    [0-9][0-9_]*[ \t]*\'[sS]?[dD][ \t]*[0-9][0-9_]*
sized_binary     [0-9][0-9_]*[ \t]*\'[sS]?[bB][ \t]*[0-1xzXZ_\?]+
sized_octal      [0-9][0-9_]*[ \t]*\'[sS]?[oO][ \t]*[0-7xzXZ_\?]+
sized_hex        [0-9][0-9_]*[ \t]*\'[sS]?[hH][ \t]*[0-9a-fA-FxzXZ_\?]+
unsized_decimal  \'[sS]?[dD][ \t]*[0-9][0-9_]*
unsized_binary   \'[sS]?[bB][ \t]*[0-1xzXZ_\?]+
unsized_octal    \'[sS]?[oO][ \t]*[0-7xzXZ_\?]+
unsized_hex      \'[sS]?[hH][ \t]*[0-9a-fA-FxzXZ_\?]+
sized_number    {sized_decimal}|{sized_binary}|{sized_octal}|{sized_hex}
unsized_number  {unsized_decimal}|{unsized_binary}|{unsized_octal}|{unsized_hex}
decimal_number  [0-9][0-9_]*
white           [ \t\b\f\r]+
normal_identifier       [a-zA-Z_][a-zA-Z0-9$_]*
backslashed_identifier  \\[^ \t\b\f\r]+
real_time_1     [0-9][0-9_]*\.[0-9][0-9_]*([Ee][+-]?[0-9][0-9_]*)?
real_time_2     [0-9][0-9_]*[Ee][+-]?[0-9][0-9_]*
k_ls       "<<"
k_rs       ">>"
k_le       "<="
k_ge       ">="
k_eg       "=>"
k_sg       "*>"
k_eq       "=="
k_ne       "!="
k_ceq      "==="
k_cne      "!=="
k_lor      "||"
k_land     "&&"
k_nxor     "~^"|"^~"
k_trigger  "->"
k_at       "@"
k_always        always
k_and           and
k_assign        assign
k_automatic     automatic
k_bit           bit
k_begin         begin
k_bool          bool
k_buf           buf
k_bufif0        bufif0
k_bufif1        bufif1
k_case          case
k_casex         casex
k_casez         casez
k_cmos          cmos
k_deassign      deassign
k_default       default
k_defparam      defparam
k_disable       disable
k_else          else
k_end           end
k_endcase       endcase
k_endfunction   endfunction
k_endmodule     endmodule
k_endprimitive  endprimitive
k_endspecify    endspecify
k_endtable      endtable
k_endtask       endtask
k_event         event
k_for           for
k_force         force
k_forever       forever
k_fork          fork
k_function      function
k_genvar        genvar
k_generate      generate
k_endgenerate   endgenerate
k_highz0        highz0
k_highz1        highz1
k_if            if
k_initial       initial
k_inout         inout
k_input         input
k_integer       integer
k_join          join
k_large         large
k_localparam    localparam
k_logic         logic
k_medium        medium
k_module        module
k_nand          nand|"~&"
k_negedge       negedge
k_nmos          nmos
k_nor           nor|"~|"
k_not           not
k_notif0        notif0
k_notif1        notif1
k_or            or
k_output        output
k_parameter     parameter
k_pmos          pmos
k_posedge       posedge
k_primitive     primitive
k_pull0         pull0
k_pull1         pull1
k_pulldown      pulldown
k_pullup        pullup
k_rcmos         rcmos
k_real          real
k_realtime      realtime
k_reg           reg
k_release       release
k_repeat        repeat
k_rnmos         rnmos
k_rpmos         rpmos
k_rtran         rtran
k_rtranif0      rtranif0
k_rtranif1      rtranif1
k_signed        signed
k_unsigned      unsigned
k_small         small
k_specify       specify
k_specparam     specparam
k_strong0       strong0
k_strong1       strong1
k_supply0       supply0
k_supply1       supply1
k_table         table
k_task          task
k_time          time
k_tran          tran
k_tranif0       tranif0
k_tranif1       tranif1
k_tri           tri
k_tri0          tri0
k_tri1          tri1
k_triand        triand
k_trior         trior
k_trireg        trireg
k_wait          wait
k_wand          wand
k_weak0         weak0
k_weak1         weak1
k_while         while
k_wire          wire
k_wreal         wreal
k_wor           wor
k_xnor          xnor
k_xor           xor
hidentifier        [a-zA-Z_][a-zA-Z0-9$_]*(\.[a-zA-Z_][\[\]a-zA-Z0-9$_]*)+
identifier         {normal_identifier}|{backslashed_identifier}
portname           \.{white}?[a-zA-Z_][a-zA-Z0-9$_]*
kk_attribute       \$attribute
system_identifier  \$([a-zA-Z0-9$_]+)
string             \"(\\\"|[^\"\n])*[\"\n]
number             {sized_number}|{unsized_number}|{decimal_number}
realtime           {real_time_1}|{real_time_2}

wisent_literal_string_0 "(*"
wisent_literal_string_1 "*)"
wisent_literal_string_2 "+:"
wisent_literal_string_3 "-:"


%%

{k_ls} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_LS");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_LS; }
{k_rs} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_RS");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_RS; }
{k_le} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_LE");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_LE; }
{k_ge} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_GE");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_GE; }
{k_eg} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_EG");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_EG; }
{k_sg} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_SG");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_SG; }
{k_eq} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_EQ");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_EQ; }
{k_ne} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_NE");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_NE; }
{k_ceq} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_CEQ");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_CEQ; }
{k_cne} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_CNE");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_CNE; }
{k_lor} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_LOR");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_LOR; }
{k_land} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_LAND");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_LAND; }
{k_nxor} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_NXOR");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_NXOR; }
{k_trigger} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_TRIGGER");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_TRIGGER; }
{k_at} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_AT");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_AT; }
{k_always} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_ALWAYS");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_ALWAYS; }
{k_and} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_AND");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_AND; }
{k_assign} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_ASSIGN");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_ASSIGN; }
{k_automatic} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_AUTOMATIC");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_AUTOMATIC; }
{k_bit} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_BIT");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_BIT; }
{k_begin} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_BEGIN");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_BEGIN; }
{k_bool} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_BOOL");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_BOOL; }
{k_buf} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_BUF");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_BUF; }
{k_bufif0} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_BUFIF0");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_BUFIF0; }
{k_bufif1} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_BUFIF1");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_BUFIF1; }
{k_case} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_CASE");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_CASE; }
{k_casex} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_CASEX");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_CASEX; }
{k_casez} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_CASEZ");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_CASEZ; }
{k_cmos} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_CMOS");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_CMOS; }
{k_deassign} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_DEASSIGN");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_DEASSIGN; }
{k_default} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_DEFAULT");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_DEFAULT; }
{k_defparam} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_DEFPARAM");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_DEFPARAM; }
{k_disable} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_DISABLE");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_DISABLE; }
{k_else} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_ELSE");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_ELSE; }
{k_end} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_END");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_END; }
{k_endcase} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_ENDCASE");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_ENDCASE; }
{k_endfunction} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_ENDFUNCTION");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_ENDFUNCTION; }
{k_endmodule} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_ENDMODULE");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_ENDMODULE; }
{k_endprimitive} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_ENDPRIMITIVE");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_ENDPRIMITIVE; }
{k_endspecify} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_ENDSPECIFY");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_ENDSPECIFY; }
{k_endtable} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_ENDTABLE");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_ENDTABLE; }
{k_endtask} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_ENDTASK");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_ENDTASK; }
{k_event} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_EVENT");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_EVENT; }
{k_for} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_FOR");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_FOR; }
{k_force} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_FORCE");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_FORCE; }
{k_forever} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_FOREVER");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_FOREVER; }
{k_fork} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_FORK");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_FORK; }
{k_function} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_FUNCTION");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_FUNCTION; }
{k_genvar} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_GENVAR");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_GENVAR; }
{k_generate} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_GENERATE");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_GENERATE; }
{k_endgenerate} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_ENDGENERATE");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_ENDGENERATE; }
{k_highz0} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_HIGHZ0");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_HIGHZ0; }
{k_highz1} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_HIGHZ1");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_HIGHZ1; }
{k_if} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_IF");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_IF; }
{k_initial} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_INITIAL");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_INITIAL; }
{k_inout} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_INOUT");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_INOUT; }
{k_input} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_INPUT");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_INPUT; }
{k_integer} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_INTEGER");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_INTEGER; }
{k_join} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_JOIN");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_JOIN; }
{k_large} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_LARGE");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_LARGE; }
{k_localparam} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_LOCALPARAM");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_LOCALPARAM; }
{k_logic} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_LOGIC");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_LOGIC; }
{k_medium} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_MEDIUM");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_MEDIUM; }
{k_module} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_MODULE");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_MODULE; }
{k_nand} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_NAND");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_NAND; }
{k_negedge} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_NEGEDGE");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_NEGEDGE; }
{k_nmos} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_NMOS");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_NMOS; }
{k_nor} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_NOR");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_NOR; }
{k_not} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_NOT");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_NOT; }
{k_notif0} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_NOTIF0");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_NOTIF0; }
{k_notif1} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_NOTIF1");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_NOTIF1; }
{k_or} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_OR");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_OR; }
{k_output} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_OUTPUT");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_OUTPUT; }
{k_parameter} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_PARAMETER");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_PARAMETER; }
{k_pmos} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_PMOS");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_PMOS; }
{k_posedge} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_POSEDGE");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_POSEDGE; }
{k_primitive} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_PRIMITIVE");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_PRIMITIVE; }
{k_pull0} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_PULL0");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_PULL0; }
{k_pull1} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_PULL1");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_PULL1; }
{k_pulldown} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_PULLDOWN");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_PULLDOWN; }
{k_pullup} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_PULLUP");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_PULLUP; }
{k_rcmos} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_RCMOS");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_RCMOS; }
{k_real} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_REAL");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_REAL; }
{k_realtime} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_REALTIME");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_REALTIME; }
{k_reg} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_REG");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_REG; }
{k_release} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_RELEASE");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_RELEASE; }
{k_repeat} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_REPEAT");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_REPEAT; }
{k_rnmos} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_RNMOS");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_RNMOS; }
{k_rpmos} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_RPMOS");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_RPMOS; }
{k_rtran} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_RTRAN");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_RTRAN; }
{k_rtranif0} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_RTRANIF0");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_RTRANIF0; }
{k_rtranif1} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_RTRANIF1");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_RTRANIF1; }
{k_signed} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_SIGNED");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_SIGNED; }
{k_unsigned} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_UNSIGNED");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_UNSIGNED; }
{k_small} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_SMALL");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_SMALL; }
{k_specify} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_SPECIFY");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_SPECIFY; }
{k_specparam} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_SPECPARAM");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_SPECPARAM; }
{k_strong0} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_STRONG0");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_STRONG0; }
{k_strong1} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_STRONG1");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_STRONG1; }
{k_supply0} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_SUPPLY0");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_SUPPLY0; }
{k_supply1} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_SUPPLY1");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_SUPPLY1; }
{k_table} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_TABLE");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_TABLE; }
{k_task} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_TASK");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_TASK; }
{k_time} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_TIME");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_TIME; }
{k_tran} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_TRAN");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_TRAN; }
{k_tranif0} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_TRANIF0");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_TRANIF0; }
{k_tranif1} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_TRANIF1");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_TRANIF1; }
{k_tri} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_TRI");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_TRI; }
{k_tri0} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_TRI0");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_TRI0; }
{k_tri1} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_TRI1");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_TRI1; }
{k_triand} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_TRIAND");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_TRIAND; }
{k_trior} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_TRIOR");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_TRIOR; }
{k_trireg} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_TRIREG");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_TRIREG; }
{k_wait} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_WAIT");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_WAIT; }
{k_wand} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_WAND");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_WAND; }
{k_weak0} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_WEAK0");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_WEAK0; }
{k_weak1} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_WEAK1");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_WEAK1; }
{k_while} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_WHILE");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_WHILE; }
{k_wire} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_WIRE");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_WIRE; }
{k_wreal} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_WREAL");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_WREAL; }
{k_wor} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_WOR");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_WOR; }
{k_xnor} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_XNOR");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_XNOR; }
{k_xor} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("K_XOR");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return K_XOR; }
{hidentifier} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("HIDENTIFIER");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return HIDENTIFIER; }
{identifier} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("IDENTIFIER");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return IDENTIFIER; }
{portname} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("PORTNAME");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return PORTNAME; }
{kk_attribute} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("KK_ATTRIBUTE");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return KK_ATTRIBUTE; }
{system_identifier} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("SYSTEM_IDENTIFIER");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return SYSTEM_IDENTIFIER; }
{string} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("STRING");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return STRING; }
{number} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("NUMBER");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return NUMBER; }
{realtime} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("REALTIME");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return REALTIME; }
 \/\/\/\/[^\n]*   {
		  storeVerilogPortComment(verilogtext,verilogline_number,verilogcolumn_number);
                  verilogline_number += countLines(verilogtext);
                  verilogcolumn_number += verilogleng;
                }
 \/\/\/[^\n]*   {
		  storeVerilogDocComment(verilogtext,verilogline_number,verilogcolumn_number);
                  verilogline_number += countLines(verilogtext);
                  verilogcolumn_number += verilogleng;
                }
          \`celldefine.*   {
		  
                  verilogline_number += countLines(verilogtext);
                  verilogcolumn_number += verilogleng;
                }
     \`default_nettype.*   {
		  
                  verilogline_number += countLines(verilogtext);
                  verilogcolumn_number += verilogleng;
                }
              \`define.*   {
		  
                  verilogline_number += countLines(verilogtext);
                  verilogcolumn_number += verilogleng;
                }
                \`else.*   {
		  
                  verilogline_number += countLines(verilogtext);
                  verilogcolumn_number += verilogleng;
                }
               \`endif.*   {
		  
                  verilogline_number += countLines(verilogtext);
                  verilogcolumn_number += verilogleng;
                }
       \`endcelldefine.*   {
		  
                  verilogline_number += countLines(verilogtext);
                  verilogcolumn_number += verilogleng;
                }
               \`ifdef.*   {
		  
                  verilogline_number += countLines(verilogtext);
                  verilogcolumn_number += verilogleng;
                }
              \`ifndef.*   {
		  
                  verilogline_number += countLines(verilogtext);
                  verilogcolumn_number += verilogleng;
                }
             \`include.*   {
		  
                  verilogline_number += countLines(verilogtext);
                  verilogcolumn_number += verilogleng;
                }
                \`line.*   {
		  
                  verilogline_number += countLines(verilogtext);
                  verilogcolumn_number += verilogleng;
                }
 \`nounconnected_drive.*   {
		  
                  verilogline_number += countLines(verilogtext);
                  verilogcolumn_number += verilogleng;
                }
            \`resetall.*   {
		  
                  verilogline_number += countLines(verilogtext);
                  verilogcolumn_number += verilogleng;
                }
           \`timescale.*   {
		  
                  verilogline_number += countLines(verilogtext);
                  verilogcolumn_number += verilogleng;
                }
   \`unconnected_drive.*   {
		  
                  verilogline_number += countLines(verilogtext);
                  verilogcolumn_number += verilogleng;
                }
               \`undef.*   {
		  
                  verilogline_number += countLines(verilogtext);
                  verilogcolumn_number += verilogleng;
                }
               \/\/.*   {
		  
                  verilogline_number += countLines(verilogtext);
                  verilogcolumn_number += verilogleng;
                }
                 \/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+\/   {
		  
                  verilogline_number += countLines(verilogtext);
                  verilogcolumn_number += verilogleng;
                }
                     {
		  
                  verilogline_number += countLines(verilogtext);
                  verilogcolumn_number += verilogleng;
                }
               \r   {
		  
                  verilogline_number += countLines(verilogtext);
                  verilogcolumn_number += verilogleng;
                }

{wisent_literal_string_0} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("WISENT_LITERAL_STRING_0");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return WISENT_LITERAL_STRING_0; }
{wisent_literal_string_1} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("WISENT_LITERAL_STRING_1");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return WISENT_LITERAL_STRING_1; }
{wisent_literal_string_2} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("WISENT_LITERAL_STRING_2");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return WISENT_LITERAL_STRING_2; }
{wisent_literal_string_3} {
                     veriloglval = new AST(verilogtext);
                     veriloglval->setTokenType("WISENT_LITERAL_STRING_3");
                     veriloglval->line_number = verilogline_number;
                     veriloglval->column_number = verilogcolumn_number;
                     verilogline_number += countLines(verilogtext);
                     verilogcolumn_number += verilogleng;
                     return WISENT_LITERAL_STRING_3; }

[ \t]                   { ++verilogcolumn_number; }
[\n]                    { verilogcolumn_number = 1;
                          ++verilogline_number; }
.                       return *verilogtext;

%%

unsigned int verilogcolumn_number = 1;
unsigned int verilogline_number = 1;
bool verilogFileMode = true;
std::string verilogString;

static unsigned int countLines(const char * text)
{
  unsigned int result = 0;
  while (*text != 0)
    {
      if (*text == '\n')
        ++result;
      ++text;
    }
  return result;
}

void verilogFlushLexBuffer()
{
  YY_FLUSH_BUFFER;
}


