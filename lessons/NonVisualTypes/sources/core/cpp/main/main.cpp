import CppWorkerModule;

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QQuickWindow>

int main(int argc, char* argv[])
{
  QGuiApplication app(argc, argv);
  app.setOrganizationDomain("github.com/xyzdelete");
  app.setOrganizationName("xyzdelete");
  app.setApplicationName("NonVisualTypes");

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
  paths << ":/NonVisualTypes";
  paths.removeDuplicates();
  engine.setImportPathList(paths);
  QQuickStyle::setStyle("Material");
  engine.loadFromModule("NonVisualTypes", "Main");

  return app.exec();
}
