#include "appwrapper.hpp"

#include <QGuiApplication>
#include <QQuickStyle>

import StaticLibModuleExample;
import ModuleExample;

int
main(int argc, char* argv[])
{
  QGuiApplication app{argc, argv};
  QQuickStyle::setStyle("Material");
  StaticLibModuleExample::hello_world();
  ModuleExample::hello_world();

  AppWrapper wrapper;

  wrapper.initialize(&app);

  return app.exec();
}