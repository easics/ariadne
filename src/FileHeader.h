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

#ifndef FileHeader_h_
#define FileHeader_h_

#include "SourceLocManager.h"
#include <string>
#include <map>

class FileHeader
{
public:
  FileHeader(const std::string& fname, SourceLoc loc);
  void readFile(const std::string& fname, SourceLoc loc);
  std::string stream() const;
  void setComment(const std::string& comment);
  void setVar(const std::string& key, const std::string& value);

protected:
  std::string content_;
  std::string comment_;
  std::map<std::string, std::string> vars_;

  void insert_full_line_comment(std::string& s) const;
};







#endif
