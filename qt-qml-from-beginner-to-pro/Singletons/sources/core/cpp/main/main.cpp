import CppWorkerModule;

#include "singletonclass.hpp"
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QQuickWindow>

int
main(int argc, char* argv[])
{
  QGuiApplication app(argc, argv);
  app.setOrganizationDomain("github.com/xyzdelete");
  app.setOrganizationName("xyzdelete");
  app.setApplicationName("Singletons");

  CppWorkerModule::hello_world();

  /*
  qmlRegisterSingletonType<SingletonClass>("QObject", 1, 0,
  "MyApi", SingletonClass::singletonProvider);
  */

  /*
  qmlRegisterSingletonType<SingletonClass>("QObject", 1, 0,
  "MyApi",
                                           [](QQmlEngine *engine, QJSEngine
  *scriptEngine)->QObject *{ Q_UNUSED(engine) Q_UNUSED(scriptEngine)

                                               SingletonClass * example = new
  SingletonClass(); return example;
                                           });
  */

  QQmlApplicationEngine engine;

  QObject::connect(
    &engine,
    &QQmlApplicationEngine::objectCreationFailed,
    &app,
    []()
    {
      QCoreApplication::exit(-1);
    },
    Qt::QueuedConnection
  );
  QStringList paths = engine.importPathList();
  paths << ":/Singletons";
  paths.removeDuplicates();
  engine.setImportPathList(paths);
  QQuickStyle::setStyle("Material");
  engine.loadFromModule("Singletons", "Main");

  return app.exec();
}