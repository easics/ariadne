-- This file is part of ariadne.
--
-- ariadne is free software: you can redistribute it and/or modify it under
-- the terms of the GNU General Public License as published by the Free Software
-- Foundation, either version 3 of the License, or (at your option) any later
-- version.
--
-- ariadne is distributed in the hope that it will be useful, but WITHOUT ANY
-- WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
-- PARTICULAR PURPOSE. See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License along with
-- ariadne. If not, see <https://www.gnu.org/licenses/>.

library ieee;
use ieee.std_logic_1164.all;

entity A is
  port (
    port_from_matching_short_i  : in std_logic;
    port_from_opposite_short_o  : in std_logic;
    port_from_matching_long_in  : in std_logic;
    port_from_opposite_long_out : in std_logic;

    port_to_matching_short : in std_logic;
    port_to_opposite_short : in std_logic;
    port_to_matching_long  : in std_logic;
    port_to_opposite_long  : in std_logic
  );
end A;