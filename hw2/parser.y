%{

#include <iostream>
#include <map>
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

struct State {
  protected:
    std::unordered_map<std::string, int> memory;
  public:
    void print() {
      std::map<std::string, int> key_val(memory.begin(), memory.end());
      std::cout << "{";
      for (auto it = key_val.begin(); it != key_val.end(); it++) {
        if (it != key_val.begin()) std::cout << ", ";
        std::cout << it->first << " → " << it->second;
      }
      std::cout << "}" << std::endl;
    }
    void set(std::string name, int value) { memory[name] = value; }
    int get(std::string name) {
      if (memory.count(name))
        return memory[name];
      return 0;
    }
};

struct Expr {
  public:
    virtual void print() = 0;
    virtual int eval(State*) = 0;
};

struct Num : public Expr {
  public:
    Num(int num) : value(num) {}
    int value;
    void print() { std::cout << value; }
    int eval(State *state) { return value; }
};

struct Bool : public Expr {
  public:
    Bool(bool b) : value(b) {}
    bool value;
    void print() { std::cout << (value ? "true" : "false"); }
    int eval(State *state) { return (int)value; }
};

struct Variable : public Expr {
  public:
    virtual void set(State* state, int value) = 0;
};

struct Identifier : public Variable {
  public:
    Identifier(char *text) { this->name = text; }
    std::string name;
    void print() { std::cout << name; }
    int eval(State *state) { return state->get(name); }
    void set(State *state, int value) { state->set(name, value); }
};

struct Array : public Variable {
  public:
    Array(std::string name, Expr *expr) : name(name), expr(expr) {}
    std::string name;
    Expr *expr;
    void print() {
      std::cout << name;
      std::cout << "[";
      expr->print();
      std::cout << "]";
    }
    int eval(State *state) {
      std::string index = std::to_string(expr->eval(state));
      return state->get(name + "[" + index + "]");
    }
    void set(State *state, int value) {
      std::string index = std::to_string(expr->eval(state));
      state->set(name + "[" + index + "]", value);
    }
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
    int eval(State *state) {
      switch (op) {
        case Plus:
          return left->eval(state) + right->eval(state);
        case Minus:
          return left->eval(state) - right->eval(state);
        case Multiply:
          return left->eval(state) * right->eval(state);
        // NOTE: Bool is converted to Integer
        //       true -> 1 / false -> 0
        case Equal:
          return (int)(left->eval(state) == right->eval(state));
        case LessThan:
          return (int)(left->eval(state) < right->eval(state));
        case And:
          return (int)(left->eval(state) && right->eval(state));
        case Or:
          return (int)(left->eval(state) || right->eval(state));
        default:
          exit(1);
      }
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
    int eval(State *state) {
      switch (op) {
        case Not:
          return !(expr->eval(state));
        default:
          exit(1);
      }
    }
};

struct Cmd {
  public:
    virtual void print() = 0;
    virtual void eval(State*) = 0;
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
    void eval(State *state) {
      left->eval(state);
      right->eval(state);
    }
};

struct CmdSkip : public Cmd {
  public:
    CmdSkip() {}
    void print() {
      std::cout << "skip";
    }
    void eval(State *state) {
      // None
    }
};

struct CmdAssign : public Cmd {
  public:
    CmdAssign(Variable *variable, Expr *expr) : variable(variable), expr(expr) {}
    Variable *variable;
    Expr *expr;
    void print() {
      variable->print();
      std::cout << ":=";
      expr->print();
    }
    void eval(State *state) {
      variable->set(state, expr->eval(state));
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
    void eval(State *state) {
      if (cond->eval(state)) {
        first->eval(state);
      } else {
        second->eval(state);
      }
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
    void eval(State *state) {
      while (cond->eval(state)) {
        cmd->eval(state);
      }
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
%token LBRACK RBRACK
%token LPAREN RPAREN
%token SKIP
%token ASSIGN
%token IF ELSE THEN
%token WHILE DO

%union {
  struct State *state;
  struct Cmd *cmd;
  struct Variable *variable;
  struct Expr *expr;
  char *text;
  int value;
}

%type <state> program
%type <cmd> cmd block
%type <variable> variable
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
        {
          $$ = new State();
          $1->eval($$);
          $$->print();
        }
        |
        { $$ = nullptr; }

cmd : LBRACE block RBRACE
        { $$ = $2; }
    | SKIP
        { $$ = new CmdSkip(); }
    | variable ASSIGN aexp
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
     | MINUS NUM
        { $$ = new Num(-$2); }
     | NUM
        { $$ = new Num($1); } 
     | variable
        { $$ = $1; }

variable : ID
        { $$ = new Identifier($1); }
         | ID LBRACK aexp RBRACK
        { $$ = new Array($1, $3); }

%%

void yyerror(const char *s) {
  std::cout << "Error: " << s << std::endl;
}

