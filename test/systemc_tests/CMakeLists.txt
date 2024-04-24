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

## All the SystemC tests
add_test(NAME systemc_header_parser_000
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/systemc_header_parser_000)
set_property(TEST systemc_header_parser_000
             PROPERTY LABELS systemc)

add_test(NAME systemc_header_parser_001
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/systemc_header_parser_001)
set_property(TEST systemc_header_parser_001
             PROPERTY LABELS systemc)

add_test(NAME systemc_connections
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/systemc_connections)
set_property(TEST systemc_connections
             PROPERTY LABELS systemc)

add_test(NAME systemc_new_port_and_signal
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/systemc_new_port_and_signal)
set_property(TEST systemc_new_port_and_signal
             PROPERTY LABELS systemc)

add_test(NAME systemc_create
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/systemc_create)
set_property(TEST systemc_create
             PROPERTY LABELS systemc)

add_test(NAME systemc_add_and_move_header
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/systemc_add_and_move_header)
set_property(TEST systemc_add_and_move_header
             PROPERTY LABELS systemc)

add_test(NAME systemc_comments
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/systemc_comments)
set_property(TEST systemc_comments
             PROPERTY LABELS systemc)
