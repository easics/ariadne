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

# Adds a prefix to the AXI4Lite ports (by default the vc entity name),
# and a group name.
# If the prefix is left empty, the name of the entity is used
#
# Typical usage: in the ariadne file combining a core and a VC.
# e.g.
#
#  ruby
#     require "axi4lBusPrefix"
#     axi4lBusPrefix('vc')
#  end ruby;
#
# See $VCI_HOME/contrib/axiBusConnect.rb
def axi4lBusPrefix(vcInstName, axi4lPortPrefix="")

  axi4lPorts = [
    'araddr',
    'arready',
    'arvalid',
    'awaddr',
    'awready',
    'awvalid',
    'bready',
    'bresp',
    'bvalid',
    'rdata',
    'rready',
    'rresp',
    'rvalid',
    'wdata',
    'wready',
    'wstrb',
    'wvalid'
  ]

  m = $module.getSubInstance(vcInstName)
  if axi4lPortPrefix.empty? then
    axi4lPortPrefix = m.getEntityName + "_"
  end
  # rename vciports
  axi4lPorts.each{|port|
    $module.addRenamePorts(vcInstName, "^" + port + "$", axi4lPortPrefix+port)
    $module.addGroupComment(axi4lPortPrefix+port, 'AXI4 Lite bus' )
  }
end

