#ifndef VERBOSE_AST_H
#define VERBOSE_AST_H

#include <ostream>
#include <string>
#include <memory>
#include <vector>

typedef std::string String;
typedef int Int;
typedef float Float;

#define ERROR_VAL nullptr

// Abstract Syntax Tree
namespace AST
{
#define DISP_ARGS std::ostream& o, uint tabs
    using std::unique_ptr;
    using std::vector;

    // Base classes
    class Node
    {
    public:
        const Node* parent = nullptr;

        virtual const char* nodeName() { return "Node"; }
        virtual void display(DISP_ARGS);

        virtual ~Node() = default;
    };

    class Statement : public Node
    {
    public:
        const char* nodeName() override { return "Statement"; }
        void display(DISP_ARGS) override;
    };

    class Expression : public Statement
    {
    public:
        const char* nodeName() override { return "Expression"; }
        void display(DISP_ARGS) override;
    };

    // Possibly temporary typedefs for nodes that might become derived classes
    typedef Expression Assignable;
    typedef Expression Type;

    // Literal Expressions
    class IntegerLiteral : public Expression
    {
    public:
        Int value;
        const char* nodeName() override { return "Integer Literal"; }
        void display(DISP_ARGS) override;
        IntegerLiteral(Int value) : value(value) {}
    };

    class FloatLiteral : public Expression
    {
    public:
        Float value;
        const char* nodeName() override { return "Float Literal"; }
        void display(DISP_ARGS) override;
        FloatLiteral(Float value) : value(value) {}
    };

    class StringLiteral : public Expression
    {
    public:
        String value;
        const char* nodeName() override { return "String Literal"; }
        void display(DISP_ARGS) override;
        StringLiteral(String value) : value(std::move(value)) {}
    };

    // Identifier
    class Identifier : public Expression
    {
    public:
        String name;
        const char* nodeName() override { return "Identifier"; }
        void display(DISP_ARGS) override;
        Identifier(String name) : name(std::move(name)) {}
    };

    // Call-related
    class CallArgs : public Node
    {
    public:
        vector<unique_ptr<Expression>> list;
        const char* nodeName() override { return "Call Arguments"; }
        void display(DISP_ARGS) override;
        CallArgs() = default;
    };

    class Call : public Expression
    {
    public:
        unique_ptr<Identifier> callable;
        unique_ptr<CallArgs> args = nullptr;
        const char* nodeName() override { return "Call"; }
        void display(DISP_ARGS) override;
        Call(unique_ptr<Identifier> callable, unique_ptr<CallArgs> args)
            : callable(std::move(callable)), args(std::move(args)) {}
        Call(unique_ptr<Identifier> callable)
            : callable(std::move(callable)) {}
    };

    // Operations
    class UnaryOperation : public Expression
    {
    public:
        enum Operator
        {
            NEGATIVE,
            NOT,
            PRE_INC,
            PRE_DEC,
            POST_INC,
            POST_DEC
        };
    public:
        Operator op;
        unique_ptr<Expression> expr;
        const char* nodeName() override { return "Unary Operator"; }
        void display(DISP_ARGS) override;
        UnaryOperation(unique_ptr <Expression> expr, Operator operand) : op(operand), expr(std::move(expr)) {}
    };

    class BinaryOperation : public Expression
    {
    public:
        enum Operator
        {
            PLUS, MINUS, MULTIPLY, DIVIDE, MODULO, POWER,
            EQUAL, NOT_EQUAL, LESS, GREATER, LESS_EQUAL, GREATER_EQUAL,
            AND, OR
        };
    public:
        Operator op;
        unique_ptr<Expression> left;
        unique_ptr<Expression> right;
        const char* nodeName() override { return "Binary Operator"; }
        void display(DISP_ARGS) override;
        BinaryOperation(unique_ptr <Expression> left, unique_ptr <Expression> right, Operator op)
            : op(op), left(std::move(left)), right(std::move(right)) {}
    };

    // Statements
    class TermDecl : public Statement
    {
    public:
        unique_ptr<Identifier> term_name;
        unique_ptr<Expression> type;
        unique_ptr<Expression> assigned_value = nullptr;
        bool is_const = false;
        const char* nodeName() override { return "Term Declaration"; }
        void display(DISP_ARGS) override;
        TermDecl(unique_ptr<Identifier> name, unique_ptr<Expression> type, unique_ptr<Expression> assigned_value, bool is_const)
            : term_name(std::move(name)), type(std::move(type)), assigned_value(std::move(assigned_value)), is_const(is_const) {}
        // Declaration without assignment, for non-const terms
        TermDecl(unique_ptr<Identifier> name, unique_ptr<Expression> type)
            : term_name(std::move(name)), type(std::move(type)) {}
    };

    class Assignment : public Statement
    {
    public:
        unique_ptr<Expression> term;
        unique_ptr<Expression> assigned_value;
        const char* nodeName() override { return "Assignment"; }
        void display(DISP_ARGS) override;
        Assignment(unique_ptr<Expression> term, unique_ptr<Expression> assigned_value)
            : term(std::move(term)), assigned_value(std::move(assigned_value)) {}
    };

    // Procedure-related
    class Procedure : public Statement
    {
    public:
        vector<unique_ptr<Statement>> statements;
        const char* nodeName() override { return "Procedure"; }
        void display(DISP_ARGS) override;
        Procedure() = default;
    };

    class ParamsDecl : public Node
    {
    public:
        vector<unique_ptr<TermDecl>> list;
        const char* nodeName() override { return "Parameter Declaration"; }
        void display(DISP_ARGS) override;
        ParamsDecl() = default;
    };

    class FunctionDecl : public Statement
    {
    public:
        unique_ptr<Identifier> func_name = nullptr;
        unique_ptr<Expression> return_type = nullptr;
        unique_ptr<ParamsDecl> params = nullptr;
        unique_ptr<Procedure> procedure = nullptr;

        const char* nodeName() override { return "Function Declaration"; }

        void display(DISP_ARGS) override;

        FunctionDecl(unique_ptr<Identifier> name, unique_ptr<ParamsDecl> params, unique_ptr<Procedure> procedure)
            : func_name(std::move(name)), params(std::move(params)), procedure(std::move(procedure)) {}
        FunctionDecl() = default;
        ~FunctionDecl() override = default;
    };

    // If specific utility classes
    class AbstractElse : public Node
    {
    public:
        const char* nodeName() override = 0;
        void display(DISP_ARGS) override = 0;
    };

    class IfStatement : public Statement
    {
    public:
        unique_ptr<Expression> condition;
        unique_ptr<Procedure> procedure;
        unique_ptr<AbstractElse> else_node = nullptr;
        const char* nodeName() override { return "If statement"; }
        void display(DISP_ARGS) override;
        IfStatement(unique_ptr<Expression> condition, unique_ptr<Procedure> procedure)
            : condition(std::move(condition)), procedure(std::move(procedure)) {}
        IfStatement(unique_ptr<Expression> condition, unique_ptr<Procedure> procedure, unique_ptr<AbstractElse> else_node)
            : condition(std::move(condition)), procedure(std::move(procedure)), else_node(std::move(else_node)) {}

    };

    class Else : public AbstractElse
    {
    public:
        unique_ptr<Procedure> procedure;
        const char* nodeName() override { return "Else"; }
        void display(DISP_ARGS) override;
        Else(unique_ptr<Procedure> procedure) : procedure(std::move(procedure)) {}
    };

    class ElseIf : public AbstractElse
    {
    public:
        unique_ptr<IfStatement> if_statement;
        const char* nodeName() override { return "Else If"; }
        void display(DISP_ARGS) override;
        ElseIf(unique_ptr<IfStatement> if_statement) : if_statement(std::move(if_statement)) {}
    };


    class WhileStatement : public Statement
    {
    public:
        unique_ptr<Expression> condition;
        unique_ptr<Procedure> procedure;
        const char* nodeName() override { return "While statement"; }
        void display(DISP_ARGS) override;
        WhileStatement(unique_ptr<Expression> condition, unique_ptr<Procedure> procedure)
            : condition(std::move(condition)), procedure(std::move(procedure)) {}
    };

    class Program : public Node
    {
    public:
        vector<unique_ptr<Statement>> statements;
        const char* nodeName() override { return "Program"; }
        void display(DISP_ARGS) override;
        Program() = default;
    };
}

#endif //VERBOSE_AST_H