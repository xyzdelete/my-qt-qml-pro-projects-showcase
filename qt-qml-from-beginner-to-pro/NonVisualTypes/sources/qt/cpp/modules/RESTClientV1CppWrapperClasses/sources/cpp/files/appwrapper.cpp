#include "appwrapper.hpp"

#include <QDebug>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkRequest>
#include <QQmlContext>
#include <QQuickStyle>

AppWrapper::AppWrapper(QObject* parent)
  : QObject(parent)
  , mNetManager(std::make_unique<QNetworkAccessManager>())  // Use make_unique
{
}

AppWrapper::~AppWrapper()
{
}

void AppWrapper::fetchPosts()
{
  // Initialize our API data
  const QUrl API_ENDPOINT("https://jsonplaceholder.typicode.com/posts");

  QNetworkRequest request;
  request.setUrl(API_ENDPOINT);

  mNetReply = mNetManager->get(request);
  connect(mNetReply, &QIODevice::readyRead, this, &AppWrapper::dataReadyRead);
  connect(
    mNetReply,
    &QNetworkReply::finished,
    this,
    &AppWrapper::dataReadFinished);
}

void AppWrapper::removeLast()
{
  if (!mPosts.isEmpty())
  {
    mPosts.removeLast();
    resetModel();
  }
}

bool AppWrapper::initialize(QGuiApplication* app)
{
  mEngine.rootContext()->setContextProperty("Wrapper", this);
  resetModel();

  QObject::connect(
    &mEngine,
    &QQmlApplicationEngine::objectCreationFailed,
    app,
    []()
    {
      QCoreApplication::exit(-1);
    },
    Qt::QueuedConnection);
  QStringList paths = mEngine.importPathList();
  paths << ":/RESTIntegration";
  paths.removeDuplicates();
  mEngine.setImportPathList(paths);
  QQuickStyle::setStyle("Material");
  mEngine.loadFromModule("RESTIntegration", "Main");

  if (mEngine.rootObjects().isEmpty())
  {
    return false;
  }
  else
  {
    return true;
  }
}

void AppWrapper::dataReadyRead()
{
  mDataBuffer.append(mNetReply->readAll());
}

void AppWrapper::dataReadFinished()
{
  // Parse the JSON
  if (mNetReply->error())
  {
    qDebug() << "Error : " << mNetReply->errorString();
  }
  else
  {
    // qDebug() << "Data fetch finished : " << QString(*mDataBuffer);

    // Turn the data into a json document
    QJsonDocument doc = QJsonDocument::fromJson(mDataBuffer);

    /*
    //What if you get an object from the server
    QJsonDocument objectDoc = QJsonDocument::fromJson(*mDataBuffer);
    QJsonObject obObject = objectDoc.toVariant().toJsonObject();
    */

    // Turn document into json array
    QJsonArray array = doc.array();
    for (int i = 0; i < array.size(); i++)
    {
      QJsonObject object = array.at(i).toObject();
      QVariantMap map = object.toVariantMap();
      QString title = map["title"].toString();
      mPosts.append(title);
    }
    if (array.size() != 0)
    {
      resetModel();
    }
    // Clear the buffer
    mDataBuffer.clear();
  }
}

void AppWrapper::resetModel()
{
  mEngine.rootContext()->setContextProperty(
    "myModel",
    QVariant::fromValue(mPosts));
}
