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

#ifndef SmartFile_h_
#define SmartFile_h_

#include <fstream>
#include <string>

/**
  A smart file only writes to a file it the content is different than
  an already existing file with the same name.
  If there is no file with the same name, content is always written.
 */
class SmartFile
{
public:
  SmartFile(const std::string & fileName);
  ~SmartFile();

  void close();

  template <class Type> void write(const Type & value);

  SmartFile & operator<<(std::ostream & (*functionPtr)(std::ostream &));

  // Always overwrite generated files, even if they have not changed
  static bool forceOverwrite;

private:
  bool changed() const;
  bool exists(const std::string & filename) const;
  unsigned long long size(const std::string & file) const;

  static std::string suffix_;
  bool fileExisted_;
  std::ofstream output_;
  std::string fileName_;
  bool closed_;
};

template <class Type>
void SmartFile::write(const Type & value)
{
  output_ << value;
}

template <class Type>
SmartFile & operator<<(SmartFile & smartFile, const Type & value)
{
  smartFile.write(value);
  return smartFile;
}

#endif
