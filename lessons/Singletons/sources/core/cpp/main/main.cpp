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

  qmlRegisterSingletonType(
    "QJsValue", 1, 0, "MyApi", SingletonClass::singletonProvider
  );

  // qmlRegisterSingletonType(
  //   "QJsValue",
  //   1,
  //   0,
  //   "MyApi", // It's important that MyApi here starts with upppercase,
  //   otherwise
  //            // you'll get errors.
  //   [](QQmlEngine* engine, QJSEngine* scriptEngine) -> QJSValue
  //   {
  //     Q_UNUSED(scriptEngine)
  //     int mValue = 5;
  //
  //     QJSValue jsValue = engine->newObject();
  //     jsValue.setProperty("someProperty", mValue);
  //
  //     // Put in an array
  //     QJSValue mArray = engine->newArray(3);
  //     for (unsigned int i = 1; i <= 3; ++i)
  //     {
  //       mArray.setProperty(i, i * 5);
  //     }
  //
  //     jsValue.setProperty("mArray", mArray);
  //
  //     return jsValue;
  //   }
  // );

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