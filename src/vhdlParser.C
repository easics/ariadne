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


#include "vhdlParser.h"
#include "AriException.h"
#include "StringUtil.h"
#include <cstdio>
#include <cstring>
#include <cerrno>

extern FILE * vhdlin;
extern unsigned int vhdlcolumn_number;
extern unsigned int vhdlline_number;
extern bool vhdlFileMode;
extern std::string vhdlString;

int vhdlparse();
void vhdlFlushLexBuffer();
static std::string source_name;

vhdlParser::vhdlParser()
{
}

vhdlParser::~vhdlParser()
{
}

void vhdlParser::parseFile(const char * filename)
{
  source_name = std::string("In file ") + filename;

  vhdlin = fopen(filename, "r");

  if (!vhdlin)
    {
      throw AriException(std::string("Unable to open ") + filename + " : " +
                         strerror(errno));
    }

  vhdlcolumn_number = 1;
  vhdlline_number = 1;
  vhdlFileMode = true;

  vhdlparse();
  vhdlFlushLexBuffer();

  fclose(vhdlin);
}

void vhdlParser::parseString(const std::string & s)
{
  source_name = "In a string";
  vhdlString = s;
  vhdlcolumn_number = 1;
  vhdlline_number = 1;
  vhdlFileMode = false;

  vhdlparse();
  vhdlFlushLexBuffer();
}

void vhdlerror(const char * message)
{
  vhdlFlushLexBuffer();
  throw AriException(source_name + ", on line " +
                     StringUtil::number(vhdlline_number) + ", column " +
                     StringUtil::number(vhdlcolumn_number) + " : " +
                     message);
}
