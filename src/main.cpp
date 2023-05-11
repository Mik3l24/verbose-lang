#include <cstdio>
#include "lexer.h"

int main(int argc, char** argv) 
{
    FILE* fd = stdin;
    if(argc > 1 && (fd = fopen(argv[1], "r")) == NULL)
        exit(EXIT_FAILURE);
    if(fd == stdin) //Lexer only works when a file is open
        exit(EXIT_FAILURE);
    // create a lexer that consumes a file or reads stdin
    Lexer lexer(fd);
    // here we go!
    lexer.lex();
    // display the results
    if(fd != stdin)
        fclose(fd);
    return 0;
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

