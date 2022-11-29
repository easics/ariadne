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


#include "SourceLocManager.h"
#include "AST.h"

SourceLocManager * SourceLocManager::instance_ = 0;

SourceLocManager & SourceLocManager::instance()
{
  if (instance_ == 0)
    instance_ = new SourceLocManager;
  return *instance_;
}

SourceLoc SourceLocManager::registerNode(const std::string & filename,
                                         AST * node)
{
  return instance().registerSourceLoc(filename, node->line_number,
                                      node->column_number);
}

SourceLocManager::SourceLocManager()
{
  SourceLocInfo undefined;
  undefined.filename = "undefined";
  undefined.line = 0;
  undefined.column = 0;
  sourceLocs_.push_back(undefined);
}

SourceLocManager::~SourceLocManager()
{
}

SourceLoc SourceLocManager::registerSourceLoc(const std::string & filename,
                                              unsigned int line,
                                              unsigned int column) // static
{
  SourceLocInfo loc;
  loc.filename = filename;
  loc.line = line;
  loc.column = column;
  instance().sourceLocs_.push_back(loc);
  return instance().sourceLocs_.size()-1;
}

SourceLocInfo SourceLocManager::resolveSourceLoc(SourceLoc loc) const
{
  return sourceLocs_[loc];
}
