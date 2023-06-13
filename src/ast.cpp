#include "ast.h"
#include <iostream>
#include <utility>

using namespace AST;

#define TAB "  "
#define notnull(target) if(target == nullptr) {std::cerr << #target << " is null\n"; return;}
//#define dispSubNode(sub) writeTabs(o, tabs); o << #sub ":\n"; sub->display(o, tabs+1);
#define dispNullableSubNode(sub) \
    if(sub != nullptr)  \
    {                     \
    writeTabs(o, tabs); o << #sub ":\n"; sub->display(o, tabs+1); \
    }                    \
    else                 \
    {                    \
        writeTabs(o, tabs); o << #sub ": none\n";\
    }
#define dispSubNode(sub) dispNullableSubNode(sub)
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
    Statement::display(o, tabs);
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
    for(auto& arg: list)
    {
        dispSubNode(arg);
    }
}

void Call::display(DISP_ARGS)
{
    Expression::display(o, tabs);
    dispSubNode(callable);
    dispNullableSubNode(args);
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


void TermDecl::display(DISP_ARGS)
{
    Statement::display(o, tabs);
    dispSubNode(term_name);
    dispField(is_const);
    dispNullableSubNode(assigned_value);
}

void Assignment::display(DISP_ARGS)
{
    Statement::display(o, tabs);
    dispSubNode(term);
    dispSubNode(assigned_value);
}

// Procedure-related
void Procedure::display(DISP_ARGS)
{
    Statement::display(o, tabs);
    for(auto& statement: statements)
    {
        dispSubNode(statement);
    }
}

void ParamsDecl::display(DISP_ARGS)
{
    Node::display(o, tabs);
    for(auto& parameter : list)
    {
        dispSubNode(parameter);
    }
}


void FunctionDecl::display(DISP_ARGS)
{
    Statement::display(o, tabs);
    dispNullableSubNode(func_name);
    dispNullableSubNode(return_type);
    dispNullableSubNode(params);
    dispNullableSubNode(procedure);
}

void IfStatement::display(std::ostream& o, uint tabs)
{
    Statement::display(o, tabs);
    dispSubNode(condition);
    dispSubNode(procedure);
    dispNullableSubNode(else_procedure);
}

void WhileStatement::display(std::ostream& o, uint tabs)
{
    Statement::display(o, tabs);
    dispSubNode(condition);
    dispSubNode(procedure);
}

void Program::display(std::ostream& o, uint tabs)
{
    Node::display(o, tabs);
    for(auto& statement: statements)
    {
        dispSubNode(statement);
    }
}

