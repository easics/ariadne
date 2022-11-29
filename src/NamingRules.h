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

#ifndef NamingRules_h_
#define NamingRules_h_

#include "CaseAwareString.h"

class SignalPort;

class NamingRules
{
public:
  static NamingRules * getInstance();
  NamingRules();
  virtual ~NamingRules();

  virtual CaseAwareString getPortBaseName(const CaseAwareString & name,
                                          const CaseAwareString & direction) = 0;
  virtual CaseAwareString getPortName(const CaseAwareString & baseName,
                                      const CaseAwareString & direction) = 0;
  virtual CaseAwareString getInternalSignalName(const CaseAwareString & baseName) = 0;
  virtual std::string getEntityFileName(const CaseAwareString & entity) = 0;
  virtual std::string getArchitectureFileName(const CaseAwareString & entity,
                                              const CaseAwareString & architecture) = 0;
  virtual CaseAwareString getConfigurationName(const CaseAwareString & entity,
                                               const CaseAwareString & architecture) = 0;
  virtual std::string getConfigurationFileName(const CaseAwareString &
                                               configuration) = 0;

  CaseAwareString getPortBaseName(SignalPort * port);

private:
  static NamingRules * instance_;
};

#endif
