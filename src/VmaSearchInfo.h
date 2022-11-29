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

#ifndef VmaSearchInfo_h_
#define VmaSearchInfo_h_

#include "cvector.h"
#include "StringUtil.h"
#include <map>
#include <iosfwd>

class VmaSearchInfo
{
public:
  VmaSearchInfo() {}

  bool runVma();

  // If libraryName is specified, search it. If only 1 match found, return it.
  // If there is only 1 match in all libraries, return it.
  // If there are more matches, return empty string.
  // If nothing is found, return empty string;
  StringUtil::stringpairlist getEntityFile(const std::string & libraryName,
                                          const std::string & entityName) const;

private:
  friend std::ostream & operator<<(std::ostream & str,
                                   const VmaSearchInfo & rhs);
  enum UnitType { ENTITY, ARCHITECTURE, PACKAGE, BODY, CONFIGURATION };
  struct DesignUnit
    {
      UnitType type;
      std::string primary;
      std::string secondary;
      std::string filename;
    };

  struct LibraryInfo
    {
      std::string name;
      std::multimap<std::string, DesignUnit> designUnits;
    };
  typedef std::map<std::string, LibraryInfo> LibraryInfoArray;

  LibraryInfoArray libraries_;
};

std::ostream & operator<<(std::ostream & str, const VmaSearchInfo & rhs);

#endif
