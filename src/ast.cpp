#include "ast.h"
#include <iostream>

using namespace AST;

#define TAB "  "
#define notnull(ptr) if(ptr == nullptr) {std::cerr << #ptr << " is null\n"; return;}

inline void writeTabs(DISP_ARGS)
{
    for(uint i = 0; i < tabs; i++) o << TAB;
}

#define dispSubNode(sub) writeTabs(o, tabs); o << #sub ":\n"; sub->display(o, tabs+1);

void Node::display(DISP_ARGS)
{
    writeTabs(o, tabs);
    o << nodeName() << '\n';
}

void FunctionDecl::display(DISP_ARGS)
{
    Node::display(o, tabs);
    writeTabs(o, tabs); o << "name: " << func_name << "\n";
    notnull(params); notnull(procedure);
    dispSubNode(params);
    dispSubNode(procedure);
}

FunctionDecl::FunctionDecl(String name, ParamsDecl* params, Procedure* procedure)
    : func_name(std::move(name)), params(params), procedure(procedure) {}

FunctionDecl::~FunctionDecl()
{
    delete params; delete procedure;
}