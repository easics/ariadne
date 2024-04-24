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
        -- to check that the type of the constrained port is used
        -- (b also has a p_1 with a constrained vector)
        p_1 : in std_logic_vector;
        -- p_2 is defined as port in the ari file.  The type should be taken
        -- from the ari file (which looks unconstrained) and not from here
        p_2 : in std_logic_vector(1 downto 0)
       );
end a;
