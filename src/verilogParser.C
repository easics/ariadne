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


#include "verilogParser.h"
#include "AriException.h"
#include "StringUtil.h"
#include <cstdio>
#include <cstring>
#include <cerrno>

extern FILE * verilogin;
extern unsigned int verilogcolumn_number;
extern unsigned int verilogline_number;
extern bool verilogFileMode;
extern std::string verilogString;

int verilogparse();
void verilogFlushLexBuffer();
static std::string source_name;

verilogParser::verilogParser()
{
}

verilogParser::~verilogParser()
{
}

void verilogParser::parseFile(const char * filename)
{
  source_name = std::string("In file ") + filename;

  verilogin = fopen(filename, "r");

  if (!verilogin)
    {
      throw AriException(std::string("Unable to open ") + filename + " : " +
                              strerror(errno));
    }

  verilogcolumn_number = 1;
  verilogline_number = 1;
  verilogFileMode = true;

  verilogparse();
  verilogFlushLexBuffer();

  fclose(verilogin);
}

void verilogParser::parseString(const std::string & s)
{
  source_name = "In a string";
  verilogString = s;
  verilogcolumn_number = 1;
  verilogline_number = 1;
  verilogFileMode = false;

  verilogparse();
  verilogFlushLexBuffer();
}

void verilogerror(const char * message)
{
  verilogFlushLexBuffer();
  throw AriException(source_name + ", on line " +
                     StringUtil::number(verilogline_number) + ", column " +
                     StringUtil::number(verilogcolumn_number) + " : " +
                     message);
}
