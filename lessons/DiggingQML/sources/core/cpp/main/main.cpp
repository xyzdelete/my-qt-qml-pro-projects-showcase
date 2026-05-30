import CppWorkerModule;

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlProperty>
#include <QQuickItem>
#include <QQuickStyle>
#include <QQuickView>
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

  QObject* rootObject = engine.rootObjects()[0];

  QObject* funcContext = rootObject->findChild<QObject*>("deep2");

  if (funcContext)
  {
    qDebug() << "Found the object";
    QVariant returnValue;
    QVariant parameter = "C++ Parameter";

    QMetaObject::invokeMethod(
      funcContext,
      "qmlFunction",
      Q_RETURN_ARG(QVariant, returnValue),
      Q_ARG(QVariant, parameter)
    );
    qDebug() << "This is C++, return value is : " << returnValue.toString();
  }

  return app.exec();
}