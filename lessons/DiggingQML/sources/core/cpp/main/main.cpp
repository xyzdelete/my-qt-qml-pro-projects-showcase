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

  QObject* rootObject = engine.rootObjects().first();

  // Show item count
  qDebug() << "Item count : " << rootObject->children().count();
  qDebug() << "Object name : " << rootObject->objectName();

  // Find the rectangles
  QList<QQuickItem*> list = rootObject->findChildren<QQuickItem*>("rect");
  if (list.count() > 0)
  {
    qDebug() << "Rectangle count " << list.count();
    foreach (QQuickItem* item, list)
    {
      qDebug() << "-----------ITEM-------------";
      qDebug() << "The color is : " << item->property("color").toString();

      QVariant varColor = item->property("color");

      QColor color = varColor.value<QColor>();

      qDebug() << "The color components : " << color.red() << " "
               << color.green() << " " << color.blue();

      if (color.green() > 0)
      {
        item->setProperty("radius", 30);
      }
      if (color.blue() > 0)
      {
        item->setProperty("height", 200);
      }
    }
  }

  // Find Text Area
  QQuickItem* quickItem = rootObject->findChild<QQuickItem*>("myTextArea");
  quickItem->setProperty("text", "Text from C++");

  return app.exec();
}