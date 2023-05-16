

%code top {
    #include <iostream>

    extern int yylex(void);

    static void yyerror(const char* s) {
        std::cerr << "Parser error: " << s << '\n';
    }
}

%token COOL

%start program

%%

program : COOL {std::cout << "cool\n";}
        ;

%%