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


#include "ConstGeneric.h"
#include "AriException.h"

ConstGeneric::ConstGeneric(const CaseAwareString & name,
                           const CaseAwareString & type,
                           bool isConst,
                           const CaseAwareString & defaultValue,
                           SourceLoc loc)
  : XrfBase(name, type, loc), isConst_(isConst), defaultValue_(defaultValue),
    forcedConstant_(false),
    forcedGeneric_(false),
    forcedType_(false),
    forcedValue_(false)
{
}

ConstGeneric::~ConstGeneric()
{
}

void ConstGeneric::forceConstant()
{
  if (forcedConstant_)
    throw AriException(EX_ALREADY_FORCED_CONSTANT, getName().str());
  if (forcedGeneric_)
    throw AriException(EX_ALREADY_FORCED_GENERIC, getName().str());

  forcedConstant_ = true;
  isConst_ = true;
}

void ConstGeneric::forceGeneric()
{
  if (forcedConstant_)
    throw AriException(EX_ALREADY_FORCED_CONSTANT, getName().str());
  if (forcedGeneric_)
    throw AriException(EX_ALREADY_FORCED_GENERIC, getName().str());

  forcedGeneric_ = true;
  isConst_ = false;
}

void ConstGeneric::forceType(const CaseAwareString & type)
{
  if (forcedType_)
    throw AriException(EX_ALREADY_FORCED_TYPE, getName().str());

  forcedType_ = true;
  setType(type);
}

void ConstGeneric::forceValue(const CaseAwareString & value)
{
  if (forcedValue_)
    throw AriException(EX_ALREADY_FORCED_VALUE, getName().str());

  forcedValue_ = true;
  defaultValue_ = value;
}

bool ConstGeneric::isConstant() const
{
  return isConst_;
}

CaseAwareString ConstGeneric::getValue() const
{
  return defaultValue_;
}

bool ConstGeneric::isSignalPort() const
{
  return false;
}
