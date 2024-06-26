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
        --/ Multiline
        --/ Group
        --/ comment
        clk     : in std_logic;
        --/ Another comment

        reset : in std_logic;
        --/ this line does not belong to any port (because of the empty line
        --/ after it)

        --/ more groups
        --// port comment for pin_1
        pin_1 : in std_logic;
        --// port comment for pin_2
        --// which is spread over multiple lines
        pin_2 : in std_logic;
        --/ group comment overwritten in ari file
        pin_3 : in std_logic

       );
end a;
