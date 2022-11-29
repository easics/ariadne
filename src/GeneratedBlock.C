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


#include "GeneratedBlock.h"
#include "PathFunctions.h"
#include "StringUtil.h"
#include "VectorAppend.h"
#include "ExecScript.h"
#include <fstream>
#include <stdexcept>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

GeneratedBlock::GeneratedBlock()
  : isValid_(false)
{
}

bool GeneratedBlock::extract(const std::string & file)
{
  using namespace StringUtil;

  isValid_ = false;
  file_ = file;
  dir_ = PathFunctions::dirname(file);
  std::ifstream input(file.c_str());
  if (!input.good())
    return false;
  std::string line;
  getline(input, line);
  if (!input.good())
    return false;
  line = strip(line, "#/- "); // remove comment tokens
  if (line != "EASICS generated file")
    return false;
  while (true)
    {
      getline(input, line);
      if (!input.good())
        break;
      line = strip(line, "#/- ");
      if (line.empty())
        continue;
      if (startsWith(line, "command : "))
        command_ = line.substr(10);
      else if (startsWith(line, "input : "))
        inputFiles_ << split(line.substr(8), ' ');
      else if (startsWith(line, "env : "))
        envVars_ << line.substr(6);
      else if (startsWith(line, "tool_version : "))
        ;
      else if (startsWith(line, "dir : "))
        dir_ = line.substr(6);
      else
        break;
    }
  if (command_.empty() || inputFiles_.empty())
    return false; // empty filename -> invalid

  stringlist varsToLookFor;
  for (auto file = inputFiles_.begin(); file != inputFiles_.end();)
    {
      if (startsWith(*file, "$(") && endsWith(*file, ")"))
        {
          varsToLookFor << file->substr(2, file->size()-3);
          file = inputFiles_.erase(file);
        }
      else
        ++file;
    }

  if (!varsToLookFor.empty())
    {
      bool addingFiles = false;
      bool continueOnNextLine = false;
      stringlist filesToAdd;
      while (true)
        {
          getline(input, line);
          if (!input.good())
            break;
          line = strip(line);
          bool oldContinueOnNextLine = continueOnNextLine;
          bool oldAddingFiles = addingFiles;
          continueOnNextLine = false;
          if (endsWith(line, "\\"))
            continueOnNextLine = true;
          else
            addingFiles = false;
          line = strip(line, "\\");
          if (oldContinueOnNextLine && !oldAddingFiles)
            continue;
          else if (oldContinueOnNextLine)
            filesToAdd << split(line, ' ');
          else // !oldContinueOnNextLine && !oldAddingFiles
            for (auto var : varsToLookFor)
              {
                if (startsWith(line, var + " ") &&
                    (contains(":=", line) || contains("+=", line) ||
                     contains("=", line)))
                  {
                    std::string::size_type equalPos = line.find('=');
                    filesToAdd << split(line.substr(equalPos+1), ' ');
                    addingFiles = continueOnNextLine;
                  }
              }
        }
      inputFiles_ << filesToAdd;
    }
  filenames_ << PathFunctions::normpath(file);
  for (auto & file : inputFiles_)
    {
      PathFunctions::normvars(file, "{");
    }
  isValid_ = true;
  return true;
}

bool GeneratedBlock::needToRegenerate() const
{
  if (!isValid_)
    throw std::runtime_error("needToRegenerate called when not isValid_");
  struct stat buf;
  if (stat(file_.c_str(), &buf) < 0)
    return true;
  for (auto file : inputFiles_)
    {
      std::string fullpath = StringUtil::expandVars(file);
      if (isOlder(buf.st_mtime, fullpath))
        return true;
    }

  return false;
}

bool GeneratedBlock::regenerateIfNeeded()
{
  if (!isValid_)
    throw std::runtime_error("regenerateIfNeeded called when not isValid_");
  if (!needToRegenerate())
    return false;
  regenerate();
  return true;
}

void GeneratedBlock::regenerate()
{
  isValid_ = false;
  ::exec_script(command_, dir_);
}

bool GeneratedBlock::isOlder(time_t t, const std::string & file) const
{
  struct stat buf;
  if (stat(file.c_str(), &buf) < 0)
    return false;
  return t < buf.st_mtime;
}
