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


# Connects ports between submodule A and submodule B which only differ in a
# prefix: e.g. master_vci_request -- slave_vci_request
# It has some limited type conversion knowledge :
# std_logic,boolean <-> std_logic_vector,unsigned,signed (if vectors are 1 bit)
# std_logic_vector <-> unsigned,signed
# And some limited width conversion knowledge :
# If the width can be deduced from the type string, and widths mismatch,
# truncation or padding with 0 is done.  A warning is emitted on truncation.
#
# arguments:
# * _instA_ : instance name of submodule A
# * _prefixA_ : prefix of submodule the submodule A port (including _)
# * _instB_ : instance name of submodule B
# * _prefixB_ : prefix of submodule the submodule B port (including _)
# * _signalPrefix_ : prefix of the interconnection signals
def prefixXrf(instA, prefixA, instB, prefixB, signalPrefix="")
portsA = Hash.new() # port_name -> port class
portsB = Hash.new()
modA = $module.getSubInstance(instA)
modB = $module.getSubInstance(instB)
numMatchesA = 0
numMatchesB = 0
if modA.nil?
  raise "Module #{instA} not found"
end
if modB.nil?
  raise "Module #{instB} not found"
end
modA.getPorts.each{|port|
  m = port.getName.match("^#{prefixA}(.*)")
  if m != nil and not $module.haveUserXrf(instA, port.getName)
    portsA[m[1]] = port
    numMatchesA += 1
  end
}
modB.getPorts.each{|port|
  m = port.getName.match("^#{prefixB}(.*)")
  if m != nil and not $module.haveUserXrf(instB, port.getName)
    portsB[m[1]] = port
    numMatchesB += 1
  end
}

if numMatchesA == 0 then
  puts "WARNING in prefixXrf: #{prefixA} does not match any ports in #{instA}"
end
if numMatchesB == 0 then
  puts "WARNING in prefixXrf: #{prefixB} does not match any ports in #{instB}"
end
haveConnections = false
sorted_keys = portsA.keys.sort
sorted_keys.each{|port|
  portA = portsA[port]
  typeA = portsA[port].getType.downcase
  if portsB.has_key?(port)
    def isVectorType(type)
      return type[0..15] == 'std_logic_vector' ||
             type[0..7] == 'unsigned' ||
             type[0..5] == 'signed'
    end
    def isBit(type)
      return type == 'std_logic' || type == 'boolean';
    end
    portB = portsB[port]
    typeB = portsB[port].getType.downcase
    indexA = indexB = ''
    if isBit(typeA) && isVectorType(typeB) then
      indexB = '(0)'
    elsif isVectorType(typeA) && isBit(typeB) then
      indexA = '(0)'
    end
    atob = false
    dirA = portsA[port].getDirection
    dirB = portsB[port].getDirection
    if dirA == "out" && dirB == "in" then
      atob = true
    end
    typeconversionAtoB = typeconversionBtoA = ''
    padA = ''
    padB = ''
    widthA = -1
    widthB = -1
    vectorconversion = false
    typeARenamed = $module.renameGenericInType(instA, typeA)
    typeARenamed.match(/\( *(?<high>[0-9 \/+*()-]+) +downto +0 *\)/) do |m|
      widthA = eval(m[:high]) + 1
    end
    typeBRenamed = $module.renameGenericInType(instB, typeB)
    typeBRenamed.match(/\( *(?<high>[0-9 \/+*()-]+) +downto +0 *\)/) do |m|
      widthB = eval(m[:high]) + 1
    end
    widthmismatch = false
    if widthA != -1 && widthB != -1
      if widthA < widthB
        widthmismatch = true
        padA = '"' + '0' * (widthB - widthA) + '" & '
      elsif widthB < widthA
        widthmismatch = true
        padB = '"' + '0' * (widthA - widthB) + '" & '
      end
    end
    if typeA[0..15] == 'std_logic_vector' && typeB[0..7] == 'unsigned' then
      signalA = signalPrefix + port
      signalB = signalPrefix + "unsigned_" + port
      typeconversionAtoB = 'unsigned'
      typeconversionBtoA = 'std_logic_vector'
      vectorconversion = true
    elsif typeA[0..15] == 'std_logic_vector' && typeB[0..5] == 'signed' then
      signalA = signalPrefix + port
      signalB = signalPrefix + "signed_" + port
      typeconversionAtoB = 'signed'
      typeconversionBtoA = 'std_logic_vector'
      vectorconversion = true
    elsif typeB[0..15] == 'std_logic_vector' && typeA[0..7] == 'unsigned' then
      signalA = signalPrefix + "unsigned_" + port
      signalB = signalPrefix + port
      typeconversionAtoB = 'std_logic_vector'
      typeconversionBtoA = 'unsigned'
      vectorconversion = true
    elsif typeB[0..15] == 'std_logic_vector' && typeA[0..5] == 'signed' then
      signalA = signalPrefix + "signed_" + port
      signalB = signalPrefix + port
      typeconversionAtoB = 'std_logic_vector'
      typeconversionBtoA = 'signed'
      vectorconversion = true
    elsif typeA == 'std_logic' && typeB == 'boolean' then
      signalA = signalPrefix + port
      signalB = signalPrefix + "boolean_" + port
      if atob then
        $module.addStatements(signalB + " <= " + signalA + " = '1';\n")
      else
        $module.addStatements(signalA + " <= '1' when " + signalB +
                              " else '0';\n")
      end
    elsif isVectorType(typeA) && typeB == 'boolean' then
      signalA = signalPrefix + "stdlogic_" + port
      signalB = signalPrefix + "boolean_" + port
      $module.addSignal(signalA, 'std_logic')
      if atob then
        $module.addStatements(signalB + " <= " + signalA + " = '1';\n")
      else
        $module.addStatements(signalA + " <= '1' when " + signalB +
                              " else '0';\n")
      end
    elsif typeA == 'boolean' && typeB == 'std_logic' then
      signalA = signalPrefix + "boolean_" + port
      signalB = signalPrefix + port
      if atob then
        $module.addStatements(signalB + " <= '1' when " + signalA +
                              " else '0';\n")
      else
        $module.addStatements(signalA + " <= " + signalB + " = '1';\n")
      end
    elsif isVectorType(typeB) && typeA == 'boolean' then
      signalA = signalPrefix + "boolean_" + port
      signalB = signalPrefix + "stdlogic_" + port
      $module.addSignal(signalB, 'std_logic')
      if atob then
        $module.addStatements(signalB + " <= '1' when " + signalA +
                              " else '0';\n")
      else
        $module.addStatements(signalA + " <= " + signalB + " = '1';\n")
      end
    elsif
      signalA = signalPrefix + port
      signalB = signalPrefix + port
    end
    if vectorconversion then
      if atob then
        if widthB < widthA
          puts "WARNING in prefixXrf: Truncation of #{instA}/#{portA.getName}[#{widthA}] to #{instB}/#{portB.getName}[#{widthB}]"
          $module.addStatements("  " + signalB + " <= " + typeconversionAtoB +
                                "(" + signalA + "(#{widthB-1} downto 0));\n")
        else # padA is empty if widths are equal
          if widthA < widthB
            puts "WARNING in prefixXrf: Padding of #{instA}/#{portA.getName}[#{widthA}] to #{instB}/#{portB.getName}[#{widthB}]"
          end
          $module.addStatements("  " + signalB + " <= " + padA + typeconversionAtoB +
                                "(" + signalA + ");\n")
        end
      else
        if widthA < widthB
          puts "WARNING in prefixXrf: Truncation of #{instB}/#{portB.getName}[#{widthB}] to #{instA}/#{portA.getName}[#{widthA}]"
          $module.addStatements("  " + signalA + " <= " + typeconversionBtoA +
                                "(" + signalB + "(#{widthA-1} downto 0));\n")
        else # padB is empty if widths are equal
          if widthA > widthB
            puts "WARNING in prefixXrf: Padding of #{instB}/#{portB.getName}[#{widthB}] to #{instA}/#{portA.getName}[#{widthA}]"
          end
          $module.addStatements("  " + signalA + " <= " + padB + typeconversionBtoA +
                                "(" + signalB + ");\n")
        end
      end
    elsif widthmismatch
      if atob then
        if widthA < widthB
          puts "WARNING in prefixXrf: Padding of #{instA}/#{portA.getName}[#{widthA}] to #{instB}/#{portB.getName}[#{widthB}]"
          signalB = signalPrefix + "_big" + port
          $module.addStatements("  #{signalB} <= #{padA}(#{signalA});\n")
        else
          puts "WARNING in prefixXrf: Truncation of #{instA}/#{portA.getName}[#{widthA}] to #{instB}/#{portB.getName}[#{widthB}]"
          signalB = signalPrefix + "_small" + port
          $module.addStatements("  #{signalB} <= (#{signalA}(#{widthB-1} downto 0));\n")
        end
      else
        if widthB < widthA
          puts "WARNING in prefixXrf: Padding of #{instB}/#{portB.getName}[#{widthB}] to #{instA}/#{portA.getName}[#{widthA}]"
          signalA = signalPrefix + "_big" + port
          $module.addStatements("  " + signalA + " <= " + padB + "(" + signalB + ");\n")
        else
          puts "WARNING in prefixXrf: Truncation of #{instB}/#{portB.getName}[#{widthB}] to #{instA}/#{portA.getName}[#{widthA}]"
          signalA = signalPrefix + "_small" + port
          $module.addStatements("  #{signalA} <= (#{signalB}(#{widthA-1} downto 0));\n")
        end
      end
    end

    $module.addUserXrf(signalA, instA, prefixA+port+indexA)
    $module.addUserXrf(signalB, instB, prefixB+port+indexB)
    haveConnections = true
  end
}

if not haveConnections then
  puts "WARNING in prefixXrf: No connections made between #{instA} and #{instB}"
end
end
