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


#include "ScMethod.h"

std::string ScMethod::declaration() const
{
  return "    void " + methodName + "();";
}

std::string ScMethod::constructor() const
{
  std::string result;
  result = "    ";
  if (isThread)
    result += "SC_THREAD(" + methodName + ");\n";
  else
    result += "SC_METHOD(" + methodName + ");\n";
  if (!sensitivity.empty())
    result += "    sensitive << " + StringUtil::join(" << ", sensitivity) +
      ";\n";
  return result;
}

std::string ScMethod::implementation(const std::string & className) const
{
  return "void " + className + "::" + methodName + "()\n{\n" + code + "}\n";
}
