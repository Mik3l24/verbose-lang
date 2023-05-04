%option noyywrap
%top{
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yylineno;
extern char* yytext;

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
DIGIT   [0-9]
LETTER  [A-Za-z_]
ALNUM   [A-Za-z0-9_]

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
[+][?=[[:space:][:alnum:]|{SYMBOL}]] {return OP_ADD;}
[-][?=[[:space:][:alnum:]|{SYMBOL}]] {return OP_SUB;}
[*][?=[[:space:][:alnum:]|{SYMBOL}]] {return OP_MUL;}
[/][?=[[:space:][:alnum:]|{SYMBOL}]] {return OP_DIV;}


/* Identifiers section */
/* [A-Za-z_][\w-]*(?=[\p{Space}||{SYMBOL}]) {yylval.strval = strdup(yytext); return IDENTIFIER;} */
{LETTER}{ALNUM}* {yylval.strval = strdup(yytext); return IDENTIFIER;}

/* Literals section */
{DIGIT}+ {yylval.intval = atoi(yytext); return LITERAL_INT;}


/* Other */

%%

/* int main(int argc, char** argv) {
    int token;
    while(token = yylex()) {
        switch(token) {
            case OP_ADD:
                printf("Operator: +\n");
                break;
            case OP_SUB:
                printf("Operator: -\n");
                break;
            case OP_MUL:
                printf("Operator: *\n");
                break;
            case OP_DIV:
                printf("Operator: /\n");
                break;
            case IDENTIFIER:
                printf("Identifier: %s\n", yylval.strval);
                free(yylval.strval);
                break;
            case LITERAL_INT:
                printf("Literal: %d\n", yylval.intval);
                break;
            default:
                printf("Unknown token\n");
                break;
        }
    }
    return 0;
} */