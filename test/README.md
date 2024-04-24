<!--- This file is part of ariadne. -->
<!---  -->
<!--- ariadne is free software: you can redistribute it and/or modify it under -->
<!--- the terms of the GNU General Public License as published by the Free Software -->
<!--- Foundation, either version 3 of the License, or (at your option) any later -->
<!--- version. -->
<!---  -->
<!--- ariadne is distributed in the hope that it will be useful, but WITHOUT ANY -->
<!--- WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A -->
<!--- PARTICULAR PURPOSE. See the GNU General Public License for more details. -->
<!---  -->
<!--- You should have received a copy of the GNU General Public License along with -->
<!--- ariadne. If not, see <https://www.gnu.org/licenses/>. -->

# Regression

We have a regression to test the functionality of Ariadne

The tests are divided in the following categories:

* VHDL
* Verilog
* Rename ports
* SystemC
* Ruby scripting
* Miscellaneous

The regression works with CTest as described [here](../README.md#tests-and-regressions)

## Writing tests

The procedure for adding tests is as follows:

* Create your test in the appropriate category
* Add a testdoc.adoc documentation file for the test
* Add the test to the appropriate CMakeList.txt of that category. Make sure to
  add the correct properties to that tests
