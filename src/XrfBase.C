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


#include "XrfBase.h"
#include "AriException.h"
#include "StringUtil.h"

bool XrfBase::generating = false;
using namespace StringUtil;

static unsigned int portCounter_ = 0;

XrfBase::XrfBase(const CaseAwareString & name, const CaseAwareString & type,
                 int portOrder, SourceLoc loc)
  : name_(name), type_(type), nameOrigCase_(name),
    portOrder_(portOrder), loc_(loc)
{
  if (portOrder == -1)
    portOrder_ = portCounter_++;
  else
    portOrder_ = portOrder;
}

XrfBase::~XrfBase()
{
}
const CaseAwareString & XrfBase::getName() const
{
  return name_;
}

const CaseAwareString & XrfBase::getNameOrigCase() const
{
  return nameOrigCase_;
}

CaseAwareString XrfBase::getBasename() const
{
  return name_.substr(0, name_.find_first_of(".("));
}

const CaseAwareString & XrfBase::getType() const
{
  if (generating && type_ == "@UNKNOWN@")
    throw AriException(EX_UNKNOWN_TYPE, name_.str());
  return type_;
}

void XrfBase::setType(const CaseAwareString & type)
{
  type_ = type;
}

void XrfBase::overridePortOrder(unsigned int order)
{
  portOrder_ = order;
}

unsigned int XrfBase::getPortOrder() const
{
  return portOrder_;
}
