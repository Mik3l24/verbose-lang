%option noyywrap
%top{
#include <iostream>
%}

LETTER [a-zA-ZąćęłńóśżźĄĆĘŃÓŁŚŻŹ]
WORD {LETTER}{3,}

%%
{WORD} {
    if(size() == 4) std::cout << "found 4\n";
}
%%

