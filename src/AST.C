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


#include "AST.h"
#include <iostream>

AST ast;

void AST::eraseChildren()
{
  for (AST_list::iterator node=nodes_.begin(); node!=nodes_.end(); ++node)
    {
      (*node)->eraseChildren();
      delete *node;
    }
  nodes_.clear();
}

void AST::print(bool extended) const
{
  if (!extended)
    {
      switch (type_)
        {
        case AST_NODE:
          std::cout << "node : " << node_name_ << std::endl;
          break;
        case AST_STRING:
          std::cout << "string : " << string_ << std::endl;
          break;
        case AST_CHAR:
          std::cout << "char : " << char_ << std::endl;
          break;
        case AST_NUMBER:
          std::cout << "number : " << number_ << std::endl;
          break;
        default:
          std::cout << "Something else" << std::endl;
          break;
        }
    }
  else
    {
      std::cout << "type       : " << int(type_) << std::endl;
      std::cout << "node       : " << node_name_ << std::endl;
      std::cout << "string     : " << string_ << std::endl;
      std::cout << "char       : " << char_ << std::endl;
      std::cout << "token type : " << token_type_ << std::endl;
      std::cout << "number     : " << number_ << std::endl;
    }
}

void AST::text(std::string & s) const
{
  s += " ";
  switch (type_)
    {
    case AST_NODE:
      for (unsigned int i=0; i<nodes_.size(); ++i)
        nodes_[i]->text(s);
      break;
    case AST_STRING:
      s += string_;
      break;
    case AST_CHAR:
      s += char_;
      break;
    case AST_NUMBER:
      break;
    default:
      break;
    }
}

std::string AST::text() const
{
  std::string result;
  text(result);
  return result;
}
