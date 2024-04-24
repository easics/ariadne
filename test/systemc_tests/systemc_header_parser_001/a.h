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

#ifndef a_h_
#define a_h_

#include <systemc>

#define abc(a,c) \
  bla bla bla

class a: public sc_core::sc_module
{
public:
  a(sc_core::sc_module_name name);
  ~a();
  SC_HAS_PROCESS(a);

  sc_core::sc_in<bool> clk1;
  sc_core::sc_in<int
    > clk2;
  sc_core::
    sc_out<sc_dt::sc_lv<15-1> >
    data1;
private:
};

#endif
