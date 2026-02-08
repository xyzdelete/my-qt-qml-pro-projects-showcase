#pragma once

#include <QObject>
#include <qqmlintegration.h>

class Post : public QObject
{
  Q_OBJECT

  QML_ANONYMOUS

  Q_PROPERTY(QString post READ post WRITE setPost NOTIFY postChanged)
public:
  explicit Post(const QString& post, QObject* parent = nullptr);

  QString
  post() const;

  void
  setPost(QString post);

signals:
  void
  postChanged(QString post);

private:
  QString m_post;
};
