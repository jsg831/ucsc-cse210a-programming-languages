#include <cstdlib>
#include <string>
#include <iostream>

extern void yy_scan_string(const char*);
extern int yyparse();

int main() {
  std::string line;
  while (std::getline(std::cin, line)) {
    yy_scan_string(line.c_str());
    yyparse();
  }
  return 0;
}
