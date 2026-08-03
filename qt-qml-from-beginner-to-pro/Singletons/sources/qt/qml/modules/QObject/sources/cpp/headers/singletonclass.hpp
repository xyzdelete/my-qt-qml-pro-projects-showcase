#pragma once

#include <QJSEngine>
#include <QObject>
#include <QQmlEngine>
#include <QTimer>

class SingletonClass : public QObject
{
  Q_OBJECT
  Q_PROPERTY(
    int someProperty READ someProperty WRITE setSomeProperty NOTIFY
      somePropertyChanged
  )
  QML_SINGLETON
  QML_ELEMENT
public:
  explicit SingletonClass(QObject* parent = nullptr);

  int
  someProperty() const;

  void
  setSomeProperty(int someProperty);

  static QObject*
  singletonProvider(QQmlEngine* engine, QJSEngine* scriptEngine);

signals:
  void
  somePropertyChanged(int someProperty);

private:
  int     m_someProperty;
  QTimer* m_timer;
};
