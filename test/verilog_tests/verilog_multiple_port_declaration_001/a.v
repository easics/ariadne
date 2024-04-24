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


module a
  #(parameter integer g_w2 = 32,
    parameter integer g_w3 = 16,
                      g_w1 = 8)
  (
   clk, d1, d2, b, c, d_,
   d3
  );
   input clk;
   input [g_w1-1:0] d1;
   input [g_w2+1:0] d2;
   input [3:0] b, c,
         d_;
   output [g_w3*2-1:0] d3;

  parameter integer delay = 5;

endmodule

