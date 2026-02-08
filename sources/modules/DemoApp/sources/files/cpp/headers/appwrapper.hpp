#pragma once

#include <QGuiApplication>
#include <QObject>
#include <QQmlApplicationEngine>

class AppWrapper : public QObject
{
  Q_OBJECT
public:
  explicit AppWrapper(QObject* const parent = nullptr);

  void
  initialize(QGuiApplication* const app);

private:
  QQmlApplicationEngine mEngine;
};
