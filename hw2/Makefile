LEX  := flex
YACC := bison
CC := g++

SRC_LEX := lexer.l
SRC_YACC := parser.y
SRC := main.cpp

BIN := while

all: $(BIN)

lex.yy.c: $(SRC_LEX)
	$(LEX) $(SRC_LEX)

parser.tab.c: $(SRC_YACC)
	$(YACC) -d -Wcounterexamples $(SRC_YACC)

$(BIN): lex.yy.c parser.tab.c $(SRC)
	$(CC) -o $(BIN) $(SRC) lex.yy.c parser.tab.c

.PHONY: clean

clean:
	rm -f $(BIN) lex.yy.c *.tab.c *.tab.h *.output

