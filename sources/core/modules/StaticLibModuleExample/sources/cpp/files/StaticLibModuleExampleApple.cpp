#include "StaticLibModuleExampleApple.hpp"

#if defined(__APPLE__)

#include <iostream>

namespace StaticLibModuleExample
{
void
hello_world()
{
  std::cout << "Hello World from StaticLibModuleExample!" << std::endl;
}
} // namespace StaticLibModuleExample

#endif // defined(__APPLE__)
