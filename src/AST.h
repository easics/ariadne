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

#ifndef AST_H_
#define AST_H_

#include "AriException.h"
#include <string>
#include "cvector.h"

#define CHECK_TYPE(type_name) \
  if (getType() != type_name) \
    throw AriException("This node is not of type " #type_name);
/*
                       "\nType is %d\n" \
                       "Name is %s\n" \
                       "String is %s\n" \
                       "Token type is %s", \
                       (int)getType(), getName().c_str(), \
                       getString().c_str(), \
                       getTokenType().c_str());
                       */
class AST;
typedef cvector<AST *> AST_list;

class AST
{
public:
  /**
    Types of nodes
   */
  enum E_AST_type { AST_UNKNOWN, AST_NODE, AST_STRING, AST_CHAR, AST_NUMBER };

  /**
    Default constructor (creates an unusable AST node)
   */
  AST() : type_(AST_UNKNOWN), node_name_("no name") {};
  /**
    Constructor for creating an AST string node
   */
  AST(const std::string & s) : type_(AST_STRING), string_(s) {}
  /**
    Constructor for creating an AST char node
   */
  AST(const char & c) : type_(AST_CHAR), char_(c) {}

  /**
    Recursively delete all children
   */
  void eraseChildren();

  /**
    Add a child node to this node
   */
  void addNode(AST * node) { nodes_.push_back(node); }

  /**
    Set the syntax-name of this node.  The syntax-name is the name of the
    rule for this node in the yacc syntax.
   */
  void setName(const std::string & node_name) { type_ = AST_NODE;
                                           node_name_ = node_name; }
  /**
    Set the token type of this node.  This method is used for leafs of
    the syntax tree (tokens)
   */
  void setTokenType(const std::string & token_type) { token_type_ = token_type; }
  /**
    Give a unique number to this node.  That number will be used to traverse
    the syntax tree.
   */
  void setRuleNumber(unsigned int rule_number) { type_ = AST_NODE;
                                                 rule_number_ = rule_number; }

  /**
    Return the token type. (%token statement in .w file)
   */
  const std::string & getTokenType() const { return token_type_; }
  /**
    Return the syntax-name of the node.
   */
  const std::string & getName() const { return node_name_; }
  /**
    Return the rule number of the node.
   */
  unsigned int getRuleNumber() const { return rule_number_; }
  /**
    Returns a list of children this node has
   */
  const AST_list & getNodes() const { CHECK_TYPE(AST_NODE); return nodes_; }
  AST_list & getNodes() { CHECK_TYPE(AST_NODE); return nodes_; }

  /**
    Return the node-type (AST_NODE, AST_STRING, ...)
   */
  const E_AST_type & getType() const { return type_; }
  /**
    Return the char value of this node
   */
  const char & getChar() const { CHECK_TYPE(AST_CHAR); return char_; }
  /**
    Return the string value of this node
   */
  const std::string & getString() const { return string_; }
  /**
    Set the string value of this node
   */
  void setString(const std::string & s) { string_ = s; }
  /**
    Set the integer value of this node
   */
  void setNumber(int number) { number_ = number; }
  /**
    Return the integer value of this node
   */
  int getNumber() const { return number_; }

  /**
    Write a description of this node to stdout
   */
  void print(bool extended=false) const;

  /**
    Give a textual representation of this node.
    Text is appended to the argument.
   */
  void text(std::string & s) const;
  std::string text() const;

  unsigned int line_number;
  unsigned int column_number;

private:
  E_AST_type type_;

  AST_list nodes_;
  std::string node_name_;
  unsigned int rule_number_;

  std::string string_;
  char char_;

  std::string token_type_;

  int number_;

};

extern AST ast;

#endif
