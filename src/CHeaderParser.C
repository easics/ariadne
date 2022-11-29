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


#include "CHeaderParser.h"
#include "AriException.h"
#include "SignalPort.h"
#include "Module.h"
#include "StringUtil.h"
#include "SourceLocManager.h"
#include <fstream>
#include <cstring>
#include <cerrno>

CHeaderParser::CHeaderParser(Module * module)
  : module_(module)
{
}

CHeaderParser::~CHeaderParser()
{
}

void CHeaderParser::parseFile(const std::string & filename)
{
  std::ifstream header(filename.c_str());
  if (!header.good())
    {
      throw AriException("Unable to open " + filename + " : " +
                         strerror(errno));
    }
  using namespace StringUtil;
  struct Statement
    {
      Statement(unsigned int line, std::string const & str)
        : line(line), str(str) {}
      unsigned int line;
      std::string str;
    };
  typedef std::vector<Statement> StatementArray;
  StatementArray statements;
  unsigned int lineNumber = 0;
  std::string statement;
  bool defineContinuation = false;
  while (true)
    {
      std::string line;
      getline(header, line);
      if (!header.good())
        break;
      ++lineNumber;
      // Remove comments
      std::string::size_type commentPos = line.find("//");
      line = line.substr(0, commentPos);
      line = strip(line);
      if (line.empty())
        {
          defineContinuation = false;
          continue;
        }
      if (defineContinuation)
        {
          if (line[line.size()-1] != '\\')
            defineContinuation = false;
          continue;
        }
      // Remove preprocessor stuff
      if (line[0] == '#')
        {
          if (line.substr(0, 8) == "#include")
            {
              SourceLoc loc = SourceLocManager::registerSourceLoc(filename,
                                                                  lineNumber,
                                                                  1);
              collectedContext_.add(CaseAwareString(true, "systemc"),
                                    CaseAwareString(true,strip(line.substr(8))),
                                    loc);
            }
          if (line.substr(0, 7) == "#define")
            {
              if (line[line.size()-1] == '\\')
                defineContinuation = true;
            }
          continue;
        }
      if (line.size() > 1 &&
          line.substr(line.size()-2) == "*/") // end of multiline comment
        {
          statement.clear();
          continue;
        }

      // 1 line per statement
      statement += line;
      char lastChar = line[line.size()-1];
      if (lastChar == ';' || lastChar == ':' || lastChar == '{' ||
          lastChar == '}')
        {
          Statement fullStatement(lineNumber, statement);
          statements.push_back(fullStatement);
          statement.clear();
        }
    }
  for (auto & statement : statements)
    {
      replace("sc_core::", "", statement.str);
      replace("sc_dt::", "", statement.str);
      if (statement.str.substr(0, 6) == "class " &&
          statement.str[statement.str.size()-1] == '{')
        {
          std::string::size_type nameStart =
            statement.str.find_first_not_of(' ', 5);
          std::string::size_type nameEnd =
            statement.str.find_first_of(" :", nameStart);
          std::string className =
            statement.str.substr(nameStart, nameEnd - nameStart);
          module_->setEntityName(CaseAwareString(true, className));
          module_->parsedIt();
          module_->setContext(collectedContext_);
        }
      else if (statement.str.substr(0, 6) == "sc_in<")
        {
          std::string::size_type typeEnd = statement.str.rfind('>');
          std::string type = strip(statement.str.substr(6, typeEnd - 6));
          std::string name = chop(strip(statement.str.substr(typeEnd+1)));
          SignalPort * sigPort =
            new SignalPort(CaseAwareString(true, name),
                           CaseAwareString(true, type), false,
                           CaseAwareString(true, "in"), -1,
                           SourceLocManager::registerSourceLoc(filename,
                                                               statement.line,
                                                               1));
          module_->addSignalPort(sigPort);
        }
      else if (statement.str.substr(0, 7) == "sc_out<")
        {
          std::string::size_type typeEnd = statement.str.rfind('>');
          std::string type = strip(statement.str.substr(7, typeEnd - 7));
          std::string name = chop(strip(statement.str.substr(typeEnd+1)));
          SignalPort * sigPort =
            new SignalPort(CaseAwareString(true, name),
                           CaseAwareString(true, type),
                           false,
                           CaseAwareString(true, "out"), -1,
                           SourceLocManager::registerSourceLoc(filename,
                                                               statement.line,
                                                               1));
          module_->addSignalPort(sigPort);
        }
      else if (statement.str.substr(0, 8) == "sc_port<")
        {
          std::string::size_type typeEnd = statement.str.rfind('>');
          std::string type = strip(statement.str.substr(8, typeEnd - 8));
          std::string name = chop(strip(statement.str.substr(typeEnd+1)));
          if (contains("tlm_fifo_get_if", type))
            {
              SignalPort * sigPort =
                new SignalPort(CaseAwareString(true, name),
                               CaseAwareString(true, type),
                               false,
                               CaseAwareString(true, "in"), -1,
                               SourceLocManager::registerSourceLoc(filename,
                                                                   statement.line,
                                                                   1));
              module_->addSignalPort(sigPort);
            }
          else if (contains("tlm_fifo_put_if", type))
            {
              SignalPort * sigPort =
                new SignalPort(CaseAwareString(true, name),
                               CaseAwareString(true, type),
                               false,
                               CaseAwareString(true, "out"), -1,
                               SourceLocManager::registerSourceLoc(filename,
                                                                   statement.line,
                                                                   1));
              module_->addSignalPort(sigPort);
            }
        }
    }
}

