#pragma once

#include <QJSEngine>
#include <QObject>
#include <QQmlEngine>

class SingletonClass : public QObject
{
  Q_OBJECT
  /*
  QML_SINGLETON
  QML_ELEMENT
  */
public:
  explicit SingletonClass(QObject* parent = nullptr);

  static QJSValue
  singletonProvider(QQmlEngine* engine, QJSEngine* scriptEngine);

  Q_INVOKABLE QJSValue
  getJsValue();
};
