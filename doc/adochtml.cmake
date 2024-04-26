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
  DOC "Path to asciidoctor, used to generate the HTML from the Asciidoc"
)

function(add_adoc_html SRC)
  get_filename_component(BASENAME ${SRC} NAME_WE)
  set(DST ${BASENAME}.html)
  string(PREPEND DST "${CMAKE_CURRENT_BINARY_DIR}/")
  add_custom_command(
    OUTPUT ${DST}
    COMMAND ${ASCIIDOCTOR_PATH} ${SRC} -o ${DST}
    DEPENDS ${SRC}
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    COMMENT "Generating HTML documentation ${BASENAME}.html"
    VERBATIM
  )
  add_custom_target("html_${BASENAME}" ALL DEPENDS "${DST}")
endfunction(add_adoc_html)
