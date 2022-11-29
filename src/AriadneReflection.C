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


#include "ReflectionRegistry.h"
#include "SignalPort.h"
#include "XrfBase.h"
#include "ModuleInstance.h"
#include "ConstGeneric.h"

void ReflectionWrite(ReflectionHandle handle, CaseAwareString & value,
                     void * data);
ReflectionHandle ReflectionRead(const CaseAwareString & value, void * data);

REFLECT_CLASS_DERIVED(SignalPort, XrfBase)
  .def_c(Reflection::init<CaseAwareString, CaseAwareString, bool,
         CaseAwareString>())
  .DEF_F(forcePort)
  .DEF_F(forceSignal)
  .DEF_F(forceType)
  .DEF_F(forceDirection)
  .DEF_F(setType)
  .DEF_F(getDirection)
  .DEF_F(getWidthMin1)
  .DEF_F(isPort)
  .DEF_F(renameType)
  .DEF_F(setGroupComment)
  .DEF_F(getGroupComment)
  .DEF_F(setPortComment)
  .DEF_F(getPortComment);
}

REFLECT_CLASS(XrfBase)
  .DEF_F(getName)
  .DEF_F(getType)
  .DEF_F(isSignalPort)
  .DEF_F(getPortOrder);
}

REFLECT_CLASS(RubyXrf)
  .DEF_A(signalName)
  .DEF_A(childPortName);
}

REFLECT_CLASS(ModuleInstance)
  .DEF_F(getSubInstances)
  .DEF_F(getSubInstance)
  .DEF_F(getInstanceName)
  .DEF_F(getPorts)
  .DEF_F(getSignals)
  .DEF_F(getEntityName)
  .DEF_F(addPort)
  .DEF_F(addSignal)
  .DEF_F(addConstant)
  .DEF_F(addGeneric)
  .DEF_F(addStatements)
  .DEF_F(addDeclarations)
  .DEF_F(addDeclarationsTop)
  .DEF_F(addUserXrf)
  .DEF_F(removeUserXrf)
  .DEF_F(addUserAssign)
  .DEF_F(addRenamePorts)
  .DEF_F(addGroupComment)
  .DEF_F(addPortComment)
  .DEF_F(addEntityComment)
  .DEF_F(addArchComment)
  .DEF_F(removePackage)
  .DEF_F(movePackage)
  .DEF_F(addPackage)
  .DEF_F(addComponentPackage)
  .DEF_F(getXrfs)
  .DEF_F(getUserXrfs)
  .DEF_F(getUserAssigns)
  .DEF_F(haveUserXrf);
}

REFLECT_CLASS_DERIVED(ConstGeneric, XrfBase)
  .def_c(Reflection::init<CaseAwareString, CaseAwareString, bool,
         CaseAwareString>())
  .DEF_F(forceConstant)
  .DEF_F(forceGeneric)
  .DEF_F(forceType)
  .DEF_F(forceValue)
  .DEF_F(isConstant)
  .DEF_F(getValue);
}

void ReflectionWrite(ReflectionHandle handle, CaseAwareString & value,
                     void * data)
{
  std::string s;
  ReflectionWrite(handle, s, data);
  value = CaseAwareString(true, s);
}

ReflectionHandle ReflectionRead(const CaseAwareString & value, void * data)
{
  return ReflectionRead(value.str(), data);
}
