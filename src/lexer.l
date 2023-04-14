%option noyywrap
%top{
#include <iostream>
%}

%x IN_COMMENT_INLINE

LETTER [a-zA-ZąćęłńóśżźĄĆĘŃÓŁŚŻŹ]
WORD {LETTER}{3,}

ENDL \r?\n
COMMENT_INLINE (\/\/|#).*?({ENDL}|<<EOF>>)

%%
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


{WORD} {
    if(size() == 4) std::cout << "found 4\n";
}
%%

