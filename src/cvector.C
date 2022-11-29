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


#include "cvector.h"
#include <cstdio>
#include <stdexcept>

template<class Type>
Type & cvector<Type>::operator[](size_type index)
{
  if (index >= this->size())
    {
      char index_str[30];
      char size_str[30];
      sprintf(index_str, "%u", (unsigned int)index);
      sprintf(size_str, "%u", (unsigned int)this->size());
      throw std::runtime_error(std::string("Vector out of bounds\nIndex = ") +
                         index_str + "\nSize = " + size_str);
    }

  return std::vector<Type>::operator[](index);
}

template<class Type>
const Type & cvector<Type>::operator[](size_type index) const
{
  if (index >= this->size())
    {
      char index_str[30];
      char size_str[30];
      sprintf(index_str, "%u", (unsigned int)index);
      sprintf(size_str, "%u", (unsigned int)this->size());
      throw std::runtime_error(std::string("Vector out of bounds\nIndex = ") +
                         index_str + "\nSize = " + size_str);
    }

  return std::vector<Type>::operator[](index);
}
