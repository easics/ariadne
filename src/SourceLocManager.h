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

#ifndef SourceLocManager_h_
#define SourceLocManager_h_

#include "SourceLoc.h"
#include "cvector.h"

class AST;

class SourceLocManager
{
public:
  static SourceLocManager & instance();
  static SourceLoc registerNode(const std::string & filename, AST * node);

  static SourceLoc registerSourceLoc(const std::string & filename,
                                     unsigned int line,
                                     unsigned int column);
  SourceLocInfo resolveSourceLoc(SourceLoc loc) const;

private:
  typedef cvector<SourceLocInfo> SourceLocArray;

  SourceLocManager();
  ~SourceLocManager();

  static SourceLocManager * instance_;

  SourceLocArray sourceLocs_;
};

#endif
