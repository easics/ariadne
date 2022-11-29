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

#ifndef VectorAppend_h_
#define VectorAppend_h_

#include "cvector.h"

template<typename T>
cvector<T> & operator<<(cvector<T> & array, const T & newElement)
{
  array.push_back(newElement);
  return array;
}

template<typename T>
cvector<T> & operator<<(cvector<T> & array, const cvector<T> & newElements)
{
  array.insert(array.end(), newElements.begin(), newElements.end());
  return array;
}

#endif
