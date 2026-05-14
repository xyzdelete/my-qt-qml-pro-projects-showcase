import CppWorkerModule;

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

  return app.exec();
}
