module;

// Global module fragment: only preprocessor directives.
#if !defined(_WIN32)
#include <iostream>
#include <memory>
#include <string>
#include <vector>
#endif

export module StaticLibModuleExample;

// Module purview: preprocessor directives + normal C++
// declarations/imports/etc.
#if defined(_WIN32)
import std;
#endif

export namespace StaticLibModuleExample
{
void
hello_world()
{
  std::cout << "Hello World from StaticLibModuleExample!" << std::endl;
}
} // namespace StaticLibModuleExample