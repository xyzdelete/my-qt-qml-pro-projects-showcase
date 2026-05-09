import CppWorkerModule;

#include "cppsignalsender.hpp"
#include "cppworker.hpp"
#include "movie.hpp"
#include "propertywrapper.hpp"

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
  PropertyWrapper wrapper;
  Movie movie;
  movie.setTitle("Titanic");
  movie.setMainCharacter("Leonardo D");

  QString lastName = "Doe";
  QString firstName = "John";
  wrapper.setLastname(lastName);
  wrapper.setFirstname(firstName);

  QQmlApplicationEngine engine;

  engine.rootContext()->setContextProperty("BWorker", &cppworker);
  engine.rootContext()->setContextProperty("CppSignalSender", &sender);
  engine.rootContext()->setContextProperty("Movie", &movie);

  engine.rootContext()->setContextObject(&wrapper);
  // engine.rootContext()->setContextProperty(
  //   "lastname",
  //   QVariant::fromValue(lastName));
  // engine.rootContext()->setContextProperty(
  //   "firstname",
  //   QVariant::fromValue(firstName));

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
  paths << ":/InterfacingCppToQML" << ":/ContextObjects"
        << ":/ContextProperties" << ":/QPROPERTYMapping"
        << ":/SignalsFromTheCppSide" << ":/TheConnections";
  paths.removeDuplicates();
  engine.setImportPathList(paths);
  QQuickStyle::setStyle("Material");
  engine.loadFromModule("InterfacingCppToQML", "Main");

  return app.exec();
}
