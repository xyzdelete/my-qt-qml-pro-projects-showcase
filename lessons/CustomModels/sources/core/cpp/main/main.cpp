import CppWorkerModule;

#include "objectlistwrapper.hpp"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QQuickWindow>

int main(int argc, char* argv[])
{
  QGuiApplication app(argc, argv);
  QQuickStyle::setStyle("Material");
  CppWorkerModule::hello_world();

  ObjectListWrapper wrapper;

  if (!wrapper.initialize(&app))
  {
    return -1;
  }

  return app.exec();
}
