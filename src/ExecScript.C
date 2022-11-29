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


#include "ExecScript.h"
#include "StringUtil.h"
#include "PathFunctions.h"
#include <iostream>
#include <sys/types.h>
#ifndef WIN32
#include <sys/wait.h>
#endif
#include <unistd.h>
#include <cstdlib>
#include <cstring>

using namespace StringUtil;
using namespace PathFunctions;

void exec_script(const std::string & script, const std::string & dir)
{
  std::string command = script;
  replace("\n", " ", command);
  replace("\r", " ", command);
  command = expandVars(command);
  std::cout << "Running " << command << "\n";
#ifndef WIN32
  int pid = fork();
  if (pid == 0)
    {
      stringlist allargs = split(command, ' ', false);
      if (!dir.empty()) // explicit dir to run in
        {
          chdir(dir.c_str());
        }
      else if (allargs[0].find('/') != std::string::npos) // relative path
        {
          // relative path
          // first change to directory and then execute ./command
          std::string dir = dirname(allargs[0]);
          chdir(dir.c_str());
          allargs[0] = std::string("./") + basename(allargs[0]);
        }
      char * argv[allargs.size() + 1];
      for (unsigned int i=0; i<allargs.size(); ++i)
        {
          argv[i] = strdup(allargs[i].c_str());
        }
      argv[allargs.size()] = 0;
      execvp(argv[0], argv);
      std::cerr << "Failed to run " << command << "\n"
                << "Maybe it is not in your path ?\n";
      exit(127);
    }
  else if (pid < 0)
    {
      std::cerr << "fork failed, try using a knife\n";
      exit(127);
    }
  else
    {
      int status = 0;
      while (true)
        {
          int waitReturn = waitpid(pid, &status, 0);
          if (waitReturn < 0)
            {
              if (errno == EINTR)
                continue;
              std::cerr << "waitpid failed " << strerror(errno) << "\n";
              exit(127);
            }
          break;
        }

      if (WIFEXITED(status))
        {
          int exitStatus = WEXITSTATUS(status);
          if (exitStatus)
            exit(exitStatus);
        }
      else if (WIFSIGNALED(status))
        {
          std::cerr << "Received signal " << WTERMSIG(status) << "\n";
          exit(127);
        }
      else
        {
          std::cerr << "Something weird happened to my child\n";
          exit(127);
        }
    }
#else
  char cwd[100];
  getcwd(cwd, 100);
  stringlist allargs = split(command);
  std::string dir = ".";
  if (allargs[0].find('/') != std::string::npos) // relative path
    {
      // relative path
      // first change to directory and then execute ./command
      dir = dirname(allargs[0]);
      chdir(dir.c_str());
      allargs[0] = std::string("./") + basename(allargs[0]);
    }
  std::string comm = join(" ", allargs);
  int status = system(comm.c_str());
  if (status)
    {
      std::cerr << "trying to run the command in a shell\n";
      std::ostringstream wincommand;
      wincommand << "sh -c \'" << comm << "\'";
      status = system(wincommand.str().c_str());
    }
  if (status)
    {
      std::cerr << "Failed to run " << command << "\n"
                << "Maybe it is not in your path ?\n";
      exit(127);
    }
  chdir(cwd);

#endif
}
