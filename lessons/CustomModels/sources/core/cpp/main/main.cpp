import CppWorkerModule;

#include "person.hpp"

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

  QList<QObject*> personList;
  personList.append(new Person("John Doe C++", "green", 32, &engine));
  personList.append(new Person("Mary Green", "blue", 23, &engine));
  personList.append(new Person("Mitch Nathson", "dodgerblue", 30, &engine));
  personList.append(new Person("Daniel Sten", "red", 67, &engine));
  personList.append(new Person("John Doe C++", "green", 32, &engine));
  personList.append(new Person("Mary Green", "blue", 23, &engine));
  personList.append(new Person("Mitch Nathson", "dodgerblue", 30, &engine));
  personList.append(new Person("Daniel Sten", "red", 67, &engine));
  personList.append(new Person("John Doe C++", "green", 32, &engine));
  personList.append(new Person("Mary Green", "blue", 23, &engine));
  personList.append(new Person("Mitch Nathson", "dodgerblue", 30, &engine));
  personList.append(new Person("Daniel Sten", "red", 67, &engine));
  personList.append(new Person("John Doe C++", "green", 32, &engine));
  personList.append(new Person("Mary Green", "blue", 23, &engine));
  personList.append(new Person("Mitch Nathson", "dodgerblue", 30, &engine));
  personList.append(new Person("Daniel Sten", "red", 67, &engine));

  // Expose the list as a context property
  engine.rootContext()->setContextProperty(
    "personModel",
    QVariant::fromValue(personList));

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
