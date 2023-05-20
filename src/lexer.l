%option noyywrap
%top{
#include <iostream>
#include <string>

#include "parser.hpp"


#ifdef VERBOSE_PARSER_MODE
// Print for debugging
#define vprint(text) {std::cout << text << '\n';}
// Macro that signifies a token has been found, to be replaced with returns for Bison
#define ret(token) {std::cout << "Found token " << #token << std::endl;}
// Macro that signifies a token with an assigned value has been found
#define retv(token,val) {std::cout << "Found token " << #token << " Value " << val << std::endl;}

#define err(what) {std::cerr << what << '\n';}
#else 
// Print for debugging
#define vprint(text) {std::cout << text << '\n';}
// Macro that signifies a token has been found, to be replaced with returns for Bison
#define ret(token) {std::cout << "Found token " << #token << '\n';}
// Macro that signifies a token with an assigned value has been found
#define retv(token,val) {std::cout << "Found token " << #token << " Value " << val << '\n';}

#define err(what) {std::cerr << what << '\n';}
#endif
%}

%class{
std::string literal_str;
%}

%init{
literal_str.clear(); /*probably unnessesary, but for safety in case it doesn't get cleared*/
%}





/* States */
%x IN_COMMENT_INLINE
%x IN_STRING_LITERAL

/* Utility patterns */
ENDL \r?\n
SYMBOL [\.,\"'\+\-\*\/\^\|\(\)=<>!%&\\\[\]\{\}\(\)\?;:]

AFTER_SYMBOL (?=.*)
AFTER_ALNUM (?=([^\p{Alnum}_])(.*))
IDENTIFIER_CHARS [\p{Alnum}_]




%%
/* Comment section */
"rem"{AFTER_ALNUM} {
    push_state(IN_COMMENT_INLINE); //vprint("comment");
}
("//")(?=.*) {
    push_state(IN_COMMENT_INLINE); //vprint("comment");
}
<IN_COMMENT_INLINE>[^\n]*
<IN_COMMENT_INLINE>{ENDL} {
    pop_state(); //vprint("comment end");
}
<IN_COMMENT_INLINE><<EOF>> {
    pop_state(); //vprint("comment end");
}

/* Literals section (ex. strings in "", or 1.5f) */
/*-string-*/
\"{AFTER_SYMBOL} {push_state(IN_STRING_LITERAL);}
<IN_STRING_LITERAL>{ENDL}|\t /* Ignore newline character, but escaped n "\n" should still be captured */
<IN_STRING_LITERAL>\Q\"\E {literal_str += '"';}
<IN_STRING_LITERAL>\Q\n\E {literal_str += '\n';}
<IN_STRING_LITERAL>\Q\t\E {literal_str += '\t';}
<IN_STRING_LITERAL>[^\"] {literal_str += text();}
<IN_STRING_LITERAL>\" {
    pop_state();
    std::string return_str = literal_str;
    literal_str.clear();
    retv(LIT_STRING, return_str);
}
<IN_STRING_LITERAL><<EOF>> {err("Lexical Error: String literal not closed");}



/*-float- //at least 1 digit after the decimal point is required 
          so it is not mistaken for the instruction terminator */
(\d+).(\d+)(?:f?){AFTER_ALNUM} {retv(LIT_FLOAT, std::stod(text()))}
/*-bin int- // not working*/
(?:0[bB])[10]+{AFTER_ALNUM} {retv(LIT_INT, std::stoi(text(), nullptr, 2))}
/*-hex int- // not working*/
0[xX][ABCDEFabcdef\d]+{AFTER_ALNUM} {retv(LIT_INT, std::stoi(text()))}
/*-int- //no unary minus atm */
(\d+){AFTER_ALNUM} {retv(LIT_INT, std::stoi(text()))}


/* Keyword section    */
"begin"{AFTER_ALNUM} {ret(KEY_BEGIN)}
"end"{AFTER_ALNUM} {ret(KEY_END)}
"include"{AFTER_ALNUM} {ret(KEY_INCLUDE)}
"library"{AFTER_ALNUM} {ret(KEY_LIBRARY)}
"enum"{AFTER_ALNUM} {ret(KEY_ENUM)}
"named"{AFTER_ALNUM} {ret(KEY_NAMED)}
"of"{AFTER_ALNUM} {ret(KEY_OF)}
"function"{AFTER_ALNUM} {ret(KEY_FUNCTION)}
"returning"{AFTER_ALNUM} {ret(KEY_RETURNING)}
"variable"{AFTER_ALNUM} {ret(KEY_VARIABLE)}
"procedure"{AFTER_ALNUM} {ret(KEY_PROCEDURE)}
"return"{AFTER_ALNUM} {ret(KEY_RETURN)}
"parameters"{AFTER_ALNUM} {ret(KEY_PARAMETERS)}
"constant"{AFTER_ALNUM} {ret(KEY_CONSTANT)}
"arguments"{AFTER_ALNUM} {ret(KEY_ARGUMENTS)}
"assigned"{AFTER_ALNUM} {ret(KEY_ASSIGNED)}
"assign"{AFTER_ALNUM} {ret(KEY_ASSIGN)}
"print"{AFTER_ALNUM} {ret(KEY_PRINT)}
"call"{AFTER_ALNUM} {ret(KEY_CALL)}
"read"{AFTER_ALNUM} {ret(KEY_READ)}
"if"{AFTER_ALNUM} {ret(KEY_IF)}
"while"{AFTER_ALNUM} {ret(KEY_WHILE)}
"size"{AFTER_ALNUM} {ret(KEY_SIZE)}
"by"{AFTER_ALNUM} {ret(KEY_BY)}
"for"{AFTER_ALNUM} {ret(KEY_FOR)}
"at"{AFTER_ALNUM} {ret(KEY_AT)}
"values"{AFTER_ALNUM} {ret(KEY_VALUES)}
"value"{AFTER_ALNUM} {ret(KEY_VALUE)}




/* Symbols/operators section */
"<="{AFTER_SYMBOL} {ret(OP_LESS_EQUAL)}
">="{AFTER_SYMBOL} {ret(OP_GREATER_EQUAL)}
"++"{AFTER_SYMBOL} {ret(OP_INCREMENT)}
"--"{AFTER_SYMBOL} {ret(OP_DECREMENT)}
"!="{AFTER_SYMBOL} {ret(OP_NOT_EQUAL)}
"+"{AFTER_SYMBOL} {ret(OP_PLUS)}
"-"{AFTER_SYMBOL} {ret(OP_MINUS)}
"*"{AFTER_SYMBOL} {ret(OP_MULT)}
"/"{AFTER_SYMBOL} {ret(OP_DIV)}
"^"{AFTER_SYMBOL} {ret(OP_POWER)}
"."{AFTER_SYMBOL} {ret(DIV_TERMINATOR)}
"="{AFTER_SYMBOL} {ret(OP_EQUAL)}
">"{AFTER_SYMBOL} {ret(OP_GREATER)}
"<"{AFTER_SYMBOL} {ret(OP_LESS)}
"'s"{AFTER_SYMBOL} {ret(OP_ACCESSOR)}
"("{AFTER_SYMBOL} {ret(DIV_OPEN_PAREN)}
")"{AFTER_SYMBOL} {ret(DIV_CLOSE_PAREN)}
"}"{AFTER_SYMBOL} {ret(DIV_CLOSE_BRACE)}
"{"{AFTER_SYMBOL} {ret(DIV_OPEN_BRACE)}
"["{AFTER_SYMBOL} {ret(DIV_OPEN_BRACKET)}
"]"{AFTER_SYMBOL} {ret(DIV_CLOSE_BRACKET)}
","{AFTER_SYMBOL} {ret(DIV_COMMA)}
"%"{AFTER_SYMBOL} {ret(OP_PERCENT)}

"or"{AFTER_ALNUM} {ret(OP_OR)}
"and"{AFTER_ALNUM} {ret(OP_AND)}
"not"{AFTER_ALNUM} {ret(OP_NOT)}


/* Identifiers section */
{IDENTIFIER_CHARS}+{AFTER_ALNUM} {retv(IDENTIFIER, text())}


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
