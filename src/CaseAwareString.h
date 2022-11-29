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

#ifndef CaseAwareString_h_
#define CaseAwareString_h_

#ifdef SCRIPT_RUBY
#include "ScriptAccess.h"
#endif
#include "cvector.h"
#include <string>
#include <iosfwd>

// A string that know if comparison should be case sensitive or not
// If either part of the comparison is case insensitive, the comparison is done
// case insensitive, otherwise it is compared case sensitive.
class CaseAwareString
#ifdef SCRIPT_RUBY
: public ScriptAccess
#endif
{
public:
  typedef std::string::size_type size_type;
  typedef std::string::reference reference;
  typedef std::string::const_reference const_reference;

  CaseAwareString();
  CaseAwareString(bool caseSensitive, std::string const & s);

  bool caseSensitive() const { return caseSensitive_; }
  void setCaseSensitive(bool how) { caseSensitive_ = how; }

  char const * c_str() const;
  // Original name
  std::string str() const;
  // Lowercase name
  std::string strLower() const;
  // Lowercase if case-insensitive, else original name
  std::string strCase() const;
  CaseAwareString lower() const;

  CaseAwareString const & operator+=(CaseAwareString const & rhs);
  CaseAwareString const & operator+=(char const * rhs);
  CaseAwareString const & operator+=(std::string const & rhs);
  reference operator[](size_type pos);
  const_reference operator[](size_type pos) const;

  CaseAwareString strip() const;
  CaseAwareString allstrip() const;
  CaseAwareString fullstrip() const;
  CaseAwareString removeSpaces() const;
  CaseAwareString removeDoubleSpaces() const;

  CaseAwareString substr(size_type pos=0,
                         size_type count=std::string::npos) const;
  size_type find(char c, size_type pos=0) const;
  size_type find(CaseAwareString const & s, size_type pos=0) const;
  size_type rfind(char c, size_type pos=std::string::npos) const;
  size_type find_first_of(char const * s, size_type pos=0) const;
  size_type find_first_not_of(std::string const & s, size_type pos=0) const;

  void erase(size_type index=0, size_type count=std::string::npos);
  CaseAwareString & replace(size_type pos, size_type count, CaseAwareString
                            const & str);
  unsigned int replace(const std::string & what, const std::string & by,
                       int maxReplace=-1);
  void clear() { s_.clear(); }

  bool empty() const { return s_.empty(); }
  size_type size () const { return s_.size(); }
private:
  friend bool operator==(CaseAwareString const & lhs,
                         CaseAwareString const & rhs);
  friend bool operator==(CaseAwareString const & lhs, char const * rhs);
  friend bool operator!=(CaseAwareString const & lhs,
                         CaseAwareString const & rhs);
  friend bool operator!=(CaseAwareString const & lhs, char const * rhs);
  friend bool operator<(CaseAwareString const & lhs,
                        CaseAwareString const & rhs);
  friend CaseAwareString operator+(CaseAwareString const & lhs,
                                   char const * rhs);
  friend CaseAwareString operator+(char const * lhs,
                                   CaseAwareString const & rhs);
  friend CaseAwareString operator+(CaseAwareString const & lhs,
                                   CaseAwareString const & rhs);
  bool caseSensitive_;
  std::string s_;
};

bool operator==(CaseAwareString const & lhs, CaseAwareString const & rhs);
bool operator==(CaseAwareString const & lhs, char const * rhs);
bool operator!=(CaseAwareString const & lhs, CaseAwareString const & rhs);
bool operator!=(CaseAwareString const & lhs, char const * rhs);
bool operator<(CaseAwareString const & lhs, CaseAwareString const & rhs);

CaseAwareString operator+(CaseAwareString const & lhs, char const * rhs);
CaseAwareString operator+(char const * lhs, CaseAwareString const & rhs);
CaseAwareString operator+(CaseAwareString const & lhs,
                          CaseAwareString const & rhs);

std::ostream & operator<<(std::ostream & str, CaseAwareString const & rhs);

typedef cvector<CaseAwareString> CaseAwareStringList;
CaseAwareString join(CaseAwareString const & separator,
                     CaseAwareStringList const & lines);
CaseAwareString join(std::string const & separator,
                     CaseAwareStringList const & lines);

#endif
