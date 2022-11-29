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
  #include "ariFile.tab.hpp"
  #include <string.h>
  #include <stdio.h>

  extern unsigned int ariFilecolumn_number;
  extern unsigned int ariFileline_number;
  extern bool ariFileFileMode;
  extern std::string ariFileString;

  extern void parseLineMarker(const char *,unsigned int, unsigned int);

  static unsigned int countLines(const char * text);

#define YY_INPUT(buf,result,max_size) \
  if (ariFileFileMode) \
    { \
      if ( ((result = fread( buf, 1, max_size, yyin )) == 0) \
           && ferror( yyin ) ) \
        YY_FATAL_ERROR( "input in flex scanner failed" ); \
    } \
  else \
    { \
      if (ariFileString.size() == 0) \
        result = 0; \
      else if (ariFileString.size() >= max_size) \
        { \
          strncpy(buf, ariFileString.c_str(), max_size); \
          ariFileString.erase(0, max_size); \
          result = max_size; \
        } \
      else \
        { \
          result = ariFileString.size(); \
          strcpy(buf, ariFileString.c_str()); \
          ariFileString.erase(); \
        } \
    }

%}

%option noyywrap

hierarchy  hierarchy
info  info
end  end
port  port
generic  generic
signal  signal
constant  constant
xrfp  xrfp
xrf  xrf
assign  assign
tln_from  from
library  library
configuration  configuration
architecture  architecture
component  component
statements  statements
declarations  declarations
declarationstop  declarationstop
ruby_post  ruby_post
ruby  ruby
python_post  python_post
python  python
remove_package  remove_package
add_package  add_package
move_package  move_package
exec  exec
post_exec  post_exec
in  in
out  out
inout  inout
auto  auto
varassign  ":="
rename_ports  rename_ports
group_comment  group_comment
port_comment  port_comment
keep_case  keep_case
language  language
add_header  add_header
move_header  move_header
remove_header  remove_header
create  create
sc_method  sc_method
sc_thread  sc_thread
config_in_arch  config_in_arch
entity_comment  entity_comment
arch_comment  arch_comment
inst_comment  inst_comment
file_header  file_header
identifier  [a-zA-Z_][a-zA-Z0-9_]*
%option case-insensitive



%%

{hierarchy} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("HIERARCHY");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return HIERARCHY; }
{info} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("INFO");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return INFO; }
{end} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("END");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return END; }
{port} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("PORT");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return PORT; }
{generic} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("GENERIC");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return GENERIC; }
{signal} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("SIGNAL");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return SIGNAL; }
{constant} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("CONSTANT");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return CONSTANT; }
{xrfp} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("XRFP");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return XRFP; }
{xrf} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("XRF");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return XRF; }
{assign} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("ASSIGN");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return ASSIGN; }
{tln_from} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("TLN_FROM");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return TLN_FROM; }
{library} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("LIBRARY");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return LIBRARY; }
{configuration} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("CONFIGURATION");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return CONFIGURATION; }
{architecture} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("ARCHITECTURE");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return ARCHITECTURE; }
{component} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("COMPONENT");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return COMPONENT; }
{statements} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("STATEMENTS");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return STATEMENTS; }
{declarations} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("DECLARATIONS");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return DECLARATIONS; }
{declarationstop} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("DECLARATIONSTOP");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return DECLARATIONSTOP; }
{ruby_post} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("RUBY_POST");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return RUBY_POST; }
{ruby} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("RUBY");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return RUBY; }
{python_post} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("PYTHON_POST");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return PYTHON_POST; }
{python} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("PYTHON");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return PYTHON; }
{remove_package} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("REMOVE_PACKAGE");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return REMOVE_PACKAGE; }
{add_package} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("ADD_PACKAGE");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return ADD_PACKAGE; }
{move_package} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("MOVE_PACKAGE");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return MOVE_PACKAGE; }
{exec} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("EXEC");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return EXEC; }
{post_exec} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("POST_EXEC");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return POST_EXEC; }
{in} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("IN");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return IN; }
{out} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("OUT");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return OUT; }
{inout} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("INOUT");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return INOUT; }
{auto} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("AUTO");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return AUTO; }
{varassign} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("VARASSIGN");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return VARASSIGN; }
{rename_ports} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("RENAME_PORTS");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return RENAME_PORTS; }
{group_comment} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("GROUP_COMMENT");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return GROUP_COMMENT; }
{port_comment} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("PORT_COMMENT");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return PORT_COMMENT; }
{keep_case} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("KEEP_CASE");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return KEEP_CASE; }
{language} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("LANGUAGE");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return LANGUAGE; }
{add_header} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("ADD_HEADER");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return ADD_HEADER; }
{move_header} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("MOVE_HEADER");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return MOVE_HEADER; }
{remove_header} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("REMOVE_HEADER");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return REMOVE_HEADER; }
{create} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("CREATE");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return CREATE; }
{sc_method} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("SC_METHOD");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return SC_METHOD; }
{sc_thread} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("SC_THREAD");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return SC_THREAD; }
{config_in_arch} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("CONFIG_IN_ARCH");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return CONFIG_IN_ARCH; }
{entity_comment} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("ENTITY_COMMENT");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return ENTITY_COMMENT; }
{arch_comment} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("ARCH_COMMENT");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return ARCH_COMMENT; }
{inst_comment} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("INST_COMMENT");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return INST_COMMENT; }
{file_header} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("FILE_HEADER");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return FILE_HEADER; }
{identifier} {
                     ariFilelval = new AST(ariFiletext);
                     ariFilelval->setTokenType("IDENTIFIER");
                     ariFilelval->line_number = ariFileline_number;
                     ariFilelval->column_number = ariFilecolumn_number;
                     ariFileline_number += countLines(ariFiletext);
                     ariFilecolumn_number += ariFileleng;
                     return IDENTIFIER; }
 --.*   {
		  
                  ariFileline_number += countLines(ariFiletext);
                  ariFilecolumn_number += ariFileleng;
                }
 ^#.*   {
		  parseLineMarker(ariFiletext,ariFileline_number,ariFilecolumn_number);
                  ariFileline_number += countLines(ariFiletext);
                  ariFilecolumn_number += ariFileleng;
                }


[ \t]                   { ++ariFilecolumn_number; }
[\n]                    { ariFilecolumn_number = 1;
                          ++ariFileline_number; }
.                       return *ariFiletext;

%%

unsigned int ariFilecolumn_number = 1;
unsigned int ariFileline_number = 1;
bool ariFileFileMode = true;
std::string ariFileString;

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

void ariFileFlushLexBuffer()
{
  YY_FLUSH_BUFFER;
}

std::string read_to_string(const std::string & lookFor, bool consumeLookFor)
{
  std::string result;
  char c;

  if (lookFor == ")")
    {
      int parenLevel = 0;
      while (true)
        {
          c = yyinput();
          ++ariFilecolumn_number;
          if (c == '\n')
            {
              ariFilecolumn_number = 1;
              ++ariFileline_number;
            }

          if (c == EOF)
            return result;
          if (c == '(')
            ++parenLevel;
          if (c == ')')
            {
              if (parenLevel <= 0)
                {
                  if (!consumeLookFor)
                    unput(c);
                  else
                    result += c;
                  break;
                }
              else
                --parenLevel;
            }
          result += c;

        }
    }
  while (result.length() < lookFor.length())
    {
      c = yyinput();
      ++ariFilecolumn_number;
      if (c == '\n')
        {
          ariFilecolumn_number = 1;
          ++ariFileline_number;
        }

      if (c == EOF)
        return result;
      result += c;
    }

  while (result.substr(result.length() - lookFor.length(),
                       lookFor.length()) != lookFor)
    {
      c = yyinput();
      ++ariFilecolumn_number;
      if (c == '\n')
        {
          ariFilecolumn_number = 1;
          ++ariFileline_number;
        }

      if (c == EOF)
        return result;
      result += c;
    }

  if (!consumeLookFor)
    {
      result.erase(result.length() - lookFor.length(), lookFor.length());

      for (unsigned int i = 0; i < lookFor.length(); ++i)
        unput(lookFor[lookFor.length() - i - 1]);
    }

  return result;
}

