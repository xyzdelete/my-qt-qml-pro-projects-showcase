#pragma once

#include <QDebug>
#include <QObject>
#include <QtQml>

class MySingleton : public QObject
{
  Q_OBJECT
  /*
  QML_SINGLETON
  QML_ELEMENT
  */
public:
  explicit MySingleton(QObject* parent = nullptr);

  // Invokable methods
  Q_INVOKABLE void doSomething() const
  {
    qDebug() << "Doing something...";
  }

signals:
};
