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


# A makefile for a subdirectory that only contains C/C++ programs that can be
# compiled with cma x; make -f cmaMakefile.x

#==================== Modify start ====================#
EXECUTABLES = ariadne
#==================== Modify end ====================#

cmamakefiles = $(addprefix cmaMakefile., $(EXECUTABLES))

all: $(EXECUTABLES)
	-@rm -f .make_cmds

clean:
	@for exe in $(EXECUTABLES); do \
	  if [ -e cmaMakefile.$$exe ]; then \
	    $(MAKE) --no-print-directory -f cmaMakefile.$$exe distclean; \
	  fi; \
	done
	-@rm -fr .make_cmds objects

$(EXECUTABLES): $(cmamakefiles)

cmaMakefile.%: cma.ini
	cma $*

.PHONY: clean $(EXECUTABLES)

-include .make_cmds

.make_cmds:
	@for exe in $(EXECUTABLES); do \
	  echo "$$exe : cmaMakefile.$$exe"; \
	  echo '	@$$(MAKE) --no-print-directory -f $$<'; \
	  echo ""; \
	done > .make_cmds
