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


#include "SignalPort.h"
#include "AriException.h"
#include "StringUtil.h"
#include <iostream>

SignalPort::SignalPort(const CaseAwareString & name,
                       const CaseAwareString & type,
                       bool isSignal,
                       const CaseAwareString & direction,
                       int portOrder,
                       SourceLoc loc)
  : XrfBase(name, type, portOrder, loc),
    isSignal_(isSignal),
    direction_(direction),
    forcedPort_(false),
    forcedSignal_(false),
    forcedType_(false),
    relatedPort_(0)
{
}

SignalPort::~SignalPort()
{
}

void SignalPort::forcePort()
{
  if (forcedPort_)
    throw AriException(EX_ALREADY_FORCED_PORT, getName().str());

  if (forcedSignal_)
    throw AriException(EX_ALREADY_FORCED_SIGNAL, getName().str());

  forcedPort_ = true;
  isSignal_ = false;
}

void SignalPort::forceSignal()
{
  if (forcedPort_)
    throw AriException(EX_ALREADY_FORCED_PORT, getName().str());

  if (forcedSignal_)
    throw AriException(EX_ALREADY_FORCED_SIGNAL, getName().str());

  forcedSignal_ = true;
  isSignal_ = true;
}

void SignalPort::forceType(const CaseAwareString & type)
{
  if (forcedType_)
    throw AriException(EX_ALREADY_FORCED_TYPE, getName().str());

  setType(type);
  forcedType_ = type != "@UNKNOWN@";
}

void SignalPort::forceDirection(const CaseAwareString & direction)
{
  direction_ = direction;
}

void SignalPort::setType(const CaseAwareString & type)
{
  if (!forcedType_)
    XrfBase::setType(type);
}

CaseAwareString SignalPort::getDirection() const
{
  return direction_;
}

CaseAwareString SignalPort::getLeftRange() const
{
  // The following are checks for VHDL so we compare them case insensitive
  CaseAwareString type = getType().strip();
  type.setCaseSensitive(false);
  CaseAwareString vhdlType;
  if (type.substr(0, 16) == "std_logic_vector")
    vhdlType = CaseAwareString(type.caseSensitive(), "std_logic_vector");
  else if (type.substr(0, 8) == "unsigned")
    vhdlType = CaseAwareString(type.caseSensitive(), "unsigned");
  else if (type.substr(0, 6) == "signed")
    vhdlType = CaseAwareString(type.caseSensitive(), "signed");
  if (!vhdlType.empty())
    {
      using namespace StringUtil;
      CaseAwareString range = type.substr(vhdlType.size());
      replace("(", "", range, 1);
      rreplace(')', "", range, 1);

      // Find the range token
      std::string::size_type rangePos = std::string::npos;
      std::uint32_t scopeDepth = 0;
      for (std::string::size_type i = 0; i < range.size(); ++i)
        {
          if (range[i] == '(')
            {
              ++scopeDepth;
            }
          if (range[i] == ')')
            {
              --scopeDepth;
            }

          if (scopeDepth == 0)
            {
              if (range.substr(i, 8) == " downto ")
                {
                  rangePos = i;
                  break;
                }
              if (range.substr(i, 4) == " to ")
                {
                  rangePos = i;
                  break;
                }
            }
        }

      if ((rangePos == std::string::npos))
        {
          throw AriException(EX_PORT_HAS_NO_RANGE, type.str(),
                             getName().str());
        }

      CaseAwareString leftRange = range.substr(0, rangePos);
      return leftRange;
    }
  throw AriException(EX_PORT_HAS_NO_RANGE, type.str(), getName().str());
}

CaseAwareString SignalPort::getRightRange() const
{
  // The following are checks for VHDL so we compare them case insensitive
  CaseAwareString type = getType().strip();
  type.setCaseSensitive(false);
  CaseAwareString vhdlType;
  if (type.substr(0, 16) == "std_logic_vector")
    vhdlType = CaseAwareString(type.caseSensitive(), "std_logic_vector");
  else if (type.substr(0, 8) == "unsigned")
    vhdlType = CaseAwareString(type.caseSensitive(), "unsigned");
  else if (type.substr(0, 6) == "signed")
    vhdlType = CaseAwareString(type.caseSensitive(), "signed");
  if (!vhdlType.empty())
    {
      using namespace StringUtil;
      CaseAwareString range = type.substr(vhdlType.size());
      replace("(", "", range, 1);
      rreplace(')', "", range, 1);

      // Find the range token
      std::string::size_type rangePos = std::string::npos;
      bool downtoNotTo = true;
      std::uint32_t scopeDepth = 0;
      for (std::string::size_type i = 0; i < range.size(); ++i)
        {
          if (range[i] == '(')
            {
              ++scopeDepth;
            }
          if (range[i] == ')')
            {
              --scopeDepth;
            }

          if (scopeDepth == 0)
            {
              if (range.substr(i, 8) == " downto ")
                {
                  rangePos = i;
                  break;
                }
              if (range.substr(i, 4) == " to ")
                {
                  rangePos = i;
                  downtoNotTo = false;
                  break;
                }
            }
        }

      if ((rangePos == std::string::npos))
        {
          throw AriException(EX_PORT_HAS_NO_RANGE, type.str(),
                             getName().str());
        }

      CaseAwareString rightRange;
      if (downtoNotTo)
        {
          rightRange = range.substr(rangePos + 8);
        }
      else
        {
          rightRange = range.substr(rangePos + 4);
        }

      return rightRange;
    }
  throw AriException(EX_PORT_HAS_NO_RANGE, type.str(), getName().str());
}

CaseAwareString SignalPort::getWidthMin1() const
{
  CaseAwareString type = getType().strip();
  if (type == "real")
    return CaseAwareString(type.caseSensitive(), "0");

  // The following are checks for VHDL so we compare them case insensitive
  type.setCaseSensitive(false);
  if (type == "std_logic")
    return CaseAwareString(type.caseSensitive(), "0");

  CaseAwareString vhdlType;
  if (type.substr(0, 16) == "std_logic_vector")
    vhdlType = CaseAwareString(type.caseSensitive(), "std_logic_vector");
  else if (type.substr(0, 8) == "unsigned")
    vhdlType = CaseAwareString(type.caseSensitive(), "unsigned");
  else if (type.substr(0, 6) == "signed")
    vhdlType = CaseAwareString(type.caseSensitive(), "signed");
  if (!vhdlType.empty())
    {
      using namespace StringUtil;
      CaseAwareString range = type.substr(vhdlType.size());
      replace("(", "", range, 1);
      rreplace(')', "", range, 1);

      // Find the range token
      std::string::size_type rangePos = std::string::npos;
      bool downtoNotTo = true;
      std::uint32_t scopeDepth = 0;
      for (std::string::size_type i = 0; i < range.size(); ++i)
        {
          if (range[i] == '(')
            {
              ++scopeDepth;
            }
          if (range[i] == ')')
            {
              --scopeDepth;
            }

          if (scopeDepth == 0)
            {
              if (range.substr(i, 8) == " downto ")
                {
                  rangePos = i;
                  break;
                }
              if (range.substr(i, 4) == " to ")
                {
                  rangePos = i;
                  downtoNotTo = false;
                  break;
                }
            }
        }

      if ((rangePos == std::string::npos))
        {
          throw AriException(EX_WIDTH_COULD_NOT_BE_CALCULATED, type.str(),
                             getName().str());
        }

      CaseAwareString highRange = range.substr(0, rangePos);
      CaseAwareString lowRange;
      if (downtoNotTo)
        {
          lowRange = range.substr(rangePos + 8);
        }
      else
        {
          lowRange = range.substr(rangePos + 4);
          std::swap(highRange, lowRange);
        }

      // Some cleanup of the output
      if (lowRange.removeSpaces() == "0")
        {
          return highRange;
        }

      return "(" + highRange + ") - (" + lowRange + ")";
    }
  throw AriException(EX_WIDTH_COULD_NOT_BE_CALCULATED, type.str(), getName().str());
}

bool SignalPort::isPort() const
{
  return !isSignal_;
}

bool SignalPort::isSignalPort() const
{
  return true;
}

void SignalPort::renameType(const CaseAwareString & oldName,
                            const CaseAwareString & newName)
{
  static std::string iskeyword("abcdefghijklmnopqrstuvwxyz0123456789_");
  std::string::size_type pos = 0;
  std::string::size_type oldLen = oldName.size();
  std::string::size_type newLen = newName.size();
  CaseAwareString type = getType();
  while ((pos = type.find(oldName, pos)) != std::string::npos)
    {
      // Only replace whole words
      // Check that character before pos is a non-keyword character
      if (pos > 0)
        {
          if (iskeyword.find(type[pos-1]) != std::string::npos)
            {
              // Not the beginning of a word -> skip it
              pos = pos + oldLen;
              continue;
            }
        }
      // Check that character after pos is a non-keyword character
      if (type.size() > 1 && (pos+oldLen) < type.size())
        {
          if (iskeyword.find(type[pos+oldLen]) != std::string::npos)
            {
              // Not the end of a word -> skip it
              pos = pos + oldLen;
              continue;
            }
        }
      type.replace(pos, oldLen, newName);
      pos = pos + newLen;
    }
  setType(type);
}

void SignalPort::setGroupComment(const CaseAwareString & comment)
{
  groupComment_ = comment;
}

CaseAwareString SignalPort::getGroupComment() const
{
  return groupComment_;
}

void SignalPort::setPortComment(const CaseAwareString & comment)
{
  portComment_ = comment;
}

CaseAwareString SignalPort::getPortComment() const
{
  return portComment_;
}

void SignalPort::setRelatedPort(SignalPort * port)
{
  relatedPort_ = port;
}

SignalPort * SignalPort::getRelatedPort() const
{
  return relatedPort_;
}

bool operator==(const SignalPort & lhs, const SignalPort & rhs)
{
  return (lhs.getName() == rhs.getName()) &&
    (lhs.getType() == rhs.getType()) &&
    (lhs.isPort() == rhs.isPort()) &&
    (lhs.getDirection() == rhs.getDirection());
}
