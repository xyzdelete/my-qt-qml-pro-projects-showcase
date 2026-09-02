module;

export module CppWorkerModule;

import std;

export namespace CppWorkerModule
{
  void hello_world()
  {
    std::cout << "Hello World from CppWorkerModule!" << std::endl;
  }
}  // namespace CppWorkerModule