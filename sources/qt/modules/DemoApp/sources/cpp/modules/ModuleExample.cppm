module;

// Global module fragment: only preprocessor directives.
#if !defined(_WIN32)
#include <iostream>
#include <memory>
#include <string>
#include <vector>
#endif

export module ModuleExample;

// Module purview: preprocessor directives + normal C++
// declarations/imports/etc.
#if defined(_WIN32)
import std;
#endif

export namespace ModuleExample
{
void
hello_world()
{
  std::cout << "Hello World from ModuleExample!" << std::endl;
}
} // namespace ModuleExample