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
  app->setApplicationName("RESTClientV2");

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
  paths << ":/RESTClientV2Project";
  paths.removeDuplicates();
  mEngine.setImportPathList(paths);

  mEngine.loadFromModule("RESTClientV2Project", "Main");
}
