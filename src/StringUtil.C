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


#include "StringUtil.h"
#include <cstdio>
#include <cstring>
#include <cstdlib>
#include <ctype.h>

namespace StringUtil
{

std::string toLower(const std::string & s)
{
  std::string result(s);
  for (std::string::iterator ch=result.begin(); ch!=result.end(); ++ch)
    {
      if (*ch >= 'A' && *ch <= 'Z')
        *ch = *ch | 0x20;
    }
  return result;
}

std::string number(unsigned int value)
{
  char s[30];
  sprintf(s, "%d", value);
  return s;
}

std::string strip(const std::string & s, const std::string & what)
{
  std::string::size_type i = 0, j = s.size();

  while (i<j && what.find(s[i]) != std::string::npos)
    ++i;
  while (i<j && what.find(s[j-1]) != std::string::npos)
    --j;
  return s.substr(i, j-i);
}

CaseAwareString strip(const CaseAwareString & s, const std::string & what)
{
  CaseAwareString::size_type i = 0, j = s.size();

  while (i<j && what.find(s[i]) != std::string::npos)
    ++i;
  while (i<j && what.find(s[j-1]) != std::string::npos)
    --j;
  return s.substr(i, j-i);
}

std::string allstrip(const std::string & s)
{
  std::string::size_type l=0;
  std::string::size_type r=s.size();

  while (l<r && (s[l]==' ' || s[l]=='\r' || s[l] == '\n' || s[l] == '\t'))
    ++l;
  while (l<r && (s[r-1]==' ' || s[r-1]=='\r' || s[r-1] == '\n'||s[r-1] == '\t'))
    --r;

  return std::string(s, l, r-l);
}

std::string fullstrip(const std::string & s)
{
  std::string result(s);
  std::string::iterator c = result.begin();
  while (c!=result.end())
    {
      if (*c == ' ')
        c = result.erase(c);
      else
        ++c;
    }
  return result;
}

std::string removeDoubleSpaces(const std::string & s)
{
  std::string::size_type pos = 0;
  std::string result;
  char prev = 0;
  bool skip = false; // don't remove doubles inside string
  for (auto c : s)
    {
      if (skip)
        result += c;
      else if (prev != ' ' || c != ' ')
        result += c;
      if (c == '"')
        skip = !skip;
      prev = c;
    }
  return result;
}

std::string expandVars(const std::string & s)
{
  size_t n;
  int offset = 0;
  std::string::size_type dollar_pos;
  static char alpha_numeric[] = "0123456789abcdefghijklmnopqrstuvwxyz"
                                "ABCDEFGHIJKLMNOPQRSTUVWXYZ_";
  std::string env_var_name;
  std::string result(s);
  int braced;

  while ((dollar_pos=result.find('$', offset)) != std::string::npos)
    {
      offset = dollar_pos + 1;
      braced = 0;
      if (result[dollar_pos+1] == '{')
        braced = 1;
      n = strspn(result.c_str()+dollar_pos+1+braced, alpha_numeric);
      if (n==0)
        break;
      if (braced && result[dollar_pos+n+2] != '}')
        break;
      env_var_name = result.substr(dollar_pos+1+braced, n);
      if (!getenv(env_var_name.c_str()))
        break;
      result = result.substr(0, offset-1) + getenv(env_var_name.c_str()) +
        result.substr(dollar_pos+n+1+braced*2, std::string::npos);
      offset--;
    }
  return result;
}

unsigned int replace(const std::string & what,
                     const std::string & by,
                     std::string & in,
                     int maxReplace)
{
  int replacements = 0;
  std::string::size_type token = in.find(what);
  while (token != std::string::npos)
    {
      in.replace(token, what.size(), by);
      token = in.find(what, token + by.size());
      ++replacements;
      if ((maxReplace > -1) && (replacements >= maxReplace))
        break;
    }
  return replacements;
}

unsigned int replace(const std::string & what,
                     const std::string & by,
                     CaseAwareString & in,
                     int maxReplace)
{
  int replacements = 0;
  std::string::size_type token = in.find(CaseAwareString(in.caseSensitive(),
                                                         what));
  while (token != std::string::npos)
    {
      in.replace(token, what.size(), CaseAwareString(in.caseSensitive(), by));
      token = in.find(CaseAwareString(in.caseSensitive(), what),
                                      token + by.size());
      ++replacements;
      if ((maxReplace > -1) && (replacements >= maxReplace))
        break;
    }
  return replacements;
}

unsigned int replace(const std::string & what,
                     const CaseAwareString & by,
                     CaseAwareString & in,
                     int maxReplace)
{
  return replace(what, by.str(), in, maxReplace);
}

unsigned int rreplace(const std::string & what,
                      const std::string & by,
                      std::string & in,
                      int maxReplace)
{
  int replacements = 0;
  std::string::size_type token = in.rfind(what);
  while (token != std::string::npos)
    {
      in.replace(token, what.size(), by);
      token = in.rfind(what, token-1);
      ++replacements;
      if ((maxReplace > -1) && (replacements >= maxReplace))
        break;
    }
  return replacements;
}

unsigned int rreplace(char what,
                      const std::string & by,
                      CaseAwareString & in,
                      int maxReplace)
{
  int replacements = 0;
  std::string::size_type token = in.rfind(what);
  while (token != std::string::npos)
    {
      in.replace(token, 1, CaseAwareString(in.caseSensitive(), by));
      ++replacements;
      if ((maxReplace > -1) && (replacements >= maxReplace))
        break;
      token = in.rfind(what, token-1);
    }
  return replacements;
}

std::string chop(const std::string & s)
{
  return s.substr(0, s.size()-1);
}

std::string chomp(const std::string & s)
{
  std::string::size_type r = s.size();
  while (0<r && (s[r-1] == '\n' || s[r-1] == '\r'))
    r--;
  return s.substr(0, r);
}

stringlist split(const std::string & s, char separator, bool keepEmpty)
{
  stringlist result;
  std::string ss(s);
  std::string firstword;
  std::string::size_type pos;

  while (ss.size() > 0)
    {
      pos = ss.find(separator);
      firstword = ss.substr(0, pos);
      if (pos == std::string::npos)
        ss.clear();
      else
        {
          ss = strip(ss.substr(pos+1), std::string(separator, 1));
        }
      if (keepEmpty || !firstword.empty())
        result.push_back(firstword);
    }
  return result;
}

CaseAwareStringList split(const CaseAwareString & s, char separator)
{
  CaseAwareStringList result;
  CaseAwareString ss(s);
  CaseAwareString firstword;
  std::string::size_type pos;

  while (ss.size() > 0)
    {
      pos = ss.find(separator);
      firstword = ss.substr(0, pos);
      if (pos == std::string::npos)
        ss.clear();
      else
        {
          ss = strip(ss.substr(pos+1), std::string(separator, 1));
        }
      result.push_back(firstword);
    }
  return result;
}

stringlist keywordsplit(const std::string & s, const std::string & keywordchars)
{
  stringlist result;
  std::string ss(s);
  std::string firstword;
  std::string::size_type pos;

  while (ss.size() > 0)
    {
      pos = ss.find_first_not_of(keywordchars);
      firstword = ss.substr(0, pos?pos:1);
      if (pos == std::string::npos)
        ss.clear();
      else
        {
          ss = strip(ss.substr(pos?pos:1));
        }
      result.push_back(firstword);
    }
  return result;
}

CaseAwareStringList keywordsplit(const CaseAwareString & s,
                                 std::string const & keywordchars)
{
  CaseAwareStringList result;
  CaseAwareString ss(s);
  CaseAwareString firstword;
  std::string::size_type pos;

  while (ss.size() > 0)
    {
      pos = ss.find_first_not_of(keywordchars);
      firstword = ss.substr(0, pos?pos:1);
      if (pos == std::string::npos)
        ss.clear();
      else
        {
          ss = strip(ss.substr(pos?pos:1));
        }
      result.push_back(firstword);
    }
  return result;
}

std::string join(const std::string & separator, const stringlist & l)
{
  std::string result;
  stringlist::const_iterator nextItem;
  for (stringlist::const_iterator item=l.begin(); item!=l.end();)
    {
      nextItem = item;
      ++nextItem;
      if (nextItem == l.end())
        result += *item;
      else
        result += *item + separator;
      item = nextItem;
    }
  return result;
}

bool has(const stringlist & l, const std::string & element)
{
  for (stringlist::const_iterator item=l.begin(); item!=l.end(); ++item)
    if (*item == element)
      return true;
  return false;
}

bool startsWith(const std::string & s, const std::string & start)
{
  return s.substr(0, start.size()) == start;
}

bool startsWith(const CaseAwareString & s, const CaseAwareString & start)
{
  return s.substr(0, start.size()) == start;
}

bool endsWith(const std::string & s, const std::string & end)
{
  if (end.size() > s.size())
    return false;
  return s.substr(s.size()-end.size()) == end;
}

bool endsWith(const CaseAwareString & s, const CaseAwareString & end)
{
  if (end.size() > s.size())
    return false;
  return s.substr(s.size()-end.size()) == end;
}

bool contains(const std::string & substring, const std::string & s)
{
  return s.find(substring) != std::string::npos;
}

bool contains(const std::string & substring, const CaseAwareString & s)
{
  return s.find(CaseAwareString(s.caseSensitive(), substring)) !=
    std::string::npos;
}

bool equali(const std::string & lhs, const std::string & rhs)
{
  if (lhs.size() != rhs.size())
    return false;
  std::string::const_iterator left = lhs.begin();
  std::string::const_iterator right = rhs.begin();
  for (; left!=lhs.end(); ++left, ++right)
    {
      if (tolower(*left) != tolower(*right))
        return false;
    }
  return true;
}

}
