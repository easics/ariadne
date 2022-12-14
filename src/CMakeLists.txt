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

## Target libraries
add_executable(ariadne)

## Include direcories
target_include_directories(ariadne
  PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}
)

if (SCRIPT_RUBY)
  target_include_directories(ariadne
    PRIVATE
      ${RUBY_INCLUDE_DIRS}
  )
endif()

if (SCRIPT_PYTHON)
  target_include_directories(ariadne
    PRIVATE
      ${Python_INCLUDE_DIRS}
  )
endif()

## Linking dependencies
target_link_libraries(ariadne PreProcess)

if (SCRIPT_RUBY)
  target_link_libraries(ariadne rubyexport ${RUBY_LIBRARY} ${CMAKE_DL_LIBS})
endif()

if (SCRIPT_PYTHON)
  target_link_libraries(ariadne rubyexport ${Python_LIBRARY} ${CMAKE_DL_LIBS})
endif()

## Package dependencies for parsers
find_package(BISON)
find_package(FLEX)

BISON_TARGET(vhdlParser
             ${CMAKE_CURRENT_SOURCE_DIR}/vhdl.y
             ${CMAKE_CURRENT_BINARY_DIR}/vhdl.tab.cpp
             COMPILE_FLAGS "-d -p vhdl")
FLEX_TARGET(vhdlScanner
            ${CMAKE_CURRENT_SOURCE_DIR}/vhdl.l
            ${CMAKE_CURRENT_BINARY_DIR}/vhdl.lex.cpp
            COMPILE_FLAGS "-P vhdl")
ADD_FLEX_BISON_DEPENDENCY(vhdlScanner vhdlParser)

BISON_TARGET(ariFileParser
             ${CMAKE_CURRENT_SOURCE_DIR}/ariFile.y
             ${CMAKE_CURRENT_BINARY_DIR}/ariFile.tab.cpp
             COMPILE_FLAGS "-d -p ariFile")
FLEX_TARGET(ariFileScanner
            ${CMAKE_CURRENT_SOURCE_DIR}/ariFile.l
            ${CMAKE_CURRENT_BINARY_DIR}/ariFile.lex.cpp
            COMPILE_FLAGS "-P ariFile")
ADD_FLEX_BISON_DEPENDENCY(ariFileScanner ariFileParser)

BISON_TARGET(verilogParser
             ${CMAKE_CURRENT_SOURCE_DIR}/verilog.y
             ${CMAKE_CURRENT_BINARY_DIR}/verilog.tab.cpp
             COMPILE_FLAGS "-d -p verilog")
FLEX_TARGET(verilogScanner
            ${CMAKE_CURRENT_SOURCE_DIR}/verilog.l
            ${CMAKE_CURRENT_BINARY_DIR}/verilog.lex.cpp
            COMPILE_FLAGS "-P verilog")
ADD_FLEX_BISON_DEPENDENCY(verilogScanner verilogParser)

target_link_libraries(ariadne ${FLEX_LIBRARIES})

## File list
target_sources(ariadne
  PRIVATE
    ariadne.C
    AriadneReflection.C
    AriElaborate.C
    AriException.C
    ariFileParser.C
    AriOptions.C
    Assign.C
    AST.C
    ASTTraversalariFile.C
    ASTTraversalverilog.C
    ASTTraversalvhdl.C
    CaseAwareString.C
    CHeaderParser.C
    ConstGeneric.C
    Context.C
    EasicsNamingRules.C
    ExecScript.C
    FileHeader.C
    GeneratedBlock.C
    lex.yy.c
    Module.C
    ModuleInstance.C
    NamingRules.C
    PathFunctions.C
    ScMethod.C
    SignalPort.C
    SmartFile.C
    SourceLoc.C
    SourceLocManager.C
    StringUtil.C
    verilogParser.C
    VerilogParserWrapper.C
    vhdlParser.C
    VhdlParserWrapper.C
    VmaSearchInfo.C
    wrap_memcpy.c
    XrfBase.C
    Xrf.C
    ${BISON_vhdlParser_OUTPUTS}
    ${FLEX_vhdlScanner_OUTPUTS}
    ${BISON_ariFileParser_OUTPUTS}
    ${FLEX_ariFileScanner_OUTPUTS}
    ${BISON_verilogParser_OUTPUTS}
    ${FLEX_verilogScanner_OUTPUTS}
)
