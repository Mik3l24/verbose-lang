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
BOUNDARY [\p{Space}||{SYMBOL}]
AFTER_SYMBOL (?=[[:space:][:alnum:]|{SYMBOL}])
AFTER_BOUNDARY (?=[[:space:][:alnum:]|{BOUNDARY}])
IDENTIFIER [a-zA-Z_][a-zA-Z0-9_]*




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
{SYMBOL} {retv(LIT_STRING, text().substr(1, text().size() - 2))}

/* Keyword section    */
"begin" {ret(KEY_BEGIN)}
"end" {ret(KEY_END)}
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
"print" {ret(KEY_END)}
"call" {ret(KEY_END)}
"read" {ret(KEY_END)}
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
"!"{AFTER_SYMBOL} {ret(KEY_TERMINATOR)}
"#"{AFTER_SYMBOL} {ret(KEY_TERMINATOR)}
"&"{AFTER_SYMBOL} {ret(KEY_TERMINATOR)}
"%"{AFTER_SYMBOL} {ret(KEY_TERMINATOR)}
"$"{AFTER_SYMBOL} {ret(KEY_TERMINATOR)}
"<="{AFTER_SYMBOL} {ret(KEY_TERMINATOR)}
"++"{AFTER_SYMBOL} {ret(KEY_TERMINATOR)}
"!="{AFTER_SYMBOL} {ret(KEY_TERMINATOR)}
")."{AFTER_SYMBOL} {ret(KEY_TERMINATOR)}
"i++"{AFTER_SYMBOL} {ret(KEY_TERMINATOR)}


/* Identifiers section */
[A-Za-z_][A-Za-z0-9_]* {ret(IDENTIFIER)}
"Function"{IDENTIFIER} {ret(IDENTIFIER)}
"Int"{IDENTIFIER} {ret(KEY_END)}
"Float"{IDENTIFIER} {ret(KEY_END)}
"String"{IDENTIFIER} {ret(KEY_END)}
"Bool"{IDENTIFIER} {ret(KEY_END)}
"UInt"{IDENTIFIER} {ret(KEY_END)}
"UInt16"{IDENTIFIER} {ret(KEY_END)}
"RETURN_CODE"{IDENTIFIER} {ret(KEY_END)}
"SUCCESS"{IDENTIFIER} {ret(KEY_END)}
"RETURN_CODE's"{IDENTIFIER} {ret(KEY_END)}
"Function"{IDENTIFIER} {ret(KEY_END)}
"ERROR"{IDENTIFIER} {ret(KEY_END)}
"main"{IDENTIFIER} {ret(KEY_END)}
"Array"{IDENTIFIER} {ret(KEY_END)}
"isNotEqual"{IDENTIFIER} {ret(KEY_END)}
"read."{IDENTIFIER} {ret(KEY_END)}
"print."{IDENTIFIER} {ret(KEY_END)}
"call."{IDENTIFIER} {ret(KEY_END)}
"read."{IDENTIFIER} {ret(KEY_END)}
"y."{IDENTIFIER} {ret(KEY_END)}
"n."{IDENTIFIER} {ret(KEY_END)}
"true"{IDENTIFIER} {ret(KEY_END)}
"false"{IDENTIFIER} {ret(KEY_END)}
"SUCCESS,"{IDENTIFIER} {ret(KEY_END)}
"standard"{IDENTIFIER} {ret(KEY_END)}
"library"{IDENTIFIER} {ret(KEY_END)}
"x."{IDENTIFIER} {ret(KEY_END)}
"and"{IDENTIFIER} {ret(KEY_END)}
"0xA0F9,"{IDENTIFIER} {ret(KEY_END)}
"0b1001000010101111"{IDENTIFIER} {ret(KEY_END)}
"x"{IDENTIFIER} {ret(KEY_END)}
"pi"{IDENTIFIER} {ret(KEY_END)}
"3var"{IDENTIFIER} {ret(KEY_END)}
"pi/2."{IDENTIFIER} {ret(KEY_END)}
"arr"{IDENTIFIER} {ret(KEY_END)}
"arr."{IDENTIFIER} {ret(KEY_END)}
"i."{IDENTIFIER}{ret(KEY_END)}
"SUCCESS."{IDENTIFIER} {ret(KEY_END)}
"end."{IDENTIFIER} {ret(KEY_END)}
"lambdaExample"{IDENTIFIER} {ret(KEY_END)}




/* [A-Za-z_][\w-]*(?=[\p{Space}||{SYMBOL}]) {yylval.strval = strdup(yytext); return IDENTIFIER;} 
Znaleznieie indetyfikatorów, aflanumeryczne > 1*/

/* Other */
/*Ignore whitespace*/
/* {ENDL} {vprint("endline");}
{LETTER}{ALNUM}* {yylval.strval = strdup(text()); return IDENTIFIER;}

/* Literals section */
/* {DIGIT}+ {yylval.intval = atoi(text()); return LITERAL_INT;} */ 


/* Keywords section */

/* Match whitespace */
\p{Space}+ { }

/* Match any other non-whitespace chars with length > 1 */
[^[:space:]]{2,2} {std::cout << "Token with more than one symbol: " << text() << '\n';}

/* Identifiers*/
[^[:space:]]{3,100} {std::cout << "Identifiers: " << text() << '\n';}

/* Match any other non-whitespace chars with length > 1 */
[^[:space:]]{1,1} {std::cout << "Token with one symbol: " << text() << '\n';}
/* Any other non-whitespace chars are an unknown token, lexical error*/



\P{Space}+ {std::cout << "Unknown token: " << text() << '\n';}



%%

