#include "datasource.hpp"

#include <QDebug>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

DataSource::DataSource(QObject* parent)
  : QObject{parent}
  , mNetManager{new QNetworkAccessManager{this}}
  , mNetReply{nullptr}
  , mDataBuffer{new QByteArray}
{
}

void
DataSource::fetchPosts()
{
  // Initialize our API data
  const QUrl API_ENDPOINT("https://jsonplaceholder.typicode.com/posts");

  QNetworkRequest request{};
  request.setUrl(API_ENDPOINT);

  mNetReply = mNetManager->get(request);
  connect(mNetReply, &QIODevice::readyRead, this, &DataSource::dataReadyRead);
  connect(
    mNetReply, &QNetworkReply::finished, this, &DataSource::dataReadFinished
  );
}

void
DataSource::addPost(Post* post)
{
  emit preItemAdded();
  mPosts.append(post);
  emit postItemAdded();
}

void
DataSource::addPost()
{
  Post* const post{
    new Post{"Test Post Added First", this}
  };
  addPost(post);
}

void
DataSource::addPost(const QString& postParam)
{
  Post* const post{
    new Post{postParam, this}
  };
  addPost(post);
}

void
DataSource::removePost(int index)
{
  emit preItemRemoved(index);
  mPosts.removeAt(index);
  emit postItemRemoved();
}

void
DataSource::removeLastPost()
{
  if (!mPosts.isEmpty())
  {
    removePost(mPosts.size() - 1);
  }
}

QList<Post*>
DataSource::dataItems()
{
  return mPosts;
}

void
DataSource::dataReadyRead()
{
  mDataBuffer->append(mNetReply->readAll());
}

void
DataSource::dataReadFinished()
{
  // Parse the JSON
  if (mNetReply->error())
  {
    qDebug() << "Error : " << mNetReply->errorString();
  }
  else
  {
    // qDebug() << "Data fetch finished : " << QString(*mDataBuffer);

    QJsonParseError     error;
    const QJsonDocument doc{QJsonDocument::fromJson(*mDataBuffer, &error)};

    if (error.error != QJsonParseError::NoError)
    {
      qDebug() << "JSON parse error:" << error.errorString()
               << "at offset:" << error.offset;
      return;
    }

    if (doc.isNull())
    {
      qDebug() << "Document is null";
      return;
    }

    if (doc.isArray())
    {
      const QJsonArray array{doc.array()};

      if (array.isEmpty())
      {
        qDebug() << "Array is empty";
        return;
      }

      for (const QJsonValue& value : array)
      {
        addPost(value["title"].toString());
      }
    }
    else if (doc.isObject())
    {
      const QJsonObject object{doc.object()};

      if (object.isEmpty())
      {
        qDebug() << "Object is empty";
        return;
      }

      addPost(object["title"].toString());
    }
    else
    {
      qDebug() << "Unexpected JSON format";
    }

    // Clear the buffer
    mDataBuffer->clear();
  }
}
