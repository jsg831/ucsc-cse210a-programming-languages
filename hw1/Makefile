BIN := arith

all: $(BIN)

arith: arith.hs
	ghc -dynamic arith.hs -o $(BIN)

.PHONY: clean

clean:
	rm -f $(BIN) *.hi *.o
