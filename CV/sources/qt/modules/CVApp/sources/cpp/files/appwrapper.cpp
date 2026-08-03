#include "appwrapper.hpp"

#include <QDebug>
#include <QSslSocket>

AppWrapper::AppWrapper(QObject* const parent)
  : QObject(parent)
{
}

void
AppWrapper::initialize(QGuiApplication* const app)
{
  app->setOrganizationDomain("github.com/xyzdelete");
  app->setOrganizationName("xyzdelete");
  const QString targetName = {"CVApp"};
  app->setApplicationName(targetName);

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

  mEngine.loadFromModule(targetName, "Main");

#if QT_CONFIG(ssl)
  qDebug() << QSslSocket::activeBackend();
#else
  qDebug() << "SSL: not available on this platform (TLS handled by browser)";
#endif
}
