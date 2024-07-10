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

#ifndef SignalPort_h_
#define SignalPort_h_

#include "XrfBase.h"

class SignalPort : public XrfBase
{
public:
  SignalPort(const CaseAwareString & name,
             const CaseAwareString & type,
             bool isSignal,
             const CaseAwareString & direction,
             int portOrder = -1,
             SourceLoc loc = 0);
  ~SignalPort();

  void forcePort();
  void forceSignal();
  void forceType(const CaseAwareString & type);
  void forceDirection(const CaseAwareString & direction);
  void setType(const CaseAwareString & type);
  CaseAwareString getDirection() const;

  // Only for 'simple' port types
  // Throws an exception for non-simple port types
  CaseAwareString getLeftRange() const;
  CaseAwareString getRightRange() const;
  CaseAwareString getWidthMin1() const;

  bool isPort() const;
  bool isSignalPort() const;
  void renameType(const CaseAwareString & oldName,
                  const CaseAwareString & newName);
  void setGroupComment(const CaseAwareString & comment);
  CaseAwareString getGroupComment() const;
  void setPortComment(const CaseAwareString & comment);
  CaseAwareString getPortComment() const;
  // The port that corresponds to an intermediate signal.
  // Used when auto deducing signal/port type to also set the port type
  // when the signal type is found
  void setRelatedPort(SignalPort * port);
  SignalPort * getRelatedPort() const;

private:
  bool isSignal_;
  CaseAwareString direction_;
  CaseAwareString groupComment_;
  CaseAwareString portComment_;

  bool forcedPort_;
  bool forcedSignal_;
  bool forcedType_;
  SignalPort * relatedPort_;
};

bool operator==(const SignalPort & lhs, const SignalPort & rhs);

#endif
