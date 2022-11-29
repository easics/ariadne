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


#include "FileHeader.h"
#include "StringUtil.h"
#include "PathFunctions.h"
#include "AriException.h"
#include <iostream>
#include <fstream>

FileHeader::FileHeader(const std::string& fname, SourceLoc loc)
{
  readFile(fname, loc);
}

void FileHeader::readFile(const std::string& fname, SourceLoc loc)
{
  std::string filename = PathFunctions::normpath(StringUtil::expandVars(fname));

  std::ifstream f(filename);
  if (f.good()) {

    f.seekg (0, f.end);
    int length = f.tellg();
    f.seekg (0, f.beg);

    char * buffer = new char [length];

    f.read(buffer,length);
    content_ = std::string(buffer, length);

    delete[] buffer;

    f.close();
  }
  else {
    throw AriException(EX_FILE_NOT_FOUND, filename, loc);
  }
}

// replaces %comment:<n>% by a comment string of length n
void FileHeader::insert_full_line_comment(std::string& s) const
{
  std::string::size_type pos = s.find(" %comment:");
  while (pos != std::string::npos) {
    // search for the closing '%'
    std::string::size_type end = s.find("%", pos+2);
    if (end == std::string::npos)
      return;

    // interprete <n>
    std::string length_str = s.substr(pos+10, end-pos-10);
    unsigned length = std::atoi(length_str.c_str());

    // create a comment string of at least the specified length
    std::string commentstr;
    while (commentstr.size() < length) commentstr.append(comment_);

    // fill it in
    s.replace(pos, end-pos+1, commentstr);
    pos = s.find(" %comment:");
  }
}

std::string FileHeader::stream() const
{
  std::string result = content_;

  //// insert comment
  StringUtil::stringlist lines = StringUtil::split(result, '\n');
  for (auto & line : lines)
    {
      if (line.empty())
        line = comment_;
      else
        line = comment_ + " " + line;
    }
  result = StringUtil::join("\n", lines) + "\n";

  // fill in all variables
  for (auto it = vars_.begin(); it != vars_.end(); ++it) {
    std::string key = std::string("%") + it->first + "%";
    StringUtil::replace(key, it->second, result);
  }

  // replace %comment:<n>% by a comment string of length n
  insert_full_line_comment(result);


  return result;
}

void FileHeader::setComment(const std::string& comment)
{
  comment_ = comment;
}

void FileHeader::setVar(const std::string& key, const std::string& value)
{
  vars_[key] = value;
}
