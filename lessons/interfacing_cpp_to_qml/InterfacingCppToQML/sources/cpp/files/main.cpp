#include "cppsignalsender.hpp"
#include "cppworker.hpp"
#include "movie.hpp"

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
  CppSignalSender sender;
  Movie movie;
  movie.setTitle("Titanic");
  movie.setMainCharacter("Leonardo D");

  QQmlApplicationEngine engine;

  engine.rootContext()->setContextProperty("BWorker", &cppworker);
  engine.rootContext()->setContextProperty("CppSignalSender", &sender);
  engine.rootContext()->setContextProperty("Movie", &movie);

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
