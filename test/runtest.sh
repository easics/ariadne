#! /bin/bash -e

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


usage() {
  echo "runtest version 0.1"
  echo "SYNOPSIS: ./runtest [-h] -e executable"
  echo "          where:"
  echo "             -h  Shows this message."
  echo "             -e  Indicates the path where executable to run is found"
  echo "             -D<define>=<value> Add a define argument"
  echo
  echo "DESCRIPTION: Run a test with the given executable. Afterwards we check"
  echo "             if the output is correct"
  exit 0
}

# A POSIX variable
OPTIND=1 # Reset in case getopts has been used previously in the shell.
EXECUTABLE=ariadne

args=`getopt -o he:D: \
      -n "runtest" -- "$@"`
if [ $? != 0 ]; then   # In case you don't use the -e switch on the first line
  echo "Terminating..." >&2;
  exit 1
fi
# Set the positional parameters ($1, $2, ...) to the rearranged $args
eval set -- "$args"

exe_args=""

while true; do
    case "$1" in
    -h)
        usage
        exit 0
        ;;
    -e) if [ -z "$2" ]; then
          echo "-e flag missing argument"
        else
          export PATH=$2:$PATH
          echo "using ariadne from: $2"
        fi
        shift 2
        ;;
    -D) if [ -z "$2" ]; then
          echo "-D flag missing argument"
        else
          exe_args="-D$2"
        fi
        shift 2
        ;;
    --) shift; break ;;
    *)
        echo "Error: incorrect arguments $1 lalala"
        usage
        exit 1
        ;;
    esac
done

# diff 2 files without looking at the -- tool_version line
makediff() {
  file1=$1
  file2=$2

  diff -B <(grep -v 'tool_version' $file1) <(grep -v 'tool_version' $file2)
}

# Load in environment variable
if [ -f env ]; then
  . ./env
fi

fail=0
$EXECUTABLE $exe_args test.ari || fail=1
if [ -f expectingAriadneError ]; then
  if [ $fail -eq 0 ]; then
    echo "We expected a fail but it did not fail"
    exit 1;
  else
    echo "We expected a fail and it did fail"
    exit 0;
  fi
elif [ $fail -eq 1 ]; then
  echo "We got a fail back from running Ariadne"
  exit 1;
elif [ -f test.h.gold ]; then
  makediff test.h test.h.gold
  makediff test.C test.C.gold

  # If we find the CMA executable, we also check if the SystemC output compiles
  if command -v cma &> /dev/null; then
    ln -sf ../../cma.ini
    cma test
    make -f $(cma -m test)
  fi

elif [ -f test.e.vhdl ]; then
  makediff test.e.vhdl test.e.vhdl.gold
  makediff test_rtl.a.vhdl test_rtl.a.vhdl.gold
elif [ -f test.v ]; then
  makediff test.v test.v.gold
else
  makediff test_ent.vhd test_ent.vhd.gold
  makediff test_rtl.vhd test_rtl.vhd.gold
fi
