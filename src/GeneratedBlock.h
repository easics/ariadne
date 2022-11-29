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

#ifndef GeneratedBlock_h_
#define GeneratedBlock_h_

#include "StringUtil.h"

class GeneratedBlock
{
public:
  GeneratedBlock();

  // return true on success
  bool extract(const std::string & file);
  bool needToRegenerate() const;
  // return true if regenerated
  bool regenerateIfNeeded();
  void regenerate();

  std::string getCommand() const { return command_; }

private:
  // Check if time t is older than the modification time of file2
  bool isOlder(time_t t, const std::string & file) const;

  bool isValid_;
  std::string file_;

  StringUtil::stringlist filenames_;
  std::string command_;
  StringUtil::stringlist inputFiles_;
  StringUtil::stringlist envVars_;
  std::string dir_;
};

#endif
