%{
  #include <stdio.h>
  #include "string.h"
  #include "parser.tab.h"
%}

%%

";"      { return SEMICOLON; }

"-"      { return MINUS; }
"+"      { return PLUS; }
"*"      { return MULT; }
"="      { return EQ; }
"¬"      { return NOT; }
"<"      { return LT; }
"∧"      { return AND; }
"∨"      { return OR; }
":="     { return ASSIGN; }
"{"      { return LBRACE; }
"}"      { return RBRACE; }
"("      { return LPAREN; }
")"      { return RPAREN; }
-?[0-9]+ { yylval.value = atoi(yytext); return NUM; }

"skip"   { return SKIP; }
"if"     { return IF; }
"else"   { return ELSE; }
"then"   { return THEN; }
"while"  { return WHILE; }
"do"     { return DO; }
"true"   { return TRUE; }
"false"  { return FALSE; }

[a-zA-Z_][a-zA-Z0-9_]* { yylval.text = strdup(yytext); return ID; }

.|\n {}

%%

int yywrap() { return 1; }
