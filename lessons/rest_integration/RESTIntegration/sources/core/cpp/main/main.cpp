import CppWorkerModule;

#include "appwrapper.hpp"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QQuickWindow>
#include <algorithm>

int main(int argc, char* argv[])
{
  QGuiApplication app(argc, argv);
  app.setOrganizationName("xyzdelete");
  app.setOrganizationDomain("github.com/xyzdelete");
  app.setApplicationName("Showcase");

  CppWorkerModule::hello_world();

  AppWrapper wrapper;
  if (!wrapper.initialize(&app))
  {
    return -1;
  }

  return app.exec();
}
