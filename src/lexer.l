%option noyywrap
%top{
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>



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
SYMBOL [\.,\"'\+\-\*\/\^\|\(\)=<>!%&\\\[\]\{\}\(\)\?;:]

AFTER_SYMBOL (?=.*?)
AFTER_ALNUM (?=[^{IDENTIFIER_CHARS}].*?)
IDENTIFIER_CHARS [\p{Alnum}_]




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
/* (\d*)\.(\d+)(?:f?)(?=\P{Alnum}*) {retv(LIT_FLOAT, std::stod(text()))} 
/*-int- //no unary minus atm */
/* (\d+)(?=\P{Alnum}*) {retv(LIT_INT, std::stoi(text()))} */ 

(\d).(\d+)(?:f?)(?=\P{Alnum}) {retv(LIT_FLOAT, std::stod(text()))}
/*-int- //no unary minus atm */
(\d+)(?=\P{Alnum}) {retv(LIT_INT, std::stoi(text()))}


/* Keyword section    */
"end"{AFTER_ALNUM} {ret(KEY_END)}
"include" {ret(KEY_END)}
"library" {ret(KEY_END)}
"enum" {ret(KEY_END)}
"named" {ret(KEY_END)}
"of" {ret(KEY_END)}
"function" {ret(KEY_END)}
"returning" {ret(KEY_END)}
"variable" {ret(KEY_END)}
"procedure" {ret(KEY_END)}
"return" {ret(KEY_END)}
"parameters" {ret(KEY_END)}
"constant" {ret(KEY_END)}
"arguments" {ret(KEY_END)}
"assigned" {ret(KEY_END)}
"call" {ret(KEY_END)}
"if" {ret(KEY_END)}
"while" {ret(KEY_END)}
"size" {ret(KEY_END)}
"by" {ret(KEY_END)}
"for" {ret(KEY_END)}
"at" {ret(KEY_END)}
"values" {ret(KEY_END)}




/* Symbols/operators section */
"+"{AFTER_SYMBOL} {ret(OP_ADD)}
"-"{AFTER_SYMBOL} {ret(OP_SUB)}
"*"{AFTER_SYMBOL} {ret(OP_MUL)}
"/"{AFTER_SYMBOL} {ret(OP_DIV)}
"^"{AFTER_SYMBOL} {ret(OP_H)}
"."{AFTER_SYMBOL} {ret(KEY_TERMINATOR)}
"|"{AFTER_SYMBOL} {ret(KEY_TERMINATOR)}
"?"{AFTER_SYMBOL} {ret(KEY_TERMINATOR)}
"/"{AFTER_SYMBOL} {ret(KEY_TERMINATOR)}
""{AFTER_SYMBOL} {ret(KEY_TERMINATOR)}
"="{AFTER_SYMBOL} {ret(KEY_TERMINATOR)}
">"{AFTER_SYMBOL} {ret(KEY_TERMINATOR)}
"<"{AFTER_SYMBOL} {ret(KEY_TERMINATOR)}
";"{AFTER_SYMBOL} {ret(KEY_TERMINATOR)}
":"{AFTER_SYMBOL} {ret(KEY_TERMINATOR)}
"'"{AFTER_SYMBOL} {ret(KEY_TERMINATOR)}
"("{AFTER_SYMBOL} {ret(KEY_TERMINATOR)}
")"{AFTER_SYMBOL} {ret(KEY_TERMINATOR)}
"}"{AFTER_SYMBOL} {ret(KEY_TERMINATOR)}
"{"{AFTER_SYMBOL} {ret(KEY_TERMINATOR)}
"["{AFTER_SYMBOL} {ret(KEY_TERMINATOR)}
"]"{AFTER_SYMBOL} {ret(KEY_TERMINATOR)}
","{AFTER_SYMBOL} {ret(KEY_TERMINATOR)}
"%"{AFTER_SYMBOL} {ret(KEY_TERMINATOR)}
"<="{AFTER_SYMBOL} {ret(KEY_TERMINATOR)}
"++"{AFTER_SYMBOL} {ret(KEY_TERMINATOR)}
"!="{AFTER_SYMBOL} {ret(KEY_TERMINATOR)}



/* Identifiers section */
{IDENTIFIER_CHARS}+ {retv(IDENTIFIER, text())}

/* testing/utility */
/* Match any other non-whitespace chars with length > 1 */
/* [^[:space:]]{2,2} {std::cout << "Token with more than one symbol: " << text() << '\n';} */

/* Identifiers*/
/* [^[:space:]]{3,100} {std::cout << "Identifiers: " << text() << '\n';} */

/* Match any other non-whitespace chars with length > 1 */
/* [^[:space:]]{1,1} {std::cout << "Token with one symbol: " << text() << '\n';} */

/* Other */
/*Ignore whitespace*/
\p{Space}+ { }
/* Any other non-whitespace chars are an unknown token, lexical error*/
\P{Space}+ {std::cout << "Unknown token: " << text() << '\n';}



%%

