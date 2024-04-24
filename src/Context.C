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


#include "Context.h"
#include "StringUtil.h"
#include <algorithm>

Context::Context()
{
}

Context::~Context()
{
}

void Context::merge(const Context & context)
{
  for (ContextList::const_iterator library=context.context_.begin();
       library!=context.context_.end(); ++library)
    {
      std::list<PackageInfo> & localLibrary = context_[library->first];
      for (std::list<PackageInfo>::const_iterator
           package=library->second.begin(); package!=library->second.end();
           ++package)
        {
          if (std::find_if(localLibrary.begin(), localLibrary.end(),
                           [package](PackageInfo const & element){
                           return element.packageName == package->packageName;
                           }) ==
              localLibrary.end())
            localLibrary.push_back(*package);
        }
    }
}

void Context::substract(const Context & context)
{
  for (ContextList::const_iterator library=context.context_.begin();
       library!=context.context_.end(); ++library)
    {
      if (context_.find(library->first) == context_.end())
        continue;

      std::list<PackageInfo> & localLibrary = context_[library->first];
      for (std::list<PackageInfo>::const_iterator
           package=library->second.begin(); package!=library->second.end();
           ++package)
        {
          std::list<PackageInfo>::iterator remove;
          remove = std::find_if(localLibrary.begin(), localLibrary.end(),
                                [package](PackageInfo const & element) {
                                return element.packageName ==
                                package->packageName; });
          if (remove != localLibrary.end())
            localLibrary.erase(remove);
        }
    }
}

void Context::clear()
{
  context_.clear();
}

void Context::add(const CaseAwareString & library,
                  const CaseAwareString & theRest,
                  SourceLoc origin)
{
  context_[library].push_back({ theRest.removeSpaces(), origin });
}

std::string Context::getText() const
{
  std::string text;
  for (ContextList::const_iterator library=context_.begin();
       library!=context_.end(); ++library)
    {
      if (!library->second.empty())
        if (library->first.str() != "work")
          text += "library " + library->first.str() + ";\n";
      for (auto package : library->second)
        {
          if (!package.packageName.empty())
            text += "use " + library->first.str() + "." +
              package.packageName.str() +";\n";
        }
      text += "\n";
    }
  return text;
}

std::string Context::getSystemCText() const
{
  std::string text;
  for (ContextList::const_iterator library=context_.begin();
       library!=context_.end(); ++library)
    {
      for (auto package : library->second)
        {
          if (!package.packageName.empty())
            {
              text += "#";
              text += "include " + package.packageName.str() + "\n";
            }
        }
      text += "\n";
    }
  return text;
}

std::string Context::getVerilogText() const
{
  std::string text;
  for (ContextList::const_iterator library=context_.begin();
       library!=context_.end(); ++library)
    {
      for (auto package : library->second)
        {
          if (library->first != "ieee" && !package.packageName.empty())
            {
              text += "`include " + package.packageName.str() + "\n";
            }
        }
      text += "\n";
    }
  return text;
}

Context::ContextList Context::getAllContext() const
{
  return context_;
}
