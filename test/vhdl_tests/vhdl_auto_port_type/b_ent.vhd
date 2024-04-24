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

entity b is
  port (
        clk     : out std_logic;
        reset   : out std_logic;
        pin_0   : out std_logic_vector(3 downto 0);
        pin_1   : in std_logic_vector(4 downto 1)
       );
end b;
