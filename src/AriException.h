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

#ifndef AriException_h_
#define AriException_h_

#include "SourceLoc.h"
#include <string>

class AST;

enum E_AriExceptionType
{
  EX_ALREADY_HAVE_SIGPORT,
  EX_ALREADY_HAVE_CONSTGENERIC,
  EX_ENTITY_NOT_FOUND_IN_FILE,
  EX_UNKNOWN_INFO_NAME,
  EX_GENERATED,
  EX_NOT_GENERATED,
  EX_ALREADY_FORCED_PORT,
  EX_ALREADY_FORCED_SIGNAL,
  EX_ALREADY_FORCED_CONSTANT,
  EX_ALREADY_FORCED_GENERIC,
  EX_ALREADY_FORCED_TYPE,
  EX_ALREADY_FORCED_VALUE,
  EX_MULTIPLE_OUTPUTS,
  EX_MIX_INOUT,
  EX_MULTIPLE_GENERICS,
  EX_UNABLE_TO_WRITE,
  EX_MISSING_TLN_FROM,
  EX_NO_SUCH_INSTANCE,
  EX_NO_SUCH_PORT,
  EX_UNABLE_TO_REMOVE,
  EX_UNABLE_TO_COMPARE,
  EX_UNKNOWN_TYPE,
  EX_UNKNOWN_LANGUAGE,
  EX_INTERNAL_ERROR,
  EX_MORE_PORTS_CHECK,
  EX_RUBY_EXCEPTION,
  EX_AUTO_PORT_DIRECTION,
  EX_WIDTH_COULD_NOT_BE_CALCULATED,
  EX_PORT_HAS_NO_RANGE,
  EX_FILE_NOT_FOUND,
  EX_SPACES_IN_FILENAME,
  EX_MULTIPLE_CONFIGS_NO_INLINE,
  EX_NO_PYTHON_SUPPORT,
  EX_NO_RUBY_SUPPORT,
};

class AriException
{
public:
  AriException(const std::string & arg);
  AriException(E_AriExceptionType eType, const std::string & arg);
  AriException(E_AriExceptionType eType, const std::string & arg,SourceLoc loc);
  AriException(E_AriExceptionType eType,
               const std::string & arg1,
               const std::string & arg2);
  AriException(E_AriExceptionType eType,
               const std::string & arg1,
               const std::string & arg2,
               SourceLoc loc);
  AriException(E_AriExceptionType eType,
               const std::string & arg1,
               const std::string & arg2,
               const std::string & arg3);
  AriException(E_AriExceptionType eType, AST & node);
  AriException(E_AriExceptionType eType, AST & node, SourceLoc loc);
  ~AriException();

  std::string getMessage() const;

private:
  void translate(E_AriExceptionType eType, const std::string & arg);
  void translate(E_AriExceptionType eType,
                 const std::string & arg1,
                 const std::string & arg2);
  void translate(E_AriExceptionType eType,
                 const std::string & arg1,
                 const std::string & arg2,
                 const std::string & arg3);
  void translate(E_AriExceptionType eType, AST & node);

  std::string message_;
};

#endif
