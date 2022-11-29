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

#ifndef PathFunction_h_
#define PathFunction_h_

#include <string>

namespace PathFunctions
{
  std::string dirname(const std::string & file);
  std::string basename(const std::string & file);
  std::string extension(const std::string & file);

  void split(const std::string & filename,
             std::string & dir,
             std::string & basename,
             std::string & extension);

  bool isDir(const std::string & file);
  bool isReadable(const std::string & file);
  std::string normpath(const std::string & path);
  void normvars(std::string & path, const std::string & style);

};

#endif
