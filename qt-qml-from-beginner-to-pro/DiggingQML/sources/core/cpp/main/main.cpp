import CppWorkerModule;

#include "appwrapper.hpp"
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlProperty>
#include <QQuickItem>
#include <QQuickStyle>
#include <QQuickView>
#include <QQuickWindow>

int
main(int argc, char* argv[])
{
  QGuiApplication app(argc, argv);
  QQuickStyle::setStyle("Material");

  CppWorkerModule::hello_world();

  AppWrapper wrapper;

  if (!wrapper.initialize(&app))
  {
    return -1;
  }

  return app.exec();
}