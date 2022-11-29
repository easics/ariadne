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

#ifndef cvector_h_
#define cvector_h_

#include <vector>

// Checked vector (bounds checking on indexing)
template <class Type>
class cvector : public std::vector<Type>
{
public:
  typedef typename std::vector<Type>::size_type size_type;

  Type & operator[](size_type index);
  const Type & operator[](size_type index) const;
};

#include "cvector.C"

#endif
