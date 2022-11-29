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

#ifndef ScMethod_h_
#define ScMethod_h_

#include "StringUtil.h"
#include <string>
#include "cvector.h"

struct ScMethod
{
  ScMethod(bool isThread) : isThread(isThread) {}

  bool isThread;
  std::string methodName;
  StringUtil::stringlist sensitivity;
  std::string code;

  std::string declaration() const;
  std::string constructor() const;
  std::string implementation(const std::string & className) const;
};

typedef cvector<ScMethod> ScMethodArray;

#endif
