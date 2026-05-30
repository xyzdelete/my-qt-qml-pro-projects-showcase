#pragma once

#include <QGuiApplication>
#include <QObject>
#include <QQmlApplicationEngine>

class AppWrapper : public QObject
{
  Q_OBJECT
public:
  explicit AppWrapper(QObject* parent = nullptr);

  bool
  initialize(QGuiApplication* const);

signals:

public slots:
private slots:
  void
  respondToClick(QString msg, const QVariant& object);

private:
  QQmlApplicationEngine mEngine;

signals:
};
