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

#include "NamingRules.h"
#include "EasicsNamingRules.h"
#include "SignalPort.h"

#include <stdlib.h>
#include <iostream>
#include <stdexcept>
#include <cstring>

NamingRules * NamingRules::instance_ = 0;

NamingRules * NamingRules::getInstance()
{
  if (!instance_)
    {
      char * ruleSet = getenv("ARIADNE_NAMING_RULES");
      if (ruleSet)
        {
          if (strcmp(ruleSet, "easics") == 0)
            {
              std::cout << "Using easics naming rules\n";
              instance_ = new EasicsNamingRules();
            }
          else
            throw std::logic_error("unknown naming rules");
        }
      else
        instance_ = new EasicsNamingRules();
    }
  return instance_;
}

NamingRules::NamingRules()
{
}

NamingRules::~NamingRules()
{
}


CaseAwareString NamingRules::getPortBaseName(SignalPort * port)
{
  return getPortBaseName(port->getName(), port->getDirection());
}

