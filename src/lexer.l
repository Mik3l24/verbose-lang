%{
#include <iostream>
%}

LETTER [a-zA-ZąćęłńóśżźĄĆĘŃÓŁŚŻŹ]
WORD {LETTER}{3,}

%%
{WORD} {
    if(yyleng == 5) std::cout << "found 5\n";
}
%%

int yywrap(){std::cout << "wrap\n";}
