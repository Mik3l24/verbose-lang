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
