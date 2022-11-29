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


#include "VmaSearchInfo.h"
#include "VectorAppend.h"
#include <iostream>
#include <cstring>
#include <unistd.h>

bool VmaSearchInfo::runVma()
{
  FILE * vmaOutput = popen("vma -S", "r");
  if (!vmaOutput)
    {
      std::cout << "Fail vma\n";
      return false; // Fail silently, maybe vma is not available
    }
  std::string vmaText;
  char cline[8192];
  size_t nread = 0;
  errno = 0;
  while (true)
    {
      nread = fread(cline, 1, 4096, vmaOutput);
      vmaText += std::string(cline, nread);
      if (ferror(vmaOutput) && errno == EINTR)
        continue;
      if (nread == 0)
        break;
    }
  StringUtil::stringlist lines = StringUtil::split(vmaText, '\n');
  pclose(vmaOutput);
  for (auto line : lines)
    {
      StringUtil::stringlist words = StringUtil::split(line, ' ');
      if (words.size() != 5)
        {
          std::cerr << "Wrong line\n";
          continue;
        }
      DesignUnit unit;
      switch (words[1][0])
        {
        case 'E': unit.type = ENTITY; break;
        case 'A': unit.type = ARCHITECTURE; break;
        case 'P': unit.type = PACKAGE; break;
        case 'B': unit.type = BODY; break;
        case 'C': unit.type = CONFIGURATION; break;
        default: { std::cerr << "default\n"; continue; }
        }
      unit.primary = words[2];
      unit.secondary = words[3];
      unit.filename = words[4];
      libraries_[words[0]].name = words[0];
      libraries_[words[0]].designUnits.insert(std::make_pair(unit.primary,
                                                             unit));
    }
  return true;
}

StringUtil::stringpairlist
VmaSearchInfo::getEntityFile(const std::string & libraryName,
                             const std::string & entityName) const
{
  StringUtil::stringpairlist filenames;
  if (!libraryName.empty())
    {
      auto lib = libraries_.find(libraryName);
      if (lib == libraries_.end())
        return filenames;

      auto range = lib->second.designUnits.equal_range(entityName);
      for (auto unit = range.first; unit!=range.second; ++unit)
        {
          if (unit->second.type == ENTITY)
            {
              filenames << std::make_pair(libraryName, unit->second.filename);
            }
        }
      return filenames;
    }

  for (auto lib : libraries_)
    {
      auto range = lib.second.designUnits.equal_range(entityName);
      for (auto unit = range.first; unit!=range.second; ++unit)
        {
          if (unit->second.type == ENTITY)
            {
              filenames << std::make_pair(lib.first, unit->second.filename);
            }
        }
    }
  return filenames;
}

std::ostream & operator<<(std::ostream & str, const VmaSearchInfo & rhs)
{
  str << rhs.libraries_.size() << " libraries " << getpid() << "\n";
  for (auto lib : rhs.libraries_)
    {
      str << "Library: " << lib.first << ":" << lib.second.name << "\n";
      //for (auto designUnit : lib.second.designUnits)
      //  {
      //    str << "  " << designUnit.second.primary << "\n";
      //    // type
      //    // secondary
      //    // filename
      //  }
    }
  return str;
}
