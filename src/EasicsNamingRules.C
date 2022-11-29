// This file is part of ariadne.
//
// ariadne is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// ariadne is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with
// ariadne. If not, see <https://www.gnu.org/licenses/>.

#include "EasicsNamingRules.h"

EasicsNamingRules::EasicsNamingRules()
{
}

EasicsNamingRules::~EasicsNamingRules()
{
}

CaseAwareString
EasicsNamingRules::getPortBaseName(const CaseAwareString & name,
                                   const CaseAwareString & direction)
{
  return name;
}

CaseAwareString EasicsNamingRules::getPortName(const CaseAwareString & baseName,
                                              const CaseAwareString & direction)
{
  return baseName;
}

CaseAwareString EasicsNamingRules::
getInternalSignalName(const CaseAwareString & baseName)
{
  return baseName;
}

std::string EasicsNamingRules::getEntityFileName(const CaseAwareString & entity)
{
  return entity.strCase() + "_ent.vhd";
}

std::string EasicsNamingRules::
getArchitectureFileName(const CaseAwareString & entity,
                        const CaseAwareString & architecture)
{
  return entity.strCase() + "_" + architecture.strCase() + ".vhd";
}

CaseAwareString EasicsNamingRules::
getConfigurationName(const CaseAwareString & entity,
                     const CaseAwareString & architecture)
{
  return CaseAwareString(entity.caseSensitive(), "cfg_") + entity + "_" +
    architecture;
}

std::string EasicsNamingRules::
getConfigurationFileName(const CaseAwareString & configuration)
{
  return configuration.strCase() + ".vhd";
}
