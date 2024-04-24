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


find_program(ASCIIDOCTOR_PATH
  NAMES asciidoctor
  DOC "Path to asciidoctor, used to generate man pages"
)

function(add_adoc_man SRC)
  get_filename_component(BASENAME ${SRC} NAME_WE)
  set(DST ${BASENAME}.1)
  string(PREPEND DST "${CMAKE_CURRENT_BINARY_DIR}/")
  add_custom_command(
    OUTPUT ${DST}
    COMMAND ${ASCIIDOCTOR_PATH} -d manpage ${SRC} -o ${DST}
    DEPENDS ${SRC}
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    COMMENT "Generating man page ${BASENAME}.1"
    VERBATIM
  )
  add_custom_target("man_${BASENAME}" ALL DEPENDS "${DST}")
  install(FILES ${DST} DESTINATION "${CMAKE_INSTALL_PREFIX}/man1")
endfunction(add_adoc_man)
