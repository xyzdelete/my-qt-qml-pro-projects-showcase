#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>

int main(int argc, char* argv[])
{
  QGuiApplication app(argc, argv);

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
  engine.addImportPath(":/qt/qml");
  QQuickStyle::setStyle("Material");
  engine.loadFromModule("Networking", "Main");

  return app.exec();
}
