%option noyywrap
%top{
#include <iostream>

// List of possible tokens
#include "../src/tokens.h"

// Print for debugging
#define vprint(text) {std::cout << text << '\n';}
// Macro that signifies a token has been found, to be replaced with returns for Bison
#define ret(token) {std::cout << "Found token " << #token << '\n';}
// Macro that signifies a token with an assigned value has been found
#define retv(token,val) {std::cout << "Found token " << #token << " Value " << val << '\n';}
%}

/* States */
%x IN_COMMENT_INLINE

/* Utility patterns */
ENDL \r?\n
SYMBOL [\.,\"'\+\-\*\/\^\|\(\)=<>!%&\\\[\]\{\}]
BOUNDARY [\p{Space}||{SYMBOL}]

%%
/* Comment section */
"rem" {
    push_state(IN_COMMENT_INLINE); vprint("comment");
}
("//"|#)(?=.*) {
    push_state(IN_COMMENT_INLINE); vprint("comment");
}
<IN_COMMENT_INLINE>[^\n]*
<IN_COMMENT_INLINE>{ENDL} {
    pop_state(); vprint("comment end");
}
<IN_COMMENT_INLINE><<EOF>> {
    pop_state(); vprint("comment end");
}

/* Literals section (ex. strings in "", or 1.5f) */
/*-float- //at least 1 digit after the decimal point is required 
          so it is not mistaken for the instruction terminator */
(\d*)\.(\d+)(?:f?)(?=\P{Alnum}*) {retv(LIT_FLOAT, std::stod(text()))} 
/*-int- //no unary minus atm */
(\d+)(?=\P{Alnum}*) {retv(LIT_INT, std::stoi(text()))}

/* Keyword section */
"begin" {ret(KEY_BEGIN)}
"end" {ret(KEY_END)}


/* Symbols/operators section */


/* Identifiers section */


/* Other */
/*Ignore whitespace*/
\p{Space}
/*Any other non-whitespace chars are an unknown token, lexical error*/
\P{Space}+ {std::cout << "Unknown token: " << text() << '\n';}
%%

