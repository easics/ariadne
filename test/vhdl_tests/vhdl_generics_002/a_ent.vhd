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
  generic (
    g_a : natural range 0 to 4
  );
  port (
    first : in std_logic_vector(g_a - 1 downto 0);
    second : out std_logic_vector(g_a - 1 downto 0)
  );
end a;
