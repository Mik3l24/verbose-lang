%code requires {
    #include <string>
    #include "ast.h"
}

%code top {
    #include <iostream>
    #include <memory>
    #include <vector>

    #define VERBOSE_PARSER_MODE
    #include "lexer.h"



    using std::unique_ptr, std::make_unique, std::vector, std::cerr, std::cout, std::endl;
    using namespace AST;

    unique_ptr<Program> program;

    extern int yylex(void);

    static void yyerror(const char* s) {
        std::cerr << "Parser error: " << s << '\n';
    }

    static void printerr(const char* s) {
        std::cerr << "Parser error: " << s << '\n';
    }

    
}

%union {
    std::string* string;
    int token;
    int intv;
    double floatv;

    AST::Node* node_t;
    AST::Expression* expression_t;
    AST::Statement* statement_t;
    AST::IntegerLiteral* integer_literal_t;
    AST::FloatLiteral* float_literal_t;
    AST::StringLiteral* string_literal_t;
    AST::Identifier* identifier_t;
    AST::CallArgs* call_args_t;
    AST::Call* call_t;
    AST::UnaryOperation* unary_operation_t;
    AST::BinaryOperation* binary_operation_t;
    AST::TermDecl* term_decl_t;
    AST::Assignment* assignment_t;
    AST::Procedure* procedure_t;
    AST::ParamsDecl* params_decl_t;
    AST::FunctionDecl* function_decl_t;
    AST::IfStatement* if_statement_t;
    AST::WhileStatement* while_statement_t;
}

// Identifiers, Literals 
%token <string> IDENTIFIER LIT_STRING
%token <intv> LIT_INT
%token <floatv> LIT_FLOAT

// Keywords 
%token KEY_BEGIN
%token KEY_END
%token KEY_INCLUDE
%token KEY_LIBRARY
%token KEY_ENUM
%token KEY_NAMED
%token KEY_OF
%token KEY_FUNCTION
%token KEY_RETURNING
%token KEY_VARIABLE
%token KEY_PROCEDURE
%token KEY_RETURN
%token KEY_PARAMETERS
%token KEY_CONSTANT
%token KEY_ARGUMENTS
%token KEY_ASSIGNED
%token KEY_ASSIGN
%token KEY_CALL
%token KEY_IF
%token KEY_WHILE
%token KEY_SIZE
%token KEY_BY
%token KEY_FOR
%token KEY_AT
%token KEY_VALUES
%token KEY_VALUE


// Dividers 
%token DIV_OPEN_PAREN
%token DIV_CLOSE_PAREN
%token DIV_CLOSE_BRACE
%token DIV_OPEN_BRACE
%token DIV_OPEN_BRACKET
%token DIV_CLOSE_BRACKET
%token DIV_COMMA

// Operators 
%token OP_LESS_EQUAL
%token OP_GREATER_EQUAL
%token OP_INCREMENT
%token OP_DECREMENT
%token OP_NOT_EQUAL
%token OP_PLUS
%token OP_MINUS
%token OP_MULT
%token OP_DIV
%token OP_POWER
%token DIV_TERMINATOR
%token OP_EQUAL
%token OP_GREATER
%token OP_LESS
%token OP_ACCESSOR
%token OP_PERCENT
%token OP_OR
%token OP_AND
%token OP_NOT

// AST TYPES
%type <expression_t> expression ident_expr type
%type <statement_t> statement
%type <procedure_t> procedure_rec procedure
%type <call_t> call call_rec
%type <identifier_t> identifier
%type <term_decl_t> term_decl
%type <function_decl_t> function_decl function_decl_rec function_decl_params_rec
%type <assignment_t> assignment
%type <if_statement_t> if_statement
%type <while_statement_t> while_statement

// Precedence
// Logical
%left OP_OR 
%left OP_AND
%right OP_NOT

// Relational //(should it be associative?)
%left OP_LESS OP_LESS_EQUAL OP_GREATER OP_GREATER_EQUAL OP_EQUAL OP_NOT_EQUAL

// Mathematical
%left OP_PLUS OP_MINUS
%left OP_MULT OP_DIV OP_PERCENT
%right OP_POWER
%left OP_ACCESSOR

%right UMINUS

%right OP_INCREMENT OP_DECREMENT

%start program

%%

program 
: /*Empty*/ { if(program == nullptr) program = make_unique<Program>(); }
| program statement { program->statements.emplace_back($2); }
;

identifier 
: IDENTIFIER { $$ = new Identifier(*$1); delete $1; }
;

ident_expr
: identifier { $$ = $1; }
;

type 
: identifier { $$ = $1; }
;


// Declarations
term_decl 
: KEY_VARIABLE type KEY_NAMED identifier { $$ = new TermDecl(unique_ptr<Identifier>($4), unique_ptr<Expression>($2)); }
| KEY_VARIABLE type KEY_NAMED identifier KEY_ASSIGNED expression { $$ = new TermDecl(unique_ptr<Identifier>($4), unique_ptr<Expression>($2), unique_ptr<Expression>($6), false); }
| KEY_CONSTANT type KEY_NAMED identifier KEY_ASSIGNED expression { $$ = new TermDecl(unique_ptr<Identifier>($4), unique_ptr<Expression>($2), unique_ptr<Expression>($6), true); }
;

function_decl 
: function_decl_rec procedure { $$ = $1; $$->procedure = unique_ptr<Procedure>($2); }
;

function_decl_rec 
: KEY_FUNCTION { $$ = new FunctionDecl(); } 
| function_decl_rec KEY_RETURNING type { $$->return_type = unique_ptr<Expression>($3); }
| function_decl_rec KEY_NAMED identifier { $$->func_name = unique_ptr<Identifier>($3); }
| function_decl_params_rec KEY_END { $$ = $1; }
//| function_decl_rec procedure { $$ = $1; $$->procedure = unique_ptr<Procedure>($2); }
// Error Handling
| function_decl_rec KEY_RETURNING error { printerr("Expected return type afer 'returning' in function declaration"); $$->return_type = unique_ptr<Expression>(ERROR_VAL); yyerrok; } 
| function_decl_rec KEY_NAMED error { printerr("Expected identifier after 'named' in function declaration"); $$->func_name = unique_ptr<Identifier>(ERROR_VAL); yyerrok; }
;

function_decl_params_rec 
: function_decl_rec KEY_PARAMETERS term_decl 
{ 
    $$ = $1; 
    if($$->params == nullptr) 
    $$->params = make_unique<ParamsDecl>(); 
    $$->params->list.emplace_back($3); 
}
| function_decl_params_rec DIV_COMMA term_decl { $$->params->list.emplace_back($3); }
| function_decl_params_rec DIV_COMMA {}
// Error Handling
| function_decl_params_rec DIV_COMMA error { $$->params->list.emplace_back(ERROR_VAL); yyerrok; }
;

// Expressions
call_rec 
: KEY_CALL identifier KEY_PARAMETERS expression { $$ = new Call(unique_ptr<Identifier>($2), make_unique<CallArgs>()); }
| call_rec DIV_COMMA expression { $$->args->list.emplace_back($3); }
;

call 
: KEY_CALL identifier { $$ = new Call(unique_ptr<Identifier>($2)); }
| call_rec KEY_END { $$ = $1; }
;

///*Empty*/ { $$ = nullptr; }
expression 
: DIV_OPEN_PAREN expression DIV_CLOSE_PAREN { $$ = $2; } // Brackets
| DIV_OPEN_BRACE expression DIV_CLOSE_BRACE { $$ = $2; }
| DIV_OPEN_BRACKET expression DIV_CLOSE_BRACKET { $$ = $2; }
// Operations
| expression OP_PLUS expression { $$ = new BinaryOperation(unique_ptr<Expression>($1), unique_ptr<Expression>($3), BinaryOperation::Operator::PLUS); }
| expression OP_MINUS expression { $$ = new BinaryOperation(unique_ptr<Expression>($1), unique_ptr<Expression>($3), BinaryOperation::Operator::MINUS); }
| expression OP_MULT expression { $$ = new BinaryOperation(unique_ptr<Expression>($1), unique_ptr<Expression>($3), BinaryOperation::Operator::MULTIPLY); }
| expression OP_DIV expression { $$ = new BinaryOperation(unique_ptr<Expression>($1), unique_ptr<Expression>($3), BinaryOperation::Operator::DIVIDE); }
| expression OP_POWER expression { $$ = new BinaryOperation(unique_ptr<Expression>($1), unique_ptr<Expression>($3), BinaryOperation::Operator::POWER); }
| expression OP_PERCENT expression { $$ = new BinaryOperation(unique_ptr<Expression>($1), unique_ptr<Expression>($3), BinaryOperation::Operator::MODULO); }
| expression OP_EQUAL expression { $$ = new BinaryOperation(unique_ptr<Expression>($1), unique_ptr<Expression>($3), BinaryOperation::Operator::EQUAL); }
| expression OP_NOT_EQUAL expression { $$ = new BinaryOperation(unique_ptr<Expression>($1), unique_ptr<Expression>($3), BinaryOperation::Operator::NOT_EQUAL); }
| expression OP_LESS expression { $$ = new BinaryOperation(unique_ptr<Expression>($1), unique_ptr<Expression>($3), BinaryOperation::Operator::LESS); }
| expression OP_LESS_EQUAL expression { $$ = new BinaryOperation(unique_ptr<Expression>($1), unique_ptr<Expression>($3), BinaryOperation::Operator::LESS_EQUAL); }
| expression OP_GREATER expression { $$ = new BinaryOperation(unique_ptr<Expression>($1), unique_ptr<Expression>($3), BinaryOperation::Operator::GREATER); }
| expression OP_GREATER_EQUAL expression { $$ = new BinaryOperation(unique_ptr<Expression>($1), unique_ptr<Expression>($3), BinaryOperation::Operator::GREATER_EQUAL); }
| expression OP_AND expression { $$ = new BinaryOperation(unique_ptr<Expression>($1), unique_ptr<Expression>($3), BinaryOperation::Operator::AND); }
| expression OP_OR expression { $$ = new BinaryOperation(unique_ptr<Expression>($1), unique_ptr<Expression>($3), BinaryOperation::Operator::OR); }
| OP_MINUS expression %prec UMINUS { $$ = new UnaryOperation(unique_ptr<Expression>($2), UnaryOperation::Operator::NEGATIVE); }
| OP_NOT expression %prec UMINUS { $$ = new UnaryOperation(unique_ptr<Expression>($2), UnaryOperation::Operator::NOT); }
| OP_INCREMENT expression { $$ = new UnaryOperation(unique_ptr<Expression>($2), UnaryOperation::Operator::PRE_INC); }
| OP_DECREMENT expression { $$ = new UnaryOperation(unique_ptr<Expression>($2), UnaryOperation::Operator::PRE_DEC); }
| expression OP_INCREMENT { $$ = new UnaryOperation(unique_ptr<Expression>($1), UnaryOperation::Operator::POST_INC); }
| expression OP_DECREMENT { $$ = new UnaryOperation(unique_ptr<Expression>($1), UnaryOperation::Operator::POST_DEC); }
// Literals
| LIT_INT { $$ = new IntegerLiteral($1); }
| LIT_FLOAT { $$ = new FloatLiteral($1); }
| LIT_STRING { $$ = new StringLiteral(*$1); delete $1; }
// Identifiers
| identifier { $$ = $1; }
// Function call
| call { $$ = $1; }
// Error Handling
| DIV_OPEN_PAREN error DIV_CLOSE_PAREN { $$ = ERROR_VAL; yyerrok; }
| DIV_OPEN_BRACE error DIV_CLOSE_BRACE { $$ = ERROR_VAL; yyerrok; }
| DIV_OPEN_BRACKET error DIV_CLOSE_BRACKET { $$ = ERROR_VAL; yyerrok; }
;


// Statements
assignment
: KEY_ASSIGN ident_expr KEY_VALUE expression { $$ = new Assignment(unique_ptr<Expression>($2), unique_ptr<Expression>($4)); }
// Error Handling
| KEY_ASSIGN ident_expr KEY_VALUE error { $$ = new Assignment(unique_ptr<Expression>($2), unique_ptr<Expression>(ERROR_VAL)); yyerrok; }
| KEY_ASSIGN error KEY_VALUE expression { $$ = new Assignment(unique_ptr<Expression>(ERROR_VAL), unique_ptr<Expression>($4)); yyerrok; }
| KEY_ASSIGN error KEY_VALUE error { $$ = new Assignment(unique_ptr<Expression>(ERROR_VAL), unique_ptr<Expression>(ERROR_VAL)); yyerrok; }
;


if_statement
: KEY_IF expression procedure { $$ = new IfStatement(unique_ptr<Expression>($2), unique_ptr<Procedure>($3)); }
;


while_statement
: KEY_WHILE expression procedure { $$ = new WhileStatement(unique_ptr<Expression>($2), unique_ptr<Procedure>($3)); }
;


statement 
: DIV_TERMINATOR { $$ = nullptr; }
| expression DIV_TERMINATOR { $$ = $1; }
| term_decl DIV_TERMINATOR { $$ = $1; }
| function_decl { $$ = $1; }
//| function_decl DIV_TERMINATOR { $$ = $1; }
| assignment DIV_TERMINATOR { $$ = $1; }
| if_statement { $$ = $1; }
| while_statement { $$ = $1; }
// Error Handling
| error DIV_TERMINATOR { $$ = ERROR_VAL; yyerrok; }
;


procedure_rec 
: KEY_PROCEDURE { $$ = new Procedure(); }
| procedure_rec statement { $$->statements.emplace_back($2); }
;

procedure 
: procedure_rec KEY_END { $$ = $1; }
;


%%