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

#ifndef ConstGeneric_h_
#define ConstGeneric_h_

#include "XrfBase.h"

class ConstGeneric : public XrfBase
{
public:
  ConstGeneric(const CaseAwareString & name,
               const CaseAwareString & type,
               bool isConst,
               const CaseAwareString & defaultValue,
               SourceLoc loc=0);
  ~ConstGeneric();

  void forceConstant();
  void forceGeneric();
  void forceType(const CaseAwareString & type);
  void forceValue(const CaseAwareString & value);

  bool isConstant() const;
  CaseAwareString getValue() const;
  bool isSignalPort() const;

private:
  bool isConst_;
  CaseAwareString defaultValue_;

  bool forcedConstant_;
  bool forcedGeneric_;
  bool forcedType_;
  bool forcedValue_;
};

#endif
