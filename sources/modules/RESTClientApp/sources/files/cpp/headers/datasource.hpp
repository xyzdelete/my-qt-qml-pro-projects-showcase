#pragma once

#include "post.hpp"

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QObject>
#include <QStringList>
#include <qqmlintegration.h>

class QRestAccessManager;
class QRestReply;

class DataSource : public QObject
{
  Q_OBJECT

  QML_ELEMENT
  QML_UNCREATABLE("DataSource is created by PostModel")

  Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)

public:
  explicit DataSource(QObject* parent = nullptr);

  Q_INVOKABLE void
  fetchPosts();

  void
  addPost(Post* post);

  Q_INVOKABLE void
  addPost();

  Q_INVOKABLE void
  addPost(const QString& postParam);

  Q_INVOKABLE void
  removePost(int index);

  Q_INVOKABLE void
  removeLastPost();

  Q_INVOKABLE void
  removeAllPosts();

  const QList<Post*>&
  dataItems() const;

  QString
  errorMessage() const;

private:
  void
  addPosts(const QStringList& posts);

  void
  setErrorMessage(const QString& message);

  void
  handleReply(QRestReply& reply);

signals:
  void
  preItemAdded();

  void
  postItemAdded();

  void
  preItemRemoved(int index);

  void
  postItemRemoved();

  void
  preItemsAdded(int first, int last);

  void
  postItemsAdded();

  void
  preItemsRemoved(int first, int last);

  void
  postItemsRemoved();

  void
  errorMessageChanged();

private:
  QNetworkAccessManager* mNetManager;
  QRestAccessManager*    mRestManager;
  QNetworkReply*         mNetReply;
  QList<Post*>           mPosts;
  QString                m_errorMessage;
  bool                   mResponseTooLarge;
};
