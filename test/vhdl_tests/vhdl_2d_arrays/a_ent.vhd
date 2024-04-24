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

entity a is
  port (
        data1 : in twod_array_type(3 downto 0, 1 downto 0);
        data2 : in array_of_array_type(3 downto 0)(2 downto 0)
       );
end a;
