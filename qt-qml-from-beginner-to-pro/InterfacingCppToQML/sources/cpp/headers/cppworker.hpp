#pragma once

#include <QObject>

class CppWorker : public QObject
{
  Q_OBJECT
public:
  explicit CppWorker(QObject* parent = nullptr);

  Q_INVOKABLE void regularMethod();
  Q_INVOKABLE QString regularMethodWithReturn(QString name, int age);
signals:
public slots:
  void cppSlot();
};