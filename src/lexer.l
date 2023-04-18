%option noyywrap
%top{
#include <iostream>

// List of possible tokens
#include "../src/tokens.h"

// Macro that signifies a token has been found, to be replaced with returns for Bison
#define ret(token) {std::cout << "Found token " << #token << '\n';}
%}

%x IN_COMMENT_INLINE

LETTER [a-zA-ZąćęłńóśżźĄĆĘŃÓŁŚŻŹ]
WORD {LETTER}{3,}

ENDL \r?\n
COMMENT_INLINE (\/\/|#).*?({ENDL}|<<EOF>>)

%%
/* Comment section */
\<rem\> {
    push_state(IN_COMMENT_INLINE); std::cout << "comment\n";
}
<IN_COMMENT_INLINE>[^\n]*
<IN_COMMENT_INLINE>{ENDL} {
    pop_state(); std::cout << "comment end\n";
}
{COMMENT_INLINE} {
    std::cout << "comment\n";
}

/* Literals section (ex. strings in "", or 1.5f) */


/* Keyword section */
\<begin\> {ret(BEGIN)}
\<end\> {ret(END)}


/* Symbols/operators section */


/* Identifiers section */


/* Testing section */
{WORD} {
    if(size() == 4) std::cout << "found 4\n";
}
%%

