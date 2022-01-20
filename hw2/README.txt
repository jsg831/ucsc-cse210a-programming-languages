# HW2 - WHILE

## Requirements
- flex (2.6.4) & bison (3.8.2): These two programs generate the tokenizer and the parser in C
  (Got it working in C++ too, but it's kinda unstable. If you have any problem
  running it, please send me a screenshot, and I'll figure what's the issue).
- g++ (11.1.0): It compiles C++ programs.

## How to Run
1. Run `make` to generate `while` executable
2. Run `./while` or `./test.sh` after merging with the test code

## Feature
- Array: `a[i] := a[i-1] + a[i-2]`
  - For simplicity, the intepreter uses a scalar variable named "`ID`[`EXPR`]"
    to represent an array element. The index is evaluated during runtime, which
    adds so much power to the language!

## Extra Credits
HW1 - Haskell
HW2 - Flex/Bison/C++
