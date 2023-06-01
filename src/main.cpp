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
    CallArgs args;
    args.list.push_back(make_unique<BinaryOperation>(
            Operator::PLUS,
            make_unique<UnaryOperation>(
                    Operator::MINUS,
                    make_unique<IntegerLiteral>(1)
                            ),
            make_unique<IntegerLiteral>(2)));
    args.list.push_back(make_unique<FloatLiteral>(2.0));
    args.list.push_back(make_unique<StringLiteral>("Hello World"));
    args.display(std::cout, 0);

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

