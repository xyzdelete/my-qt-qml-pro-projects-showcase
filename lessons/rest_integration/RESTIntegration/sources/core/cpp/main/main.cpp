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

  QQmlApplicationEngine engine;

  QObject::connect(
    &engine,
    &QQmlApplicationEngine::objectCreationFailed,
    &app,
    []()
    {
      QCoreApplication::exit(-1);
    },
    Qt::QueuedConnection);
  QStringList paths = engine.importPathList();
  paths << ":/RESTIntegration";
  paths.removeDuplicates();
  engine.setImportPathList(paths);
  QQuickStyle::setStyle("Material");
  engine.loadFromModule("RESTIntegration", "Main");

  AppWrapper wrapper;

  if (!wrapper.initialize(&app, &engine))
  {
    return -1;
  }

  return app.exec();
}
