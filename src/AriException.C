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


#include "AriException.h"
#include "StringUtil.h"
#include "AST.h"
#include "SourceLocManager.h"

AriException::AriException(const std::string & arg)
  : message_(arg)
{
}

AriException::AriException(E_AriExceptionType eType, const std::string & arg)
{
  translate(eType, arg);
}

AriException::AriException(E_AriExceptionType eType, const std::string & arg,
                           SourceLoc loc)
{
  translate(eType, arg);
  SourceLocInfo locInfo = SourceLocManager::instance().resolveSourceLoc(loc);
  message_ = locInfo.str() + message_;
}

AriException::AriException(E_AriExceptionType eType,
                           const std::string & arg1,
                           const std::string & arg2)
{
  translate(eType, arg1, arg2);
}

AriException::AriException(E_AriExceptionType eType,
                           const std::string & arg1,
                           const std::string & arg2,
                           SourceLoc loc)
{
  translate(eType, arg1, arg2);
  SourceLocInfo locInfo = SourceLocManager::instance().resolveSourceLoc(loc);
  message_ = locInfo.str() + message_;
}

AriException::AriException(E_AriExceptionType eType,
                           const std::string & arg1,
                           const std::string & arg2,
                           const std::string & arg3)
{
  translate(eType, arg1, arg2, arg3);
}

AriException::AriException(E_AriExceptionType eType,
                           AST & node)
{
  translate(eType, node);
}

AriException::AriException(E_AriExceptionType eType,
                           AST & node, SourceLoc loc)
{
  translate(eType, node);
  SourceLocInfo locInfo = SourceLocManager::instance().resolveSourceLoc(loc);
  message_ = locInfo.str() + message_;
}

AriException::~AriException()
{
}

std::string AriException::getMessage() const
{
  return message_;
}

void AriException::translate(E_AriExceptionType eType,
                             const std::string & arg)
{
  if (eType == EX_ALREADY_FORCED_PORT)
    message_ = "Multiple port statements for port " + arg;
  else if (eType == EX_ALREADY_FORCED_SIGNAL)
    message_ = "Multiple signal statements for signal " + arg;
  else if (eType == EX_ALREADY_FORCED_TYPE)
    message_ = "Multiple definitions of port/signal " + arg;
  else if (eType == EX_MISSING_TLN_FROM)
    message_ = "Missing from statement for module " + arg;
  else if (eType == EX_UNKNOWN_TYPE)
    message_ = "Unable to determine type for signal " + arg;
  else if (eType == EX_UNABLE_TO_REMOVE)
    message_ = "Unable to remove temporary file I create " + arg;
  else if (eType == EX_UNKNOWN_LANGUAGE)
    message_ = "Unknown language " + arg;
  else if (eType == EX_INTERNAL_ERROR)
    message_ = "Internal error in ariadne in file " + arg;
  else if (eType == EX_RUBY_EXCEPTION)
    message_ = "Ruby exception raised";
  else if (eType == EX_FILE_NOT_FOUND)
    message_ = "Unable to open file " + arg;
  else if (eType == EX_ALREADY_FORCED_GENERIC)
    message_ = "Multiple generic statements for generic " + arg;
  else if (eType == EX_ALREADY_FORCED_CONSTANT)
    message_ = "Multiple constant statements for constant " + arg;
  else if (eType == EX_SPACES_IN_FILENAME)
    message_ = "Spaces or \\n detected in filename.\n" + arg +
      "\nDid you forget a semicolon after the 'from' statement ?";
  else if (eType == EX_MULTIPLE_CONFIGS_NO_INLINE)
    message_ = "When having multiple configurations, I can't put the\n"
      "configuration declaration inside the architecture for \n"
      "entity : " + arg;
  else if (eType == EX_NO_PYTHON_SUPPORT)
    message_ = "This ariadne version has no support for Python scripts\n"
               "in file : " + arg;
  else if (eType == EX_NO_RUBY_SUPPORT)
    message_ = "This ariadne version has no support for Ruby scripts\n"
               "in file : " + arg;
  else
    message_ = "Unknown error occured";
}

void AriException::translate(E_AriExceptionType eType,
                             const std::string & arg1,
                             const std::string & arg2)
{
  if (eType == EX_ALREADY_HAVE_SIGPORT)
    {
      message_ = "Adding signal/port " + arg1 + " to module " + arg2 + " which "
        "already has signal/port of that name";
    }
  else if (eType == EX_ALREADY_HAVE_CONSTGENERIC)
    {
      message_ = "Adding const/generic " + arg1 + " to module " + arg2 +
        " which already has const/generic of that name";
    }
  else if (eType == EX_GENERATED)
    {
      message_ = "In info section for " + arg1 + " :\nSpecifying " + arg2 +
        " for a generated module is not allowed";
    }
  else if (eType == EX_NOT_GENERATED)
    {
      message_ = "In info section for " + arg1 + " :\nSpecifying " + arg2 +
        " for a non-generated module is not allowed";
    }
  else if (eType == EX_ENTITY_NOT_FOUND_IN_FILE)
    {
      message_ = "Entity " + arg1 + " not found in file " + arg2;
    }
  else if (eType == EX_NO_SUCH_INSTANCE)
    {
      message_ = "In module " + arg1 + " : xrf to non-existing submodule " +
        arg2;
    }
  else if (eType == EX_NO_SUCH_PORT)
    {
      message_ = "xrf to non-existing port\n"
        "submodule : " + arg1 + "\n"
        "portname  : " + arg2;
    }
  else if (eType == EX_UNABLE_TO_WRITE)
    {
      message_ = "Unable to write to file " + arg1 + "\n" + arg2 + "\n";
    }
  else if (eType == EX_UNABLE_TO_COMPARE)
    {
      message_ = "Error comparing old file and newly generated file\n"
        "Old file = " + arg1 + "\n"
        "New file = " + arg2 + "\n";
    }
  else if (eType == EX_MORE_PORTS_CHECK)
    {
      message_ = "When checking entity file " + arg1 + "\n" + arg2;
    }
  else if (eType == EX_VERILOG_UNSUPPORTED_TYPE)
    {
      message_ = "Unsupported type for verilog generation :\n"
        "Signal/Port name : " + arg2 + "\n"
        "Type name        : " + arg1;
    }
  else if (eType == EX_AUTO_PORT_DIRECTION)
    {
      message_ = "Unable to determine port direction for " + arg1 + "\n" + arg2;
    }
  else
    {
      message_ = "Unknown error occured";
    }
}

void AriException::translate(E_AriExceptionType eType,
                             const std::string & arg1,
                             const std::string & arg2,
                             const std::string & arg3)
{
  if (eType == EX_MULTIPLE_OUTPUTS)
    {
      message_ = "Cannot connect multiple output signals with same name\n"
        "Module " + arg1 + ", port name = " + arg2 + "\n"
        "Instances that have this port as output :\n" + arg3;
    }
  else if (eType == EX_MULTIPLE_GENERICS)
    {
      message_ = "Cannot connect multiple generics with same name\n"
        "Module " + arg1 + ", generic name = " + arg2 + "\n"
        "Instances that have this generic :\n" + arg3;
    }
  else if (eType == EX_MIX_INOUT)
    {
      message_ = "Cannot connect a mix of inout and (in or out) with the same "
        "name\n"
        "Module " + arg1 + ", port name = " + arg2 + "\n"
        "Instances that have this port as output :\n" + arg3;
    }
  else
    {
      message_ = "Unknown error occured";
    }
}

void AriException::translate(E_AriExceptionType eType,
                             AST & node)
{
  using namespace StringUtil;
  if (eType == EX_UNKNOWN_INFO_NAME)
    {
      message_ = "On line " + number(node.line_number) +
        " in the descriptionfile :\nThis entity name is not used in hierarchy";
    }
  else
    {
      message_ = "Unknown error occured";
    }
}
