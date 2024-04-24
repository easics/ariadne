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


#include "AriException.h"
#include "Module.h"
#include "AriElaborate.h"
#include "ariFileParser.h"
#include "AriOptions.h"
#include "PathFunctions.h"
#include "AriadneVersionString.h"
#include "Copyright.h"
#include "StringUtil.h"
#include "SmartFile.h"
#include "FileHeader.h"
#include <iostream>
#include <cstring>
#include <unistd.h>

using namespace PathFunctions;

int main(int argc, char *argv[])
{

  if (!getenv("ARIADNE_QUIET_COPYRIGHT"))
    std::cout << copyright << "\n";
  try
    {
      StringUtil::stringlist argv_;
      AriOptions * ariOptions = AriOptions::getInstance();
      bool queryPackages = false;
      int opt_result;
      while ((opt_result = getopt(argc, argv, "hvngGcI:D:frCH:p")) > 0)
        {
          switch (opt_result)
            {
            case '?' :
            case 'h' :
              std::cout <<
                "Usage: " << argv[0] <<
                " [-h] [-v] [-n] <arifile>\n"
                "    " << argv[0] << " generates VHDL structural code.\n"
                "    -h : show this help\n"
                "    -v : show version number\n"
                "    -n : do not generate entity files (only architectures)\n"
                "    -g : overwrite group comment of each auto-connected port\n"
                "         with the instance names of the subblocks the port\n"
                "         connects to\n"
                "         This also sets the env var ARIADNE_GROUP_SOURCE\n"
                "         that will trigger sub-ariadne invocations to do the\n"
                "         same\n"
                "    -G : Same as -g but without setting the env var\n"
                "    -c : Entities are cast in stone. i.e. ariadne will not\n"
                "         overwrite entity files. It reports if ports would\n"
                "         be added or removed and exits with an error if\n"
                "         there are.\n"
                "    -I <dir> : include dir, also look in this dir for files\n"
                "               specified in from statement.\n"
                "    -D <define> : define macro (used with #ifdef).\n"
                "    -f : Always overwrite generated files, even if they have\n"
                "         not changed (force)\n"
                "    -r : Detect if an entity read by ariadne was generated\n"
                "         by an Easics tool.  If so, reinvoke the tool to\n"
                "         regenerate the entity\n"
                "         This also sets the env var ARIADNE_REGENERATE\n"
                "         that will trigger sub-ariadne invocations to do the\n"
                "         same\n"
                "    -C : print changelog\n"
                "    -H <file> : add a header to generated files\n"
                "    -p : print the origin of all packages appearing in\n"
                "         entity and architecture file\n";
              return 0;
            case 'v' :
              std::cout <<
                "ariadne version " << ariadneVersionString << "\n";
              return 0;

            case 'n' :
              ariOptions->setWriteEntity(false);
              break;
            case 'g' :
              ariOptions->groupCommentIsSource = true;
              putenv((char*)"ARIADNE_GROUP_SOURCE=1");
              break;
            case 'G' :
              ariOptions->groupCommentIsSource = true;
              break;
            case 'c':
              ariOptions->entitiesCastInStone = true;
              break;
            case 'I':
              ariOptions->includeDirs.push_back(optarg);
              break;
            case 'D':
              ariOptions->defines.push_back(optarg);
              break;
            case 'H':
              ariOptions->setFileHeader(new FileHeader(optarg, 0));
              break;
            case 'f':
              SmartFile::forceOverwrite = true;
              putenv((char*)"ARIADNE_FORCE_WRITE=1");
              break;
            case 'r':
              Module::regenerateEntities_ = true;
              putenv((char*)"ARIADNE_REGENERATE=1");
              break;
            case 'p':
              queryPackages = true;
              break;
            case 'C':
              std::cout <<
#include "Changes"
                           ;
              return 0;
            default :
              std::cout << "Me confused\n";
              return 1;
            }
        }

      if (optind == argc)
        throw AriException("No arifile provided");
      if (optind + 1 != argc)
        throw AriException("Too many files given");

      for (int i=0; i<optind; ++i)
        argv_.push_back(argv[i]);

      if (getenv("ARIADNE_GROUP_SOURCE"))
        ariOptions->groupCommentIsSource = true;

      if (getenv("ARIADNE_FORCE_WRITE"))
        SmartFile::forceOverwrite = true;

      if (getenv("ARIADNE_REGENERATE"))
        Module::regenerateEntities_ = true;

      std::string file(argv[optind]);
      std::string dir = dirname(file);
      if (file.find('/') != std::string::npos)
        {
          chdir(dir.c_str());

          file = basename(file);
        }
      argv_.push_back(file);

      ariFileParser ariParser;
      ariParser.parseFile(file.c_str());
      AriElaborate ariElaborate(file);
      ariElaborate.traverse();
      ariElaborate.searchMissingFrom();
      ariElaborate.addIncludedFiles(ariParser.getIncludedFiles());
      ariElaborate.resolve();
      if (queryPackages)
        ariElaborate.queryPackages();
      else
        ariElaborate.generate(argv_);
    }
  catch (AriException & e)
    {
      std::cerr << e.getMessage() << "\n";
      return 1;
    }
  catch (const char * message)
    {
      std::cerr << message << "\n";
      return 1;
    }
  catch (std::exception & e)
    {
      std::cerr << e.what() << "\n";
      return 1;
    }
  return 0;
}
