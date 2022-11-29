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


#include "SmartFile.h"
#include "AriException.h"
#include <cstdio>
#include <cstring>
#include <cerrno>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

std::string SmartFile::suffix_ = "_new_version_____";
bool SmartFile::forceOverwrite = false;

SmartFile::SmartFile(const std::string & fileName)
  : fileName_(fileName), closed_(false)
{
  std::string fileToOpen;
  if (forceOverwrite)
    {
      fileToOpen = fileName;
      fileExisted_ = false;
    }
  else if (exists(fileName))
    {
      fileExisted_ = true;
      fileToOpen = fileName + suffix_;
    }
  else
    {
      fileExisted_ = false;
      fileToOpen = fileName;
    }
  output_.open(fileToOpen.c_str());
  if (!output_.good())
    {
      throw AriException(EX_UNABLE_TO_WRITE, fileToOpen, strerror(errno));
    }
}

SmartFile::~SmartFile()
{
  if (!closed_)
    close();
}

void SmartFile::close()
{
  output_.close();
  if (fileExisted_)
    {
      if (changed())
        {
          remove(fileName_.c_str());
          if (rename((fileName_ + suffix_).c_str(), fileName_.c_str()))
            {
              throw AriException(EX_UNABLE_TO_WRITE, fileName_,
                                 strerror(errno));
            }
        }
      else
        {
          if (unlink((fileName_ + suffix_).c_str()))
            {
              throw AriException(EX_UNABLE_TO_REMOVE, strerror(errno));
            }
        }
    }
  else
    {
      // Do nothing since the correct file was used to write
    }
  closed_ = true;
}

bool SmartFile::changed() const
{
  std::ifstream oldFile(fileName_.c_str());
  std::ifstream newFile((fileName_ + suffix_).c_str());
  if (!oldFile.good() || !newFile.good())
    {
      throw AriException(EX_UNABLE_TO_COMPARE, fileName_, fileName_ + suffix_);
    }
  if (size(fileName_) != size(fileName_ + suffix_))
    // Different file sizes
    return true;
  do
    {
      std::string oldLine;
      std::string newLine;
      getline(oldFile, oldLine);
      getline(newFile, newLine);
      if (oldLine != newLine)
        {
          return true;
        }
    }
  while (oldFile.good() && newFile.good());
  // File sizes are the same and all the lines are the same
  // I'm guessing files have exactly the same content
  return false;
}

bool SmartFile::exists(const std::string & filename) const
{
  if (access(filename.c_str(), F_OK))
    // access return 0 if permission is granted, -1 on error
    return false;
  return true;
}

unsigned long long SmartFile::size(const std::string & file) const
{
  struct stat buf;
  if (stat(file.c_str(), &buf))
    // stat return 0 on success
    return (unsigned long long)-1;
  else
    return buf.st_size;
}

SmartFile & SmartFile::operator<<(std::ostream & (*functionPtr)(std::ostream &))
{
  functionPtr(output_);
  return *this;
}
