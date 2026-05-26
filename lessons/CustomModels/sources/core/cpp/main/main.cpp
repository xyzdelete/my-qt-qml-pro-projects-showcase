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

  QStringList continentList;
  continentList.append("Africa");
  continentList.append("Europe");
  continentList.append("America");
  continentList.append("Asia");
  continentList.append("Oceania");
  continentList.append("Antarctica");

  QQmlApplicationEngine engine;

  engine.rootContext()->setContextProperty("continentModel", continentList);
  engine.rootContext()->setContextProperties(
    QList<QQmlContext::PropertyPair>{
      {"itemList1", QStringList{"List1Item1", "List1Item2", "List1Item3"}},
      {"itemList2", QStringList{"List2Item1", "List2Item2", "List2Item3"}}});

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
  paths << ":/CustomModels";
  paths.removeDuplicates();
  engine.setImportPathList(paths);
  QQuickStyle::setStyle("Material");
  engine.loadFromModule("CustomModels", "Main");

  return app.exec();
}
