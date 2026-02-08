#include "datasource.hpp"

#include <QDebug>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QRestAccessManager>
#include <QRestReply>
#include <QSslError>

#include <chrono>

namespace
{
constexpr qint64 MaxResponseSize = 1024 * 1024;
constexpr auto   TransferTimeout = std::chrono::seconds(30);
} // namespace

DataSource::DataSource(QObject* parent)
  : QObject{
      parent
}
  , mNetManager{new QNetworkAccessManager{this}}
  , mRestManager{new QRestAccessManager{mNetManager, this}},
  mNetReply{nullptr}, mResponseTooLarge{false}
{
}

void
DataSource::fetchPosts()
{
  setErrorMessage(QString{});
  mResponseTooLarge = false;

  if (mNetReply)
  {
    QNetworkReply* const previousReply = {mNetReply};
    mNetReply                          = nullptr;
    previousReply->abort();
    previousReply->deleteLater();
  }

  // Initialize our API data
  const QUrl apiEndpoint = {"https://jsonplaceholder.typicode.com/posts"};

  QNetworkRequest request = {};
  request.setUrl(apiEndpoint);
  request.setTransferTimeout(TransferTimeout);

  mNetReply = mRestManager->get(
    request,
    this,
    [this](QRestReply& reply)
    {
      handleReply(reply);
    }
  );

  connect(
    mNetReply,
    &QNetworkReply::downloadProgress,
    this,
    [this](qint64 bytesReceived, qint64)
    {
      if (bytesReceived > MaxResponseSize && mNetReply)
      {
        qWarning() << "Network response exceeds the maximum size";
        setErrorMessage(tr("The response is too large."));
        mResponseTooLarge = true;
        mNetReply->abort();
      }
    }
  );

#if QT_CONFIG(ssl)
  connect(
    mNetReply,
    &QNetworkReply::sslErrors,
    this,
    [this](const QList<QSslError>& errors)
    {
      qWarning() << "SSL errors:" << errors;
      setErrorMessage(tr("The secure connection could not be verified."));
    }
  );
#endif
}

void
DataSource::addPost(Post* post)
{
  if (!post)
  {
    return;
  }

  if ((post->parent() && post->parent() != this) || mPosts.contains(post))
  {
    qWarning() << "Post ownership rejected";
    return;
  }

  if (post->parent() != this)
  {
    post->setParent(this);
  }

  emit preItemAdded();
  mPosts.append(post);
  emit postItemAdded();
}

void
DataSource::addPost()
{
  Post* const post = {
    new Post{"Test Post Added First", this}
  };
  addPost(post);
}

void
DataSource::addPost(const QString& postParam)
{
  Post* const post = {
    new Post{postParam, this}
  };
  addPost(post);
}

void
DataSource::removePost(int index)
{
  if (index < 0 || index >= mPosts.size())
  {
    return;
  }

  emit        preItemRemoved(index);
  Post* const post = {mPosts.takeAt(index)};
  emit        postItemRemoved();
  post->deleteLater();
}

void
DataSource::removeLastPost()
{
  if (!mPosts.isEmpty())
  {
    removePost(mPosts.size() - 1);
  }
}

void
DataSource::removeAllPosts()
{
  if (mPosts.isEmpty())
  {
    return;
  }

  const int          last = {static_cast<int>(mPosts.size()) - 1};
  emit               preItemsRemoved(0, last);
  const QList<Post*> posts = {mPosts};
  mPosts.clear();
  emit postItemsRemoved();

  for (Post* const post : posts)
  {
    post->deleteLater();
  }
}

const QList<Post*>&
DataSource::dataItems() const
{
  return mPosts;
}

QString
DataSource::errorMessage() const
{
  return m_errorMessage;
}

void
DataSource::setErrorMessage(const QString& message)
{
  if (m_errorMessage == message)
  {
    return;
  }

  m_errorMessage = message;
  emit errorMessageChanged();
}

void
DataSource::addPosts(const QStringList& posts)
{
  if (posts.isEmpty())
  {
    return;
  }

  const int    first = {static_cast<int>(mPosts.size())};
  const int    last  = {first + static_cast<int>(posts.size()) - 1};
  QList<Post*> newPosts;
  newPosts.reserve(posts.size());

  for (const QString& text : posts)
  {
    newPosts.append(new Post{text, this});
  }

  emit preItemsAdded(first, last);
  mPosts.append(newPosts);
  emit postItemsAdded();
}

void
DataSource::handleReply(QRestReply& reply)
{
  QNetworkReply* const networkReply = {reply.networkReply()};
  if (networkReply != mNetReply)
  {
    return;
  }

  mNetReply = nullptr;
  networkReply->deleteLater();

  if (!reply.isSuccess())
  {
    // Avoid clobbering the size-limit message with the abort() it triggers.
    if (!mResponseTooLarge)
    {
      if (reply.hasError())
      {
        qWarning() << "Network error:" << reply.errorString();
        setErrorMessage(
          tr("Network request failed: %1").arg(reply.errorString())
        );
      }
      else
      {
        qWarning() << "HTTP error:" << reply.httpStatus();
        setErrorMessage(
          tr("The server returned HTTP %1.").arg(reply.httpStatus())
        );
      }
    }
    return;
  }

  QJsonParseError                    error = {};
  const std::optional<QJsonDocument> doc   = {reply.readJson(&error)};

  if (!doc)
  {
    qWarning() << "JSON parse error:" << error.errorString()
               << "at offset:" << error.offset;
    setErrorMessage(tr("The server returned invalid JSON."));
    return;
  }

  if (doc->isArray())
  {
    const QJsonArray array = doc->array();

    if (array.isEmpty())
    {
      qWarning() << "Array is empty";
      setErrorMessage(tr("The server returned no posts."));
      return;
    }

    QStringList posts;
    posts.reserve(array.size());

    for (const QJsonValue& value : array)
    {
      if (!value.isObject())
      {
        qWarning() << "Response item is not an object:" << value;
        setErrorMessage(tr("The server returned an invalid post."));
        return;
      }

      const QJsonObject object = value.toObject();
      const QJsonValue  title  = object.value("title");

      if (!title.isString())
      {
        qWarning() << "Response item has no string title:" << object;
        setErrorMessage(tr("The server returned an invalid post."));
        return;
      }

      posts.append(title.toString());
    }

    addPosts(posts);
  }
  else if (doc->isObject())
  {
    const QJsonObject object = {doc->object()};

    if (object.isEmpty())
    {
      qWarning() << "Object is empty";
      setErrorMessage(tr("The server returned an empty post."));
      return;
    }

    const QJsonValue title = {object.value("title")};
    if (!title.isString())
    {
      qWarning() << "Response object has no string title";
      setErrorMessage(tr("The server returned an invalid post."));
      return;
    }

    addPost(title.toString());
  }
  else
  {
    qWarning() << "Unexpected JSON format";
    setErrorMessage(tr("The server returned an unexpected format."));
  }
}
