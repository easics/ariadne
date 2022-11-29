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

#include "AriOptions.h"

AriOptions * AriOptions::instance_ = 0;

AriOptions * AriOptions::getInstance()
{
  if (!instance_)
    instance_ = new AriOptions();
  return instance_;
}

AriOptions::AriOptions()
  : groupCommentIsSource(false),
    entitiesCastInStone(false),
    header_(0)
{
  writeEntity_ = true;
}

AriOptions::~AriOptions()
{
}

void AriOptions::setWriteEntity(bool value)
{
  writeEntity_ = value;
}

bool AriOptions::getWriteEntity()
{
  return writeEntity_;
}

FileHeader* AriOptions::getFileHeader() const
{
  return header_;
}


void AriOptions::setFileHeader(FileHeader* header)
{
  header_ = header;
}
