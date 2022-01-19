%{

#include <iostream>
#include <string>
#include <unordered_map>

extern char *yytext;

int yylex();
void yyerror(const char *s);

enum Operator {
  Plus,
  Minus,
  Multiply,
  Equal,
  LessThan,
  Not,
  And,
  Or
};

std::unordered_map<Operator, std::string> op_literal = 
{
  { Plus     , "+" },
  { Minus    , "-" },
  { Multiply , "*" },
  { Equal    , "=" },
  { LessThan , "<" },
  { Not      , "¬" },
  { And      , "∧" },
  { Or       , "∨" }
};

struct Expr {
  public:
    virtual void print() {} 
};

struct Num : public Expr {
  public:
    Num(int num) : value(num) {}
    int value;
    void print() { std::cout << value; }
};

struct Bool : public Expr {
  public:
    Bool(bool b) : value(b) {}
    bool value;
    void print() { std::cout << (value ? "true" : "false"); }
};

struct Identifier : public Expr {
  public:
    Identifier(char *text) { this->name = text; }
    std::string name;
    void print() { std::cout << name; }
};

struct BinaryExpr : public Expr {
  public:
    BinaryExpr(Expr *l, Expr *r, Operator op) : left(l), right(r), op(op) {}
    Expr *left;
    Expr *right;
    Operator op;
    void print() {
      std::cout << "(";
      left->print();
      std::cout << op_literal[op];
      right->print();
      std::cout << ")";
    }
};

struct UnaryExpr : public Expr {
  public:
    UnaryExpr(Expr *e, Operator op) : expr(e), op(op) {}
    Expr *expr;
    Operator op;
    void print() {
      std::cout << "(";
      std::cout << op_literal[op];
      expr->print();
      std::cout << ")";
    }
};

struct Cmd {
  public:
    virtual void print() {}
};

struct CmdComposite : public Cmd {
  public:
    CmdComposite(Cmd *l, Cmd *r) : left(l), right(r) {}
    Cmd *left;
    Cmd *right;
    void print() {
      std::cout << "{";
      left->print();
      std::cout << ";";
      right->print();
      std::cout << "}";
    }
};

struct CmdSkip : public Cmd {
  public:
    CmdSkip() {}
    void print() {
      std::cout << "skip";
    }
};

struct CmdAssign : public Cmd {
  public:
    CmdAssign(char *id_name, Expr *expr) : expr(expr) {
      id = new Identifier(id_name);
    }
    Identifier *id;
    Expr *expr;
    void print() {
      id->print();
      std::cout << ":=";
      expr->print();
    }
};

struct CmdIf : public Cmd {
  public:
    CmdIf(Expr *cond, Cmd *first, Cmd *second) : cond(cond), first(first), second(second) {}
    Expr *cond;
    Cmd *first;
    Cmd *second;
    void print() {
      std::cout << " if ";
      cond->print();
      std::cout << " then ";
      first->print();
      std::cout << " else ";
      second->print();
    }
};

struct CmdWhile : public Cmd {
  public:
    CmdWhile(Expr *cond, Cmd *cmd) : cond(cond), cmd(cmd) {}
    Expr *cond;
    Cmd *cmd;
    void print() {
      std::cout << " while ";
      cond->print();
      std::cout << " do ";
      cmd->print();
    }
};


%}

%token SEMICOLON
%token NUM
%token TRUE FALSE
%token ID
%token EQ LT NOT AND OR
%token PLUS MINUS MULT
%token LBRACE RBRACE
%token LPAREN RPAREN
%token SKIP
%token ASSIGN
%token IF ELSE THEN
%token WHILE DO

%union {
  struct Cmd *cmd;
  struct Expr *expr;
  char *text;
  int value;
}

%type <cmd> program cmd block
%type <expr> aexp bexp
%type <value> NUM
%type <text> ID

%left PLUS MINUS
%left MULT

%left OR
%left AND
%right NOT

%left SEMICOLON

%start program
%%

program : block
        { $1->print(); std::cout << std::endl; }
        |
        { $$ = nullptr; }

cmd : LBRACE block RBRACE
        { $$ = $2; }
    | SKIP
        { $$ = new CmdSkip(); }
    | ID ASSIGN aexp
        { $$ = new CmdAssign($1, $3); }
    | IF bexp THEN cmd ELSE cmd
        { $$ = new CmdIf($2, $4, $6); }
    | WHILE bexp DO cmd
        { $$ = new CmdWhile($2, $4); }

block : cmd
        { $$ = $1; }
      | cmd SEMICOLON block
        { $$ = new CmdComposite($1, $3); }

bexp : LPAREN bexp RPAREN
        { $$ = $2; }
     | aexp EQ aexp
        { $$ = new BinaryExpr($1, $3, Equal); }
     | aexp LT aexp
        { $$ = new BinaryExpr($1, $3, LessThan); }
     | NOT bexp
        { $$ = new UnaryExpr($2, Not); }
     | bexp AND bexp
        { $$ = new BinaryExpr($1, $3, And); }
     | bexp OR bexp
        { $$ = new BinaryExpr($1, $3, Or); }
     | TRUE
        { $$ = new Bool(true); }
     | FALSE
        { $$ = new Bool(false); }

aexp : LPAREN aexp RPAREN
        { $$ = $2; }
     | aexp PLUS aexp
        { $$ = new BinaryExpr($1, $3, Plus); }
     | aexp MINUS aexp
        { $$ = new BinaryExpr($1, $3, Minus); }
     | aexp MULT aexp
        { $$ = new BinaryExpr($1, $3, Multiply); }
     | NUM
        { $$ = new Num($1); } 
     | ID
        { $$ = new Identifier($1); }

%%

void yyerror(const char *s) {
  std::cout << "Error: " << s << std::endl;
}

