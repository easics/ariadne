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


#include "ariFileParser.h"
#include "AriException.h"
#include "StringUtil.h"
#include "PreProcessParseContext.h"
#include "AriOptions.h"
#include <cstdio>
#include <cstring>
#include <cerrno>
#include <fstream>
#include <stdexcept>
#include <unistd.h>

extern FILE * ariFilein;
extern unsigned int ariFilecolumn_number;
extern unsigned int ariFileline_number;
extern bool ariFileFileMode;
extern std::string ariFileString;

int ariFileparse();
void ariFileFlushLexBuffer();
static std::string source_name;
static ariFileParser * theAriFileParser = 0;
std::string ariFilefilename;

void parseLineMarker(const char * text,unsigned int line, unsigned int column)
{
  theAriFileParser->parseLineMarker(text, line, column);
}

ariFileParser::ariFileParser()
{
  theAriFileParser = this;
}

ariFileParser::~ariFileParser()
{
}

void ariFileParser::parseFile(const char * filename)
{
  char tmpname[256];
  sprintf(tmpname, "/tmp/ariadnetmpXXXXXX");
  int fd = mkstemp(tmpname);
  if (!fd)
    throw std::runtime_error("unable to create temporary file in /tmp");
  std::ofstream preprocessedFile(tmpname);
  PreProcessParseContext preprocessor;
  for (auto define=AriOptions::getInstance()->defines.begin();
       define!=AriOptions::getInstance()->defines.end(); ++define)
    preprocessor.addDefine(*define);
  preprocessor.result = &preprocessedFile;

  preprocessor.parseFile(filename);
  preprocessedFile.close();
  auto preprocessedFiles = preprocessor.getIncludedFiles();
  for (auto file : preprocessedFiles)
    includedFiles_.insert(file);

  ariFilein = fdopen(fd, "r");
  if (!ariFilein)
    throw std::runtime_error("Unable to open preprocess result file " +
                             std::string(tmpname));
  unlink(tmpname);
  source_name = std::string("In file ") + filename;

  ariFilecolumn_number = 1;
  ariFileline_number = 1;
  ariFileFileMode = true;
  ariFilefilename = filename;

  if (ariFileparse())
    {
      ariFileFlushLexBuffer();
      fclose(ariFilein);
      throw std::runtime_error(makeErrorLocation() + errorMessage_);
    }
  ariFileFlushLexBuffer();

  fclose(ariFilein);
}

void ariFileParser::parseString(const std::string & s)
{
  source_name = "In a string";
  ariFileString = s;
  ariFilecolumn_number = 1;
  ariFileline_number = 1;
  ariFileFileMode = false;

  ariFileparse();
  ariFileFlushLexBuffer();
}

void ariFileParser::parseLineMarker(const char * text,
                                    unsigned int line_x,
                                    unsigned int column)
{
  char filename[256];
  unsigned int flag = 0;
  unsigned int line = 0;
  sscanf(text, "# %u %s %u\n", &line, filename, &flag);
  --line;
  char * filenameNoQuotes = filename + 1; // remove quotes
  filenameNoQuotes[strlen(filenameNoQuotes)-1] = 0;
  if (flag == 1)
    pushInclude(ariFilefilename, ariFileline_number, filenameNoQuotes);
  if (flag == 2)
    popInclude();
  ariFileline_number = line;
  ariFilecolumn_number = 1;
  ariFilefilename = filenameNoQuotes;
}

void ariFileParser::setErrorMessage(const std::string & message)
{
  errorMessage_ = message;
}

void ariFileParser::pushInclude(const std::string & fromFilename,
                                unsigned int line,
                                const std::string & toFilename)
{
  IncludeInfo ii;
  ii.filename = fromFilename;
  ii.line = line;
  includeStack_.push_back(ii);
  //includedFiles_.insert(toFilename);
}

void ariFileParser::popInclude()
{
  if (!includeStack_.empty())
    includeStack_.pop_back();
}

std::string ariFileParser::makeErrorLocation()
{
  std::string result;
  result += "In " + ariFilefilename + ":" +
    StringUtil::number(ariFileline_number) + ":" +
    StringUtil::number(ariFilecolumn_number) + "\n";
  for (IncludeInfoArray::const_reverse_iterator from=includeStack_.rbegin();
       from!=includeStack_.rend(); ++from)
    {
      result += "From " + from->filename + ":" +
        StringUtil::number(from->line) + "\n";
    }
  return result;
}

int ariFileerror(const char * message)
{
  theAriFileParser->setErrorMessage(message);
  ariFileFlushLexBuffer();
  return 1;
  throw AriException(source_name + ", on line " +
                     StringUtil::number(ariFileline_number) + ", column " +
                     StringUtil::number(ariFilecolumn_number) + " : " +
                     message);
}
