import CppWorkerModule;

#include "appwrapper.hpp"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QQuickWindow>

int
main(int argc, char* argv[])
{
  QGuiApplication app(argc, argv);
  QQuickStyle::setStyle("Material");
  CppWorkerModule::hello_world();

  AppWrapper wrapper;

  wrapper.initialize(&app);

  return app.exec();
}