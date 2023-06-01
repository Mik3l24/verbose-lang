#include <cstdio>
#include <memory>
#include "lexer.h"
#include "parser.hpp"

#include "ast.h"

extern int yyparse();

using namespace AST;
using std::make_unique;

int main(int argc, char** argv)
{

    auto funcdecl = make_unique<FunctionDecl>(String("Cool func"), make_unique<ParamsDecl>(),
                                              make_unique<Procedure>());

    funcdecl->display(std::cout, 0);
    //yyparse();

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

