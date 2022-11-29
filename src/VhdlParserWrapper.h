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

#ifndef VhdlParserWrapper_h_
#define VhdlParserWrapper_h_

#include "ASTTraversalvhdl.h"
#include "Context.h"

class Module;

// Name looks very much like vhdlParser but vhdlParser is generated by wisent
// and this class is hand written.  Both classes do some part of parsing the
// vhdl (this class uses the other one) and I did not find a better name.
class VhdlParserWrapper : public ASTTraversalvhdl
{
public:
  VhdlParserWrapper(Module * module);
  ~VhdlParserWrapper();

  void parseFile(const std::string & filename);

  void entity_start(AST & node);
  void use_clause_list(AST & node);
  void interf_element(AST & node);
  void entity_decl_1(AST & node);
  void entity_decl_1_exit(AST & node);
  void entity_decl_2(AST & node);
  void entity_decl_2_exit(AST & node);

private:
  enum E_InterfMode { NONE, PORTS, GENERICS };

  // convert to lowercase, remove leading, trailing and double spaces
  CaseAwareString normalizeString(const std::string & s);

  Module * module_;
  Context collectedContext_;
  bool correctEntity_;
  E_InterfMode interf_list_mode_;
  std::string filename_;
};

#endif