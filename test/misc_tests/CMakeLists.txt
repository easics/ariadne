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

## All the miscellaneous tests
add_test(NAME misc_keep_case
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/misc_keep_case)
set_property(TEST misc_keep_case
             PROPERTY LABELS misc)

add_test(NAME misc_include
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/misc_include)
set_property(TEST misc_include
             PROPERTY LABELS misc)

add_test(NAME misc_file_headers
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/misc_file_headers)
set_property(TEST misc_file_headers
             PROPERTY LABELS misc)

add_test(NAME misc_naming_rules
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/misc_naming_rules)
set_property(TEST misc_naming_rules
             PROPERTY LABELS misc)

add_test(NAME misc_define
         COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/../runtest.sh -e ${CMAKE_RUNTIME_OUTPUT_DIRECTORY} -DBLA=2
         WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/misc_define)
set_property(TEST misc_include
             PROPERTY LABELS misc)

