#include "cppworker.hpp"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>

int main(int argc, char* argv[])
{
  QGuiApplication app(argc, argv);
  app.setOrganizationName("xyzdelete");
  app.setOrganizationDomain("github.com/xyzdelete");
  app.setApplicationName("Showcase");

  // Create the object on the C++ side
  CppWorker cppworker;

  QQmlApplicationEngine engine;

  engine.rootContext()->setContextProperty("BWorker", &cppworker);

  QObject::connect(
    &engine,
    &QQmlApplicationEngine::objectCreationFailed,
    &app,
    []()
    {
      QCoreApplication::exit(-1);
    },
    Qt::QueuedConnection);
  engine.addImportPath(":/qt/qml");
  QQuickStyle::setStyle("Material");
  engine.loadFromModule("InterfacingCppToQML", "Main");

  return app.exec();
}
