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


#include "CaseAwareString.h"
#include "StringUtil.h"
#include <algorithm>

CaseAwareString::CaseAwareString()
  : caseSensitive_(true)
{
}

CaseAwareString::CaseAwareString(bool caseSensitive, std::string const & s)
  : caseSensitive_(caseSensitive), s_(s)
{
}

char const * CaseAwareString::c_str() const
{
  return s_.c_str();
}

std::string CaseAwareString::str() const
{
  return s_;
}

std::string CaseAwareString::strLower() const
{
  return StringUtil::toLower(s_);
}

std::string CaseAwareString::strCase() const
{
  if (caseSensitive_)
    return str();
  else
    return StringUtil::toLower(s_);
}

CaseAwareString CaseAwareString::lower() const
{
  CaseAwareString result;
  result.caseSensitive_ = caseSensitive_;
  result.s_ = strLower();
  return result;
}

CaseAwareString const & CaseAwareString::operator+=(CaseAwareString const & rhs)
{
  s_ += rhs.s_;
  return *this;
}

CaseAwareString const & CaseAwareString::operator+=(char const * rhs)
{
  s_ += rhs;
  return *this;
}

CaseAwareString const & CaseAwareString::operator+=(std::string const & rhs)
{
  s_ += rhs;
  return *this;
}

CaseAwareString::reference CaseAwareString::operator[](size_type pos)
{
  return s_[pos];
}

CaseAwareString::const_reference
CaseAwareString::operator[](size_type pos) const
{
  return s_[pos];
}

CaseAwareString CaseAwareString::strip() const
{
  CaseAwareString result;
  result.caseSensitive_ = caseSensitive_;
  result.s_ = StringUtil::strip(s_);
  return result;
}

CaseAwareString CaseAwareString::allstrip() const
{
  CaseAwareString result;
  result.caseSensitive_ = caseSensitive_;
  result.s_ = StringUtil::allstrip(s_);
  return result;
}

CaseAwareString CaseAwareString::fullstrip() const
{
  CaseAwareString result;
  result.caseSensitive_ = caseSensitive_;
  result.s_ = StringUtil::fullstrip(s_);
  return result;
}

CaseAwareString CaseAwareString::removeSpaces() const
{
  CaseAwareString result;
  result.caseSensitive_ = caseSensitive_;
  result.s_ = StringUtil::fullstrip(s_);
  return result;
}

CaseAwareString CaseAwareString::removeDoubleSpaces() const
{
  CaseAwareString result;
  result.caseSensitive_ = caseSensitive_;
  result.s_ = StringUtil::removeDoubleSpaces(s_);
  return result;
}

CaseAwareString CaseAwareString::substr(size_type pos,
                                        size_type count) const
{
  CaseAwareString result;
  result.caseSensitive_ = caseSensitive_;
  result.s_ = s_.substr(pos, count);
  return result;
}

CaseAwareString::size_type
CaseAwareString::find(char c, size_type pos) const
{
  if (caseSensitive_)
    return s_.find(c, pos);

  auto needle = std::find_if(s_.begin() + pos, s_.end(),
                             [c](char c2){return tolower(c)==tolower(c2);});
  if (needle != s_.end())
    return needle - s_.begin();
  else
    return std::string::npos;
}

CaseAwareString::size_type
CaseAwareString::find(CaseAwareString const & s, size_type pos) const
{
  if (caseSensitive_ && s.caseSensitive_)
    return s_.find(s.s_, pos);

  auto needle = std::search(s_.begin() + pos, s_.end(),
                            s.s_.begin(), s.s_.end(),
                            [](char c1, char c2) -> bool
                            { return tolower(c1) == tolower(c2); });
  if (needle != s_.end())
    return needle - s_.begin();
  else
    return std::string::npos;
}

CaseAwareString::size_type
CaseAwareString::rfind(char c, size_type pos) const
{
  if (caseSensitive_)
    return s_.rfind(c);

  if (pos == std::string::npos)
    pos = s_.size()-1;
  auto needle = std::find_if(s_.rbegin() + (s_.size()-1-pos), s_.rend(),
                             [c](char c2){return tolower(c)==tolower(c2);});
  if (needle != s_.rend())
    return s_.size() - 1 - (needle - s_.rbegin());
  else
    return std::string::npos;
}

CaseAwareString::size_type
CaseAwareString::find_first_of(char const * s, size_type pos) const
{
  if (caseSensitive_)
    return s_.find_first_of(s, pos);

  std::string s1 = s;
  auto needle = std::find_first_of(s_.begin() + pos, s_.end(),
                                   s1.begin(), s1.end(),
                                   [](char c1, char c2) -> bool
                                   { return tolower(c1) == tolower(c2); });
  if (needle != s_.end())
    return needle - s_.begin();
  else
    return std::string::npos;
}

CaseAwareString::size_type
CaseAwareString::find_first_not_of(std::string const & s, size_type pos) const
{
  if (caseSensitive_)
    return s_.find_first_not_of(s, pos);

  std::string::const_iterator needle;
  std::string::size_type index = pos;
  std::string sLower = StringUtil::toLower(s);
  for (needle = s_.begin() + pos; needle!=s_.end(); ++needle, ++index)
    {
      if (sLower.find(tolower(*needle)) == std::string::npos)
        break;
    }
  if (needle != s_.end())
    return index;
  else
    return std::string::npos;
}

void CaseAwareString::erase(size_type index, size_type count)
{
  s_.erase(index, count);
}

CaseAwareString & CaseAwareString::replace(size_type pos,
                                           size_type count,
                                           CaseAwareString const & str)
{
  s_.replace(pos, count, str.s_);
  return *this;
}

unsigned int CaseAwareString::replace(const std::string & what,
                                      const std::string & by,
                                      int maxReplace)
{
  if (caseSensitive_)
    return StringUtil::replace(what, by, s_, maxReplace);

  unsigned int replaceResult = 0;
  std::string sLower = StringUtil::toLower(s_);
  std::string whatLower = StringUtil::toLower(what);
  std::string::size_type token = sLower.find(whatLower);
  while (token != std::string::npos)
    {
      s_.replace(token, what.size(), by);
      token = s_.find(whatLower, token + by.size());
      ++replaceResult;
      if ((maxReplace > -1) && (replaceResult >= maxReplace))
        break;
    }
  return replaceResult;
}

bool operator==(CaseAwareString const & lhs, CaseAwareString const & rhs)
{
  if (lhs.caseSensitive_ && rhs.caseSensitive_)
    return lhs.s_ == rhs.s_;
  else
    return StringUtil::equali(lhs.s_, rhs.s_);
}

bool operator==(CaseAwareString const & lhs, char const * rhs)
{
  if (lhs.caseSensitive_)
    return lhs.s_ == rhs;
  else
    return StringUtil::equali(lhs.s_, rhs);
}

bool operator!=(CaseAwareString const & lhs, CaseAwareString const & rhs)
{
  return !(lhs == rhs);
}

bool operator!=(CaseAwareString const & lhs, char const * rhs)
{
  return !(lhs == rhs);
}

bool operator<(CaseAwareString const & lhs, CaseAwareString const & rhs)
{
  // Always do a lowercase compare.  This operator is used in std::map, and the
  // order shoould NOT depend on wether we search with a case sensitive string
  // or with a case insensitive string.
  return std::lexicographical_compare(lhs.s_.begin(), lhs.s_.end(),
                                      rhs.s_.begin(), rhs.s_.end(),
                                      [](char l, char r) -> bool
                                      {return tolower(l) < tolower(r);});
}

CaseAwareString operator+(CaseAwareString const & lhs, char const * rhs)
{
  CaseAwareString result = lhs;
  result += rhs;
  return result;
}

CaseAwareString operator+(char const * lhs, CaseAwareString const & rhs)
{
  CaseAwareString result;
  result.caseSensitive_ = rhs.caseSensitive_;
  result.s_ = lhs;
  result += rhs;
  return result;
}

CaseAwareString operator+(CaseAwareString const & lhs,
                          CaseAwareString const & rhs)
{
  CaseAwareString result = lhs;
  result += rhs;
  return result;
}

std::ostream & operator<<(std::ostream & str, CaseAwareString const & rhs)
{
  str << rhs.str();
  return str;
}

CaseAwareString join(CaseAwareString const & separator,
                     CaseAwareStringList const & lines)
{
  CaseAwareString result;
  if (!lines.empty())
    result.setCaseSensitive(lines.front().caseSensitive());
  CaseAwareStringList::const_iterator nextItem;
  for (CaseAwareStringList::const_iterator item=lines.begin();
       item!=lines.end();)
    {
      nextItem = item;
      ++nextItem;
      if (nextItem == lines.end())
        result += *item;
      else
        result += *item + separator;
      item = nextItem;
    }
  return result;
}

CaseAwareString join(std::string const & separator,
                     CaseAwareStringList const & lines)
{
  return join(CaseAwareString(true, separator), lines);
}
