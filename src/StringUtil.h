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

#ifndef StringUtil_h_
#define StringUtil_h_

#include "cvector.h"
#include "CaseAwareString.h"
#include <string>
#include <utility>

namespace StringUtil
{
typedef cvector<std::string> stringlist;
typedef cvector<std::pair<std::string,std::string> > stringpairlist;
std::string toLower(const std::string & s);
std::string number(unsigned int value);
std::string strip(const std::string & s, const std::string & what = " ");
CaseAwareString strip(const CaseAwareString & s, const std::string & what = " ");
std::string allstrip(const std::string & s);
std::string fullstrip(const std::string & s);
std::string removeDoubleSpaces(const std::string & s);
std::string expandVars(const std::string & s);
unsigned int replace(const std::string & what,
                     const std::string & by,
                     std::string & in,
                     int maxReplace=-1);
unsigned int replace(const std::string & what,
                     const std::string & by,
                     CaseAwareString & in,
                     int maxReplace=-1);
unsigned int replace(const std::string & what,
                     const CaseAwareString & by,
                     CaseAwareString & in,
                     int maxReplace=-1);
unsigned int rreplace(const std::string & what,
                      const std::string & by,
                      std::string & in,
                      int maxReplace=-1);
unsigned int rreplace(char what,
                      const std::string & by,
                      CaseAwareString & in,
                      int maxReplace=-1);
std::string chop(const std::string & s);
std::string chomp(const std::string & s);
stringlist split(const std::string & s, char separator=' ',
                 bool keepEmpty=true);
CaseAwareStringList split(const CaseAwareString & s, char separator=' ');
stringlist keywordsplit(const std::string & s, const std::string& keywordchars);
CaseAwareStringList keywordsplit(const CaseAwareString & s,
                                 std::string const & keywordchars);
std::string join(const std::string & separator, const stringlist & l);
bool has(const stringlist & l, const std::string & element);
bool startsWith(const std::string & s, const std::string & start);
bool startsWith(const CaseAwareString & s, const CaseAwareString & start);
bool endsWith(const std::string & s, const std::string & end);
bool endsWith(const CaseAwareString & s, const CaseAwareString & end);
bool contains(const std::string & substring, const std::string & s);
bool contains(const std::string & substring, const CaseAwareString & s);
/// Case insensitive compare
bool equali(const std::string & lhs, const std::string & rhs);
};

#endif
