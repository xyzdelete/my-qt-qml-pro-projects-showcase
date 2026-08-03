#pragma once

#include <QObject>

class QmlJSCaller : public QObject
{
  Q_OBJECT
public:
  explicit QmlJSCaller(QObject* parent = nullptr);

  Q_INVOKABLE void cppMethod(QString parameter);

  void setQmlRootObject(QObject* value);

signals:
private:
  void callJSMethod(QString param);
  QObject* qmlRootObject;
};
