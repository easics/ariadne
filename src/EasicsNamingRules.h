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

#ifndef EasicsNamingRules_h_
#define EasicsNamingRules_h_

#include "NamingRules.h"

class EasicsNamingRules : public NamingRules
{
public:
  EasicsNamingRules();
  ~EasicsNamingRules();

  CaseAwareString getPortBaseName(const CaseAwareString & name,
                                  const CaseAwareString & direction);
  CaseAwareString getPortName(const CaseAwareString & baseName,
                              const CaseAwareString & direction);
  CaseAwareString getInternalSignalName(const CaseAwareString & baseName);
  std::string getEntityFileName(const CaseAwareString & entity);
  std::string getArchitectureFileName(const CaseAwareString & entity,
                                      const CaseAwareString & architecture);
  CaseAwareString getConfigurationName(const CaseAwareString & entity,
                                       const CaseAwareString & architecture);
  std::string getConfigurationFileName(const CaseAwareString & configuration);

private:
};

#endif
