#include "appwrapper.hpp"

#include <QDebug>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkRequest>
#include <QQmlContext>

AppWrapper::AppWrapper(QObject* parent)
  : QObject(parent)
{
}

void
AppWrapper::initialize(QGuiApplication* app)
{
  app->setOrganizationDomain("github.com/xyzdelete");
  app->setOrganizationName("xyzdelete");
  const QString projectName{"RESTClientV2"};
  app->setApplicationName(projectName);

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
  QStringList paths{mEngine.importPathList()};
  paths << QString{":/"} + projectName;
  paths.removeDuplicates();
  mEngine.setImportPathList(paths);

  mEngine.loadFromModule(projectName, "Main");

  qDebug() << QSslSocket::activeBackend();
}
