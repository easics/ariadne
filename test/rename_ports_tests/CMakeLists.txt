# This file is part of ariadne.
#
# ariadne is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# ariadne is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# ariadne. If not, see <https://www.gnu.org/licenses/>.

## All the rename ports tests
add_test(NAME rename_ports_without_regex
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/rename_ports_without_regex)
set_property(TEST rename_ports_without_regex
             PROPERTY LABELS rename_ports)

add_test(NAME rename_ports_regex_000
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/rename_ports_regex_000)
set_property(TEST rename_ports_regex_000
             PROPERTY LABELS rename_ports)

add_test(NAME rename_ports_regex_001
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/rename_ports_regex_001)
set_property(TEST rename_ports_regex_001
             PROPERTY LABELS rename_ports)

add_test(NAME rename_ports_matching
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/rename_ports_matching)
set_property(TEST rename_ports_matching
             PROPERTY LABELS rename_ports)

add_test(NAME rename_ports_keep_case
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/rename_ports_keep_case)
set_property(TEST rename_ports_keep_case
             PROPERTY LABELS rename_ports)

add_test(NAME rename_ports_direction
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/rename_ports_direction)
set_property(TEST rename_ports_direction
             PROPERTY LABELS rename_ports)
