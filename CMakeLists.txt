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

cmake_minimum_required(VERSION 3.16.1)
project(ariadne LANGUAGES CXX VERSION 1.4.34)

# Auto add version to install dir
string(APPEND CMAKE_INSTALL_PREFIX "/${CMAKE_PROJECT_VERSION}")

# Include CTest for the regression
include(CTest)

# Set the target output directories
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)

## Settings
option(SCRIPT_RUBY "Support Ruby scripts" OFF)
option(SCRIPT_PYTHON "Support Python scripts" OFF)

option(BUILD_TESTS "Build tests" ON)

if (SCRIPT_RUBY)
  add_compile_definitions(SCRIPT_RUBY)

  # Ruby dependencies
  find_package(Ruby REQUIRED)

  if (RUBY_VERSION_MAJOR VERSION_EQUAL "2" AND
      RUBY_VERSION_MINOR VERSION_EQUAL "7")
    message(FATAL_ERROR "Ruby version 2.7.x is not supported")
  endif()
endif()

if (SCRIPT_PYTHON)
  add_compile_definitions(SCRIPT_PYTHON)

  # Python dependencies
  find_package(Python REQUIRED COMPONENTS Interpreter Development)
endif()

if (NOT (SCRIPT_RUBY OR SCRIPT_PYTHON))
  message(FATAL_ERROR "No script support option supplied. Supply either "
                      "SCRIPT_RUBY, SCRIPT_PYTHON or both")
endif()

## Sources
# External libs
add_subdirectory(external/preprocessor)
add_subdirectory(external/rubyexport)

# Main source files
add_subdirectory(src)

# Documentation
add_subdirectory(doc)

# Regression suite
if (BUILD_TESTS)
  add_subdirectory(test)
endif()

file (GLOB RUBY_FILES "ruby/*.rb")
include(GNUInstallDirs)
install(TARGETS ariadne DESTINATION ${CMAKE_INSTALL_BINDIR})
install(FILES ${RUBY_FILES} DESTINATION ${CMAKE_INSTALL_PREFIX}/ruby)
install(FILES Changes TYPE DOC)
