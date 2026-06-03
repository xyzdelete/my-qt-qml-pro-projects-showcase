#pragma once

#include "post.hpp"

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QObject>
#include <qqmlintegration.h>

class DataSource : public QObject
{
  Q_OBJECT
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

  QList<Post*>
  dataItems();

signals:
  void
  preItemAdded();

  void
  postItemAdded();

  void
  preItemRemoved(int index);

  void
  postItemRemoved();

private slots:
  void
  dataReadyRead();

  void
  dataReadFinished();

public slots:
private:
  QNetworkAccessManager* mNetManager;
  QNetworkReply*         mNetReply;
  QByteArray*            mDataBuffer;
  QList<Post*>           mPosts;
};
