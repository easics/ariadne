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

## All the VHDL tests
add_test(NAME vhdl_port_and_group_comments
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/vhdl_port_and_group_comments)
set_property(TEST vhdl_port_and_group_comments
             PROPERTY LABELS vhdl)

add_test(NAME vhdl_entity_and_architecture_comments
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/vhdl_entity_and_architecture_comments)
set_property(TEST vhdl_entity_and_architecture_comments
             PROPERTY LABELS vhdl)

add_test(NAME vhdl_generics_000
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/vhdl_generics_000)
set_property(TEST vhdl_generics_000
             PROPERTY LABELS vhdl)

add_test(NAME vhdl_generics_001
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/vhdl_generics_001)
set_property(TEST vhdl_generics_001
             PROPERTY LABELS vhdl)

add_test(NAME vhdl_generics_002
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/vhdl_generics_002)
set_property(TEST vhdl_generics_002
             PROPERTY LABELS vhdl)

add_test(NAME vhdl_generics_003
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/vhdl_generics_003)
set_property(TEST vhdl_generics_003
             PROPERTY LABELS vhdl)

add_test(NAME vhdl_generics_004
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/vhdl_generics_004)
set_property(TEST vhdl_generics_004
             PROPERTY LABELS vhdl)

add_test(NAME vhdl_generics_005
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/vhdl_generics_005)
set_property(TEST vhdl_generics_005
             PROPERTY LABELS vhdl)

add_test(NAME vhdl_generics_006
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/vhdl_generics_006)
set_property(TEST vhdl_generics_006
             PROPERTY LABELS vhdl)

add_test(NAME vhdl_generics_007
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/vhdl_generics_007)
set_property(TEST vhdl_generics_007
             PROPERTY LABELS vhdl)

add_test(NAME vhdl_unconstrained_port_type_000
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/vhdl_unconstrained_port_type_000)
set_property(TEST vhdl_unconstrained_port_type_000
             PROPERTY LABELS vhdl)

add_test(NAME vhdl_unconstrained_port_type_001
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/vhdl_unconstrained_port_type_001)
set_property(TEST vhdl_unconstrained_port_type_001
             PROPERTY LABELS vhdl)

add_test(NAME vhdl_unconstrained_port_type_002
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/vhdl_unconstrained_port_type_002)
set_property(TEST vhdl_unconstrained_port_type_002
             PROPERTY LABELS vhdl)

add_test(NAME vhdl_port_type_resolution
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/vhdl_port_type_resolution)
set_property(TEST vhdl_port_type_resolution
             PROPERTY LABELS vhdl)

add_test(NAME vhdl_move_package
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/vhdl_move_package)
set_property(TEST vhdl_move_package
             PROPERTY LABELS vhdl)

add_test(NAME vhdl_port_directions
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/vhdl_port_directions)
set_property(TEST vhdl_port_directions
             PROPERTY LABELS vhdl)

add_test(NAME vhdl_xrfp
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/vhdl_xrfp)
set_property(TEST vhdl_xrfp
             PROPERTY LABELS vhdl)

add_test(NAME vhdl_auto_port_type
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/vhdl_auto_port_type)
set_property(TEST vhdl_auto_port_type
             PROPERTY LABELS vhdl)

add_test(NAME vhdl_auto_signal_type
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/vhdl_auto_signal_type)
set_property(TEST vhdl_auto_signal_type
             PROPERTY LABELS vhdl)

add_test(NAME vhdl_constants_000
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/vhdl_constants_000)
set_property(TEST vhdl_constants_000
             PROPERTY LABELS vhdl)

add_test(NAME vhdl_constants_001
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/vhdl_constants_001)
set_property(TEST vhdl_constants_001
             PROPERTY LABELS vhdl)

add_test(NAME vhdl_xrf_000
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/vhdl_xrf_000)
set_property(TEST vhdl_xrf_000
             PROPERTY LABELS vhdl)

add_test(NAME vhdl_exponentiation
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/vhdl_exponentiation)
set_property(TEST vhdl_exponentiation
             PROPERTY LABELS vhdl)

add_test(NAME vhdl_2d_arrays
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/vhdl_2d_arrays)
set_property(TEST vhdl_2d_arrays
             PROPERTY LABELS vhdl)

add_test(NAME vhdl_port_propagation
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/vhdl_port_propagation)
set_property(TEST vhdl_port_propagation
             PROPERTY LABELS vhdl)

add_test(NAME vhdl_port_range_propagation
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/vhdl_port_range_propagation)
set_property(TEST vhdl_port_range_propagation
             PROPERTY LABELS vhdl)

add_test(NAME vhdl_spi
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/vhdl_spi)
set_property(TEST vhdl_spi
             PROPERTY LABELS vhdl)

add_test(NAME vhdl_casing
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/vhdl_casing)
set_property(TEST vhdl_casing
             PROPERTY LABELS vhdl)

add_test(NAME vhdl_to_range
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/vhdl_to_range)
set_property(TEST vhdl_to_range
             PROPERTY LABELS vhdl)
