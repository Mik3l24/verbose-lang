#include "ast.h"
#include <iostream>
#include <utility>

using namespace AST;

#define TAB "  "
#define notnull(target) if(target == nullptr) {std::cerr << #target << " is null\n"; return;}
#define dispSubNode(sub) writeTabs(o, tabs); o << #sub ":\n"; sub->display(o, tabs+1);
#define dispField(field) writeTabs(o, tabs); o << #field ": " << field << '\n';

inline void writeTabs(DISP_ARGS)
{
    for(uint i = 0; i < tabs; i++) o << TAB;
}

// Definitions
void Node::display(DISP_ARGS)
{
    writeTabs(o, tabs);
    o << nodeName() << '\n';
}

void Expression::display(DISP_ARGS)
{
    Node::display(o, tabs);
}

void Statement::display(DISP_ARGS)
{
    Node::display(o, tabs);
}

// Literal Expressions
void IntegerLiteral::display(DISP_ARGS)
{
    Expression::display(o, tabs);
    dispField(value);
}

void FloatLiteral::display(DISP_ARGS)
{
    Expression::display(o, tabs);
    dispField(value);
}

void StringLiteral::display(DISP_ARGS)
{
    Expression::display(o, tabs);
    dispField(value);
}

// Identifier
void Identifier::display(DISP_ARGS)
{
    Expression::display(o, tabs);
    dispField(name);
}

// Call-related
void CallArgs::display(DISP_ARGS)
{
    Node::display(o, tabs);
    for(auto& arg : list)
    {
        dispSubNode(arg);
    }
}

void Call::display(DISP_ARGS)
{
    Expression::display(o, tabs);
    dispSubNode(callable);
    if(args != nullptr)
    {
        dispSubNode(args);
    }
    else
    {
        writeTabs(o, tabs); o << "args: none\n";
    }
}

// Operations
void UnaryOperation::display(DISP_ARGS)
{
    Expression::display(o, tabs);
    dispField(op);
    dispSubNode(expr);
}

void BinaryOperation::display(DISP_ARGS)
{
    Expression::display(o, tabs);
    dispField(op);
    dispSubNode(left);
    dispSubNode(right);
}




void FunctionDecl::display(DISP_ARGS)
{
    Statement::display(o, tabs);
    writeTabs(o, tabs); o << "name: " << func_name << "\n";
    notnull(params); notnull(procedure);
    dispSubNode(params);
    dispSubNode(procedure);
}

FunctionDecl::FunctionDecl(String name, unique_ptr<ParamsDecl> params, unique_ptr<Procedure> procedure)
    : func_name(std::move(name)), params(std::move(params)), procedure(std::move(procedure)) {}



