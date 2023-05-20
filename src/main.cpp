#include <cstdio>
#include "lexer.h"
#include "parser.hpp"

extern int yyparse();

int main(int argc, char** argv) 
{
    yyparse();
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

