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

  QQuickView view;
  view.setSource(QUrl(
    "qrc:/DiggingQML/VisualTypesThroughQQuickView/sources/qml/files/"
    "VisualTypesThroughQQuickView.qml"
  ));
  view.show();

  QObject* rootObject = view.rootObject();
  qDebug() << "Root object name is : " << rootObject->objectName();

  // Hijack the qml and change it before handing  control over
  // to the event loop.
  QObject* object = rootObject->findChild<QObject*>("rect");
  if (object)
  {
    QQuickItem* item = qobject_cast<QQuickItem*>(object);

    // Modify its properties
    QColor color(Qt::blue);
    item->setProperty("color", color);
    item->setProperty("width", QVariant::fromValue(600));
    item->setProperty("height", QVariant::fromValue(600));
    QQmlProperty::write(item, "height", QVariant::fromValue(800));
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