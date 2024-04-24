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

## All the Verilog tests
add_test(NAME verilog_input_and_output
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/verilog_input_and_output)
set_property(TEST verilog_input_and_output
             PROPERTY LABELS verilog)

add_test(NAME verilog_parameters_000
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/verilog_parameters_000)
set_property(TEST verilog_parameters_000
             PROPERTY LABELS verilog)

add_test(NAME verilog_parameters_001
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/verilog_parameters_001)
set_property(TEST verilog_parameters_001
             PROPERTY LABELS verilog)

add_test(NAME verilog_parameters_002
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/verilog_parameters_002)
set_property(TEST verilog_parameters_002
             PROPERTY LABELS verilog)

add_test(NAME verilog_parameters_003
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/verilog_parameters_003)
set_property(TEST verilog_parameters_003
             PROPERTY LABELS verilog)

add_test(NAME verilog_add_port
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/verilog_add_port)
set_property(TEST verilog_add_port
             PROPERTY LABELS verilog)

add_test(NAME verilog_open_output
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/verilog_open_output)
set_property(TEST verilog_open_output
             PROPERTY LABELS verilog)

add_test(NAME verilog_port_comments
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/verilog_port_comments)
set_property(TEST verilog_port_comments
             PROPERTY LABELS verilog)

add_test(NAME verilog_declarations_and_statements
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/verilog_declarations_and_statements)
set_property(TEST verilog_declarations_and_statements
             PROPERTY LABELS verilog)

add_test(NAME verilog_types
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/verilog_types)
set_property(TEST verilog_types
             PROPERTY LABELS verilog)

add_test(NAME verilog_add_header
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/verilog_add_header)
set_property(TEST verilog_add_header
             PROPERTY LABELS verilog)

add_test(NAME verilog_array_declaration
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/verilog_array_declaration)
set_property(TEST verilog_array_declaration
             PROPERTY LABELS verilog)

add_test(NAME verilog_from_vhdl_000
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/verilog_from_vhdl_000)
set_property(TEST verilog_from_vhdl_000
             PROPERTY LABELS verilog)

add_test(NAME verilog_multiple_port_declaration_000
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/verilog_multiple_port_declaration_000)
set_property(TEST verilog_multiple_port_declaration_000
             PROPERTY LABELS verilog)

add_test(NAME verilog_multiple_port_declaration_001
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/verilog_multiple_port_declaration_001)
set_property(TEST verilog_multiple_port_declaration_001
             PROPERTY LABELS verilog)

add_test(NAME verilog_function_000
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/verilog_function_000)
set_property(TEST verilog_function_000
             PROPERTY LABELS verilog)

add_test(NAME verilog_function_001
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/verilog_function_001)
set_property(TEST verilog_function_001
             PROPERTY LABELS verilog)

add_test(NAME verilog_function_002
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/verilog_function_002)
set_property(TEST verilog_function_002
             PROPERTY LABELS verilog)

add_test(NAME verilog_task_000
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/verilog_task_000)
set_property(TEST verilog_task_000
             PROPERTY LABELS verilog)

add_test(NAME verilog_task_001
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/verilog_task_001)
set_property(TEST verilog_task_001
             PROPERTY LABELS verilog)

add_test(NAME verilog_slice
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/verilog_slice)
set_property(TEST verilog_slice
             PROPERTY LABELS verilog)
