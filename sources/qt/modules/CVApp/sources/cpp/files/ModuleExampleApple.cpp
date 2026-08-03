#include "ModuleExampleApple.hpp"

#if defined(__APPLE__)

#include <iostream>

namespace ModuleExample
{
void
hello_world()
{
  std::cout << "Hello World from ModuleExample!" << std::endl;
}
} // namespace ModuleExample

#endif // defined(__APPLE__)
