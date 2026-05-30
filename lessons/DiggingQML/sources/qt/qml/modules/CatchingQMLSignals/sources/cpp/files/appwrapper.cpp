#include "appwrapper.hpp"

AppWrapper::AppWrapper(QObject* parent)
  : QObject{parent}
{
}

bool
AppWrapper::initialize(QGuiApplication* const app)
{
  app->setOrganizationDomain("github.com/xyzdelete");
  app->setOrganizationName("xyzdelete");
  app->setApplicationName("DiggingQML");

  QObject::connect(
    &mEngine,
    &QQmlApplicationEngine::objectCreationFailed,
    app,
    []()
    {
      QCoreApplication::exit(-1);
    },
    Qt::QueuedConnection
  );

  QStringList paths = mEngine.importPathList();
  paths << ":/DiggingQML";
  paths.removeDuplicates();
  mEngine.setImportPathList(paths);

  mEngine.loadFromModule("DiggingQML", "Main");

  if (mEngine.rootObjects().isEmpty())
    return false;

  QObject* rootObject =
    mEngine
      .rootObjects()[0]; // The object that contains the signal on the QML side.
  connect(
    rootObject,
    SIGNAL(qmlSignal(QString, QVariant)),
    this,
    SLOT(respondToClick(QString, QVariant))
  );

  return true;
}

void
AppWrapper::respondToClick(QString msg, const QVariant& object)
{
  qDebug() << "The message is : " << msg;

  QObject* mObject = object.value<QObject*>();

  qDebug() << "The property is : " << mObject->property("mProp").toString();
}
