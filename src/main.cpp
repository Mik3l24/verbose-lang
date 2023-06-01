#include <cstdio>
#include "lexer.h"
#include "parser.hpp"

#include "ast.h"

extern int yyparse();

using namespace AST;

int main(int argc, char** argv) 
{
    auto* testparams = new ParamsDecl();
    auto* testproc = new Procedure();
    auto* funcdecl = new FunctionDecl(String("Cool func"), testparams, testproc);

    funcdecl->display(std::cout, 0);
    //yyparse();
    delete funcdecl;
}

// #include <iostream>
// #include "tokens.h"

// int main() {
//     std::cout << "Enter variable name: ";
//     std::string var_name;
//     std::cin >> var_name;
//     std::cout << "Enter variable value: ";
//     int var_value;
//     std::cin >> var_value;
//     std::cout << "Assign " << var_name << " value " << var_value << '\n';
//     return 0;
// }

