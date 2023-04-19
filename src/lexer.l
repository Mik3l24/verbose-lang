%option noyywrap
%top{
#include <iostream>

// List of possible tokens
#include "../src/tokens.h"

// Print for debugging
#define vprint(text) {std::cout << #text << '\n';}
// Macro that signifies a token has been found, to be replaced with returns for Bison
#define ret(token) {std::cout << "Found token " << #token << '\n';}
%}

/* States */
%x IN_COMMENT_INLINE

/* Utility patterns */
ENDL \r?\n

%%
/* Comment section */
\<rem\> {
    push_state(IN_COMMENT_INLINE); vprint(comment);
}
\/\/|# {
    push_state(IN_COMMENT_INLINE); vprint(comment);
}
<IN_COMMENT_INLINE>[^\n]*
<IN_COMMENT_INLINE>{ENDL} {
    pop_state(); vprint(comment end);
}
<IN_COMMENT_INLINE><<EOF>> {
    pop_state(); vprint(comment end);
}

/* Literals section (ex. strings in "", or 1.5f) */


/* Keyword section */
\<begin\> {ret(BEGIN)}
\<end\> {ret(END)}


/* Symbols/operators section */


/* Identifiers section */


/* Other */


%%

