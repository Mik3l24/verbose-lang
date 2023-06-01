#ifndef VERBOSE_AST_H
#define VERBOSE_AST_H

#include <ostream>
#include <string>
#include <memory>

typedef std::string String;


// Abstract Syntax Tree
namespace AST
{
#define DISP_ARGS std::ostream& o, uint tabs
    using std::unique_ptr;

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
        unique_ptr<ParamsDecl> params = nullptr;
        unique_ptr<Procedure> procedure = nullptr;

        const char* nodeName() override { return "Function Declaration"; }

        void display(DISP_ARGS) override;

        FunctionDecl(String name, unique_ptr<ParamsDecl> params, unique_ptr<Procedure> procedure);
        ~FunctionDecl() override = default;
    };
}

#endif //VERBOSE_AST_H