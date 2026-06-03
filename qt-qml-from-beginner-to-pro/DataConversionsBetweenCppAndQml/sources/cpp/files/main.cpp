import CppWorkerModule;

#include "cppclass.hpp"

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

  QQmlApplicationEngine engine;

  CppWorkerModule::hello_world();

  CppClass cppclass;
  engine.rootContext()->setContextProperty("CppClass", &cppclass);

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
  paths << ":/DataConversionsBetweenCppAndQml";
  paths.removeDuplicates();
  engine.setImportPathList(paths);
  QQuickStyle::setStyle("Material");
  engine.loadFromModule("DataConversionsBetweenCppAndQml", "Main");

  if (engine.rootObjects().isEmpty())
  {
    return -1;
  }
  else
  {
    cppclass.setQmlRootObject(engine.rootObjects().first());
  }

  return app.exec();
}
