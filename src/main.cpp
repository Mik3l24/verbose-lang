#include <cstdio>
#include <memory>
#include "lexer.h"
#include "parser.hpp"

#include "ast.h"

extern int yyparse();

using namespace AST;
using std::make_unique;

void testAST()
{
    CallArgs args;
    args.list.push_back(make_unique<BinaryOperation>(
            make_unique<UnaryOperation>(
                    make_unique<IntegerLiteral>(1),
                    UnaryOperation::Operator::NEGATIVE
                            ),
            make_unique<IntegerLiteral>(2),
             BinaryOperation::Operator::PLUS));
    args.list.push_back(make_unique<FloatLiteral>(2.0));
    args.list.push_back(make_unique<StringLiteral>("Hello World"));
    args.display(std::cout, 0);

    auto funcdecl = make_unique<FunctionDecl>(make_unique<Identifier>(String("Cool func")), make_unique<ParamsDecl>(),
                                              make_unique<Procedure>());

    funcdecl->display(std::cout, 0);

    //yyparse();

}

FILE* yyin;

extern Lexer YY_SCANNER;

extern unique_ptr<Program> program;

int main(int argc, char** argv)
{
    if(argc < 2)
    {
        printf("Usage: %s <filename>\n", argv[0]);
        return 1;
    }

    FILE* file = fopen(argv[1], "r");
    if(file == nullptr)
    {
        printf("Error: could not open file %s\n", argv[1]);
        return 1;
    }
    // declaration of yyin


    yyin = file;

    YY_SCANNER.in(reflex::Input(file));

    yyparse();

    fclose(file);

    program->display(std::cout, 0);

    //testAST();
    return 0;
}


// #include <iostream>
// #include "tokens.h"

// int main() {
//     std::cout << "Enter variable name: ";
//     std::string term_name;
//     std::cin >> term_name;
//     std::cout << "Enter variable value: ";
//     int var_value;
//     std::cin >> var_value;
//     std::cout << "Assign " << term_name << " value " << var_value << '\n';
//     return 0;
// }

