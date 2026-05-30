import CppWorkerModule;

#include "footballteam.hpp"
#include "player.hpp"
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlProperty>
#include <QQuickStyle>
#include <QQuickWindow>

int
main(int argc, char* argv[])
{
  QGuiApplication app(argc, argv);
  QQuickStyle::setStyle("Material");
  app.setOrganizationDomain("github.com/xyzdelete");
  app.setOrganizationName("xyzdelete");
  app.setApplicationName("DiggingQML");

  CppWorkerModule::hello_world();

  QQmlApplicationEngine engine;

  // Register Types
  qmlRegisterType<Player>("ParseCustomQmlType", 1, 0, "Player");
  qmlRegisterType<FootBallTeam>("ParseCustomQmlType", 1, 0, "FootballTeam");

  QQmlComponent component(
    &engine,
    ":/DiggingQML/ParseCustomQmlType/sources/qml/files/"
    "ParseCustomQmlType.qml"
  );

  FootBallTeam* team = qobject_cast<FootBallTeam*>(
    component.create()
  ); // FootBallTeam is the root element in the QML file

  if (team && team->captain())
  {
    qDebug() << "Team : " << team->title()
             << " , captain is : " << team->captain()->name();
    qDebug() << "The players are : ";

    for (int i = 0; i < team->playerCountCustom(); i++)
    {
      qDebug() << " " << team->playerCustom(i)->name();
    }
  }

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
  paths << ":/DiggingQML";
  paths.removeDuplicates();
  engine.setImportPathList(paths);

  engine.loadFromModule("DiggingQML", "Main");

  return app.exec();
}