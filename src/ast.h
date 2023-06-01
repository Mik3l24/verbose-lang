#ifndef VERBOSE_AST_H
#define VERBOSE_AST_H

#include <ostream>
#include <string>
#include <memory>
#include <vector>
#include "operators.h"

typedef std::string String;
typedef int Int;
typedef float Float;


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
        virtual const char* nodeName() { return "Node"; }
        virtual void display(DISP_ARGS);

    public:
        virtual ~Node() = default;
    };

    class Expression : public Node
    {
    public:
        const char* nodeName() override { return "Expression"; }
        void display(DISP_ARGS) override;
    };

    class Statement : public Node
    {
    public:
        const char* nodeName() override { return "Statement"; }
        void display(DISP_ARGS) override;
    };

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
        Operator op;
        unique_ptr<Expression> expr;
        const char* nodeName() override { return "Unary Operator"; }
        void display(DISP_ARGS) override;
        UnaryOperation(Operator operand, unique_ptr<Expression> expr) : op(operand), expr(std::move(expr)) {}
    };

    class BinaryOperation : public Expression
    {
    public:
        Operator op;
        unique_ptr<Expression> left;
        unique_ptr<Expression> right;
        const char* nodeName() override { return "Binary Operator"; }
        void display(DISP_ARGS) override;
        BinaryOperation(Operator op, unique_ptr<Expression> left, unique_ptr<Expression> right)
            : op(op), left(std::move(left)), right(std::move(right)) {}
    };

    // Procedure-related
    class Procedure : public Expression
    {

    };

    class ParamsDecl : public Node
    {

    };

    class FunctionDecl : public Statement
    {
    public:
        String func_name;
        unique_ptr<ParamsDecl> params = nullptr;
        unique_ptr<Procedure> procedure = nullptr;

        const char* nodeName() override { return "Function Declaration"; }

        void display(DISP_ARGS) override;

        FunctionDecl(String name, unique_ptr<ParamsDecl> params, unique_ptr<Procedure> procedure);
        ~FunctionDecl() override = default;
    };
}

#endif //VERBOSE_AST_H