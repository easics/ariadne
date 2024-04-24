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

module a (
          input clk,
          input reset_n,
          input [1:0] d1, d2,
          output reg [2:0] q1, q2, q3
         );

function integer blabla (input clock);
  input integer start_not_end;
  input [17:0] base;
  input [7:0] test ;

  reg signed [18:0] t;

  reg lsb;

  begin
    blabla <= base;
    assignm <= 0;
    assigni <= 1;
  end
endfunction

endmodule
