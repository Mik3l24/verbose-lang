#ifndef VERBOSE_AST_H
#define VERBOSE_AST_H

#include <ostream>
#include <string>

typedef std::string String;
#define DISP_ARGS std::ostream& o, uint tabs

// Abstract Syntax Tree
namespace AST
{
    class Node
    {
    public:
        virtual const char* nodeName() { return "Node"; }
        virtual void display(DISP_ARGS);


        virtual ~Node() = default;
    };

    class Decl : public Node
    {

    };

    class Procedure : public Node
    {

    };

    class ParamsDecl : public Node
    {

    };

    class FunctionDecl : public Decl
    {
    public:
        String func_name;
        ParamsDecl* params;
        Procedure* procedure;

        virtual const char* nodeName() { return "Function Declaration"; }
        virtual void display(DISP_ARGS) override;

        FunctionDecl(String name, ParamsDecl* params, Procedure* procedure);
        ~FunctionDecl() override;
    };
}

#endif //VERBOSE_AST_H