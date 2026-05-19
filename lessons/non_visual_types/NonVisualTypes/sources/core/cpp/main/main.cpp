import CppWorkerModule;

#include "appwrapper.hpp"
// #include "errorlevel.hpp"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QQuickWindow>
#include <algorithm>

int main(int argc, char* argv[])
{
  QGuiApplication app(argc, argv);
  app.setOrganizationDomain("github.com/xyzdelete");
  app.setOrganizationName("xyzdelete");
  app.setApplicationName("NonVisualTypes");

  CppWorkerModule::hello_world();

  QQmlApplicationEngine engine;

  // qmlRegisterUncreatableType<ErrorLevel>(
  //   "Enums",
  //   1,
  //   0,
  //   "ErrorLevel",
  //   "Can not create ErrorLevel type in QML. Not allowed.");

  // If you want to instantiate ErrorLevel in QML:
  // qmlRegisterType<ErrorLevel>("Enums", 1, 0, "ErrorLevel");

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
  paths << ":/NonVisualTypes";
  paths.removeDuplicates();
  engine.setImportPathList(paths);
  QQuickStyle::setStyle("Material");
  engine.loadFromModule("NonVisualTypes", "Main");

  return app.exec();
}
