#pragma once

#include "postmodel.hpp"

#include <QGuiApplication>
#include <QObject>
#include <QQmlApplicationEngine>

class AppWrapper : public QObject
{
  Q_OBJECT
public:
  explicit AppWrapper(QObject* parent = nullptr);

  void
  initialize(QGuiApplication* app);

private:
  QQmlApplicationEngine mEngine;
  PostModel             mPostModel;
};
