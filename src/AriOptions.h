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

#ifndef AriOptions_h_
#define AriOptions_h_

#include "StringUtil.h"
class FileHeader;

class AriOptions
{
public:
  static AriOptions * getInstance();
  ~AriOptions();

  void setWriteEntity(bool);

  bool getWriteEntity();

  FileHeader* getFileHeader() const;

  // overwrite the group comment of the port with a list of modules that are
  // automatically connected to that port
  bool groupCommentIsSource;

  // Don't overwrite entity files, only check if ports change
  bool entitiesCastInStone;

  void setFileHeader(FileHeader* header);

  StringUtil::stringlist includeDirs;
  StringUtil::stringlist defines;

private:
  static AriOptions * instance_;
  AriOptions();

  bool writeEntity_;
  FileHeader* header_;
};

#endif
