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

#ifndef ariFileParser_h_
#define ariFileParser_h_

#include "cvector.h"
#include <string>
#include <set>

class ariFileParser
{
public:
  ariFileParser();
  ~ariFileParser();

  void parseFile(const char * filename);
  void parseString(const std::string & s);

  void parseLineMarker(const char * text,unsigned int line,unsigned int column);
  void setErrorMessage(const std::string & message);

  std::set<std::string> getIncludedFiles() const { return includedFiles_; }

private:
  struct IncludeInfo
    {
      std::string filename;
      unsigned int line;
    };
  typedef cvector<IncludeInfo> IncludeInfoArray;

  void pushInclude(const std::string & fromFilename, unsigned int line,
                   const std::string & toFilename);
  void popInclude();
  std::string makeErrorLocation();

  IncludeInfoArray includeStack_;

  std::string errorMessage_;

  std::set<std::string> includedFiles_;
};

extern std::string ariFilefilename;

#endif
