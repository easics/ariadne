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

# Adds a prefix to the vci ports (by default the vc entity name),
# and a group name.
#
# Typical usage: in the ariadne file combining a core and a VC.
# e.g.
#
#  ruby
#     require "vciBusPrefix"
#     vciBusPrefix('vc')
#  end ruby;
#
# This is usefull in combination with the generated vci bus connect.
#
# See $VCI_HOME/contrib/vciBusConnect.rb
def vciBusPrefix(vcInstName, vciPortPrefix="")

  vciPorts = [ 'vcirequest', 'vcireadnotwrite', 'vcidatafrombus',
               'vciaddress', 'vcidatatobus', 'vciacknowledge']

  # add 'vc_select' if present
  $module.getSubInstances.each{|m|
    if m.getInstanceName == vcInstName
      if vciPortPrefix==""
        vciPortPrefix = m.getEntityName + "_"
      end
      m.getPorts.each{|port|
        if port.getName == 'vc_select'
          vciPorts << 'vc_select'
        end
      }
    end
  }

  # rename vciports
  vciPorts.each{|port|
    $module.addRenamePorts(vcInstName, port, vciPortPrefix+port)
    $module.addGroupComment(vciPortPrefix+port, 'VCI bus' )
    }
end
