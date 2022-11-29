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

# Function to auto update/create .gitignore files
# All you have to do is 'require' this file and .gitignore will be updated
# on every run, if necessary

def updateGitIgnore
  entity = $module.getEntityName
  ignored_entity = 0
  ignored_arch = 0
  ignored_config = 0
  if FileTest.exists?(".gitignore") then
    file = File.open(".gitignore", File::RDONLY)
    begin
      while (line = file.readline)
        line = line.chomp
        if line == ("/" + entity + "_ent.vhd") then
          ignored_entity = 1
        end
        if line == "/" + entity + "_rtl.vhd" then
          ignored_arch = 1
        end
        if line == "/cfg_" + entity + "_*.vhd" then
          ignored_config = 1
        end
      end
    rescue EOFError
      file.close
    end
  end
  if ignored_entity + ignored_arch + ignored_config != 3 then
    file = File.open(".gitignore", File::WRONLY|File::APPEND|File::CREAT)
    if ignored_entity == 0 then
      file.print "/" + entity + "_ent.vhd\n"
    end
    if ignored_arch == 0 then
      file.print "/" + entity + "_rtl.vhd\n"
    end
    if ignored_config == 0 then
      file.print "/cfg_" + entity + "_*.vhd\n"
    end
    file.close
  end
end

updateGitIgnore
