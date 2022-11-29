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
  #include "vhdl.tab.hpp"
  #include <string.h>
  #include <stdio.h>

  extern unsigned int vhdlcolumn_number;
  extern unsigned int vhdlline_number;
  extern bool vhdlFileMode;
  extern std::string vhdlString;

  extern void storePortComment(const char *,unsigned int, unsigned int);
  extern void storeDocComment(const char *,unsigned int, unsigned int);

  static unsigned int countLines(const char * text);

#define YY_INPUT(buf,result,max_size) \
  if (vhdlFileMode) \
    { \
      if ( ((result = fread( buf, 1, max_size, yyin )) == 0) \
           && ferror( yyin ) ) \
        YY_FATAL_ERROR( "input in flex scanner failed" ); \
    } \
  else \
    { \
      if (vhdlString.size() == 0) \
        result = 0; \
      else if (vhdlString.size() >= max_size) \
        { \
          strncpy(buf, vhdlString.c_str(), max_size); \
          vhdlString.erase(0, max_size); \
          result = max_size; \
        } \
      else \
        { \
          result = vhdlString.size(); \
          strcpy(buf, vhdlString.c_str()); \
          vhdlString.erase(); \
        } \
    }

%}

%option noyywrap

digit                                 [0-9]
special_character_without_lp          [\#\&\'\)\*\+\,\-\.\/\:\;\<\=\>\_\|]
special_character                     ({special_character_without_lp}|\()
space_character                       [ \t]
letter                                [a-z]
other_special_character               [\!\$\@\?\[\\\]\^\`\{\}\~]
graphic_character_without_lp          ({basic_graphic_character_without_lp}|{other_special_character})
graphic_character                     ({graphic_character_without_lp}|\()
basic_graphic_character_without_lp    ({letter}|{digit}|{special_character_without_lp}|{space_character})
basic_graphic_character               ({basic_graphic_character_without_lp}|\()
decimal_literal                       {integer}(\.{integer})?({exponent})?
integer                               {digit}(_?{digit})*
exponent                              ([e][-+]?{integer})
base                                  {integer}
based_integer                         {extended_digit}(_?{extended_digit})*
extended_digit                        ({digit}|[a-f])
base_specifier                        (b|o|x)
abs            abs
access         access
after          after
alias          alias
all            all
and            and
architecture   architecture
array          array
assert         assert
attribute      attribute
vhdl_begin     begin
block          block
body           body
buffer         buffer
bus            bus
case           case
component      component
configuration  configuration
constant       constant
disconnect     disconnect
downto         downto
else           else
elsif          elsif
end            end
entity         entity
exit           exit
vhdl_file      file
for            for
function       function
generate       generate
generic        generic
guarded        guarded
if             if
impure         impure
in             in
inout          inout
is             is
label          label
library        library
linkage        linkage
loop           loop
map            map
mod            mod
nand           nand
new            new
next           next
nor            nor
not            not
vhdl_null      null
of             of
on             on
open           open
or             or
others         others
out            out
package        package
port           port
procedure      procedure
process        process
pure           pure
range          range
record         record
register       register
rem            rem
report         report
return         return
select         select
severity       severity
shared         shared
signal         signal
subtype        subtype
then           then
to             to
transport      transport
type           type
units          units
until          until
use            use
variable       variable
wait           wait
when           when
while          while
with           with
xor            xor
xnor           xnor
ampersand      \&
tick           \'
comma          \,
arrow          \=\>
box            \<\>
equal          \=
greater_equal  \>\=
greater        \>
left_paren     \(
less_equal     \<\=
less           \<
minus          \-
not_equal      \/\=
plus           \+
pow            \*\*
right_paren    \)
semicolon      \;
star           \*
var_assign     \:\=
colon          \:
bar            \||\!
dot            \.
slash          \/
sll            sll
srl            srl
sla            sla
sra            sra
rol            rol
ror            ror
left_bracket   \[
right_bracket  \]
identifier       [a-z][a-z_0-9]*
abstract_lit     ({decimal_literal})|({base}#{based_integer}(\.{based_integer})?#({exponent})?)|({base}:{based_integer}(\.{based_integer})?:({exponent})?)
character_lit    '({graphic_character_without_lp}|\"|\%)'
string_lit       (\"({graphic_character}|(\"\")|\%)*\")|(\%({graphic_character}|(\%\%)|\")*\%)
bit_string_lit   {base_specifier}(\"{extended_digit}(_?{extended_digit})*\"|\%{extended_digit}(_?{extended_digit})*\%)
%option case-insensitive



%%

{abs} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("ABS");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return ABS; }
{access} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("ACCESS");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return ACCESS; }
{after} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("AFTER");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return AFTER; }
{alias} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("ALIAS");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return ALIAS; }
{all} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("ALL");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return ALL; }
{and} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("AND");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return AND; }
{architecture} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("ARCHITECTURE");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return ARCHITECTURE; }
{array} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("ARRAY");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return ARRAY; }
{assert} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("ASSERT");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return ASSERT; }
{attribute} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("ATTRIBUTE");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return ATTRIBUTE; }
{vhdl_begin} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("VHDL_BEGIN");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return VHDL_BEGIN; }
{block} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("BLOCK");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return BLOCK; }
{body} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("BODY");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return BODY; }
{buffer} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("BUFFER");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return BUFFER; }
{bus} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("BUS");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return BUS; }
{case} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("CASE");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return CASE; }
{component} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("COMPONENT");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return COMPONENT; }
{configuration} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("CONFIGURATION");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return CONFIGURATION; }
{constant} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("CONSTANT");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return CONSTANT; }
{disconnect} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("DISCONNECT");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return DISCONNECT; }
{downto} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("DOWNTO");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return DOWNTO; }
{else} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("ELSE");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return ELSE; }
{elsif} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("ELSIF");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return ELSIF; }
{end} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("END");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return END; }
{entity} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("ENTITY");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return ENTITY; }
{exit} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("EXIT");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return EXIT; }
{vhdl_file} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("VHDL_FILE");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return VHDL_FILE; }
{for} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("FOR");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return FOR; }
{function} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("FUNCTION");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return FUNCTION; }
{generate} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("GENERATE");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return GENERATE; }
{generic} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("GENERIC");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return GENERIC; }
{guarded} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("GUARDED");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return GUARDED; }
{if} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("IF");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return IF; }
{impure} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("IMPURE");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return IMPURE; }
{in} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("IN");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return IN; }
{inout} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("INOUT");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return INOUT; }
{is} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("IS");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return IS; }
{label} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("LABEL");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return LABEL; }
{library} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("LIBRARY");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return LIBRARY; }
{linkage} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("LINKAGE");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return LINKAGE; }
{loop} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("LOOP");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return LOOP; }
{map} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("MAP");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return MAP; }
{mod} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("MOD");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return MOD; }
{nand} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("NAND");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return NAND; }
{new} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("NEW");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return NEW; }
{next} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("NEXT");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return NEXT; }
{nor} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("NOR");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return NOR; }
{not} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("NOT");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return NOT; }
{vhdl_null} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("VHDL_NULL");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return VHDL_NULL; }
{of} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("OF");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return OF; }
{on} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("ON");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return ON; }
{open} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("OPEN");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return OPEN; }
{or} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("OR");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return OR; }
{others} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("OTHERS");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return OTHERS; }
{out} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("OUT");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return OUT; }
{package} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("PACKAGE");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return PACKAGE; }
{port} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("PORT");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return PORT; }
{procedure} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("PROCEDURE");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return PROCEDURE; }
{process} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("PROCESS");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return PROCESS; }
{pure} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("PURE");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return PURE; }
{range} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("RANGE");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return RANGE; }
{record} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("RECORD");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return RECORD; }
{register} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("REGISTER");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return REGISTER; }
{rem} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("REM");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return REM; }
{report} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("REPORT");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return REPORT; }
{return} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("RETURN");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return RETURN; }
{select} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("SELECT");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return SELECT; }
{severity} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("SEVERITY");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return SEVERITY; }
{shared} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("SHARED");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return SHARED; }
{signal} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("SIGNAL");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return SIGNAL; }
{subtype} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("SUBTYPE");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return SUBTYPE; }
{then} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("THEN");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return THEN; }
{to} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("TO");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return TO; }
{transport} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("TRANSPORT");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return TRANSPORT; }
{type} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("TYPE");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return TYPE; }
{units} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("UNITS");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return UNITS; }
{until} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("UNTIL");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return UNTIL; }
{use} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("USE");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return USE; }
{variable} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("VARIABLE");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return VARIABLE; }
{wait} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("WAIT");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return WAIT; }
{when} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("WHEN");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return WHEN; }
{while} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("WHILE");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return WHILE; }
{with} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("WITH");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return WITH; }
{xor} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("XOR");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return XOR; }
{xnor} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("XNOR");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return XNOR; }
{ampersand} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("AMPERSAND");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return AMPERSAND; }
{tick} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("TICK");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return TICK; }
{comma} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("COMMA");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return COMMA; }
{arrow} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("ARROW");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return ARROW; }
{box} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("BOX");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return BOX; }
{equal} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("EQUAL");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return EQUAL; }
{greater_equal} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("GREATER_EQUAL");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return GREATER_EQUAL; }
{greater} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("GREATER");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return GREATER; }
{left_paren} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("LEFT_PAREN");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return LEFT_PAREN; }
{less_equal} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("LESS_EQUAL");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return LESS_EQUAL; }
{less} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("LESS");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return LESS; }
{minus} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("MINUS");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return MINUS; }
{not_equal} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("NOT_EQUAL");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return NOT_EQUAL; }
{plus} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("PLUS");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return PLUS; }
{pow} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("POW");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return POW; }
{right_paren} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("RIGHT_PAREN");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return RIGHT_PAREN; }
{semicolon} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("SEMICOLON");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return SEMICOLON; }
{star} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("STAR");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return STAR; }
{var_assign} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("VAR_ASSIGN");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return VAR_ASSIGN; }
{colon} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("COLON");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return COLON; }
{bar} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("BAR");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return BAR; }
{dot} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("DOT");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return DOT; }
{slash} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("SLASH");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return SLASH; }
{sll} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("SLL");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return SLL; }
{srl} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("SRL");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return SRL; }
{sla} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("SLA");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return SLA; }
{sra} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("SRA");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return SRA; }
{rol} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("ROL");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return ROL; }
{ror} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("ROR");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return ROR; }
{left_bracket} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("LEFT_BRACKET");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return LEFT_BRACKET; }
{right_bracket} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("RIGHT_BRACKET");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return RIGHT_BRACKET; }
{identifier} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("IDENTIFIER");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return IDENTIFIER; }
{abstract_lit} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("ABSTRACT_LIT");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return ABSTRACT_LIT; }
{character_lit} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("CHARACTER_LIT");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return CHARACTER_LIT; }
{string_lit} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("STRING_LIT");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return STRING_LIT; }
{bit_string_lit} {
                     vhdllval = new AST(vhdltext);
                     vhdllval->setTokenType("BIT_STRING_LIT");
                     vhdllval->line_number = vhdlline_number;
                     vhdllval->column_number = vhdlcolumn_number;
                     vhdlline_number += countLines(vhdltext);
                     vhdlcolumn_number += vhdlleng;
                     return BIT_STRING_LIT; }
 \-\-\/\/[^\n]*   {
		  storePortComment(vhdltext,vhdlline_number,vhdlcolumn_number);
                  vhdlline_number += countLines(vhdltext);
                  vhdlcolumn_number += vhdlleng;
                }
 \-\-\/[^\n]*   {
		  storeDocComment(vhdltext,vhdlline_number,vhdlcolumn_number);
                  vhdlline_number += countLines(vhdltext);
                  vhdlcolumn_number += vhdlleng;
                }
         \-\-[^\n]*   {
		  
                  vhdlline_number += countLines(vhdltext);
                  vhdlcolumn_number += vhdlleng;
                }
           {
		  
                  vhdlline_number += countLines(vhdltext);
                  vhdlcolumn_number += vhdlleng;
                }
        \r   {
		  
                  vhdlline_number += countLines(vhdltext);
                  vhdlcolumn_number += vhdlleng;
                }


[ \t]                   { ++vhdlcolumn_number; }
[\n]                    { vhdlcolumn_number = 1;
                          ++vhdlline_number; }
.                       return *vhdltext;

%%

unsigned int vhdlcolumn_number = 1;
unsigned int vhdlline_number = 1;
bool vhdlFileMode = true;
std::string vhdlString;

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

void vhdlFlushLexBuffer()
{
  YY_FLUSH_BUFFER;
}


