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

#include "PathFunctions.h"
#include "StringUtil.h"
#include <sys/stat.h>
#include <unistd.h>
#include <stdexcept>
#include <cstring>

std::string PathFunctions::dirname(const std::string & file)
{
  std::string dir, basename, extension;
  split(file, dir, basename, extension);
  return dir;
}

std::string PathFunctions::basename(const std::string & file)
{
  std::string dir, basename, extension;
  split(file, dir, basename, extension);
  std::string result = basename;
  if (extension != "")
    result += "." + extension;
  return result;

}

std::string PathFunctions::extension(const std::string & file)
{
  std::string dir, basename, extension;
  split(file, dir, basename, extension);
  return extension;
}

void PathFunctions::split(const std::string & filename,
                          std::string & dir,
                          std::string & basename,
                          std::string & extension)
{
  dir = basename = extension = "";
  if (isDir(filename))
    // this is a directory -> no filename
    {
      if (filename[filename.size()-1] == '/')
        dir = std::string(filename,0,filename.size()-1);
      else
        dir = filename;
    }
  else
    {
      std::string::size_type slash_position = filename.rfind('/');
      std::string file;
      if (slash_position == std::string::npos)
        {
          file = filename;
        }
      else
        {
          dir = std::string(filename,0,slash_position);
          file = std::string(filename,slash_position+1);
        }
      std::string::size_type dot_position = file.rfind('.');
      if (dot_position == std::string::npos)
        {
          basename = file;
        }
      else
        {
          basename = std::string(file, 0, dot_position);
          if (dot_position + 1 < file.size())
            extension = std::string(file, dot_position+1);
        }
    }
}

bool PathFunctions::isDir(const std::string & file)
{
  struct stat buf;
  if (stat(file.c_str(), &buf))
    // stat return 0 on success
    return false;
  else
    return S_ISDIR(buf.st_mode);
}

/// Return true if the user can read the file
bool PathFunctions::isReadable(const std::string & file)
{
  if (access(file.c_str(), R_OK))
    // access return 0 if permission is granted, -1 on error
    return false;
  else
    return true;
}

std::string PathFunctions::normpath(const std::string & path)
{
  std::string path_ = path;
  std::string leading_slash;

  // Remove all double, triple, quadruple, ... slashes
  while (StringUtil::replace("//", "/", path_));

  // Absolute path check
  if (!path.empty() && path_[0]=='/')
    leading_slash = "/";

  // Remove the trailing slash if it is there
  if (!path_.empty() && path_[path_.size() - 1]=='/')
    path_.erase(path_.size() - 1, 1);

  StringUtil::stringlist comps;
  comps = StringUtil::split(path_, '/');
  unsigned int i = 0;
  while (i<comps.size())
    {
      if (comps[i] == ".")
        {
          comps.erase(comps.begin()+i);
        }
      else if (comps[i]==".." && i>0 && comps[i-1]!="..")
        {
          comps.erase(comps.begin()+i-1, comps.begin()+i+1);
          i--;
        }
      else
        {
          i++;
        }
    }

  if (comps.size() == 0)
    comps.push_back(".");

  return leading_slash + StringUtil::join("/", comps);
}

void PathFunctions::normvars(std::string & path, const std::string & style)
{
  size_t n;
  int offset = 0;
  std::string::size_type dollar_pos;
  char alpha_numeric[] = "0123456789abcdefghijklmnopqrstuvwxyz"
                         "ABCDEFGHIJKLMNOPQRSTUVWXYZ_";
  std::string env_var_name;
  char braced;
  char closingBrace;
  std::string closingStyle;
  if (style == "{")
    closingStyle = "}";
  else if (style == "(")
    closingStyle = ")";
  else if (!style.empty())
    throw std::runtime_error("Unsupported style " + style +
                             " in PathFunctions::normvars");

  while ((dollar_pos=path.find('$', offset)) != std::string::npos)
    {
      offset = dollar_pos + 1;
      braced = 0;
      if (path[dollar_pos+1] == '{')
        {
          braced = '{';
          closingBrace = '}';
        }
      else if (path[dollar_pos+1] == '(')
        {
          braced = '(';
          closingBrace = ')';
        }
      n = strspn(path.c_str()+dollar_pos+1+(braced?1:0), alpha_numeric);
      if (n==0)
        continue;
      if (braced && path[dollar_pos+n+2] != closingBrace) // wrong closing brace
        continue;
      env_var_name = path.substr(dollar_pos+1+(braced?1:0), n);
      path = path.substr(0, offset) + style + env_var_name + closingStyle +
               path.substr(dollar_pos+n+1+(braced?2:0));
    }
}
