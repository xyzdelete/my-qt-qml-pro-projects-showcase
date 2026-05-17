#pragma once

#include <QGuiApplication>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QObject>
#include <QQmlApplicationEngine>
#include <memory>


class AppWrapper : public QObject
{
  Q_OBJECT
public:
  explicit AppWrapper(QObject* parent = nullptr);
  ~AppWrapper();
  Q_INVOKABLE void fetchPosts();
  Q_INVOKABLE void removeLast();
  bool initialize(QGuiApplication* app);

private slots:
  void dataReadyRead();
  void dataReadFinished();

private:
  void resetModel();

  std::unique_ptr<QNetworkAccessManager> mNetManager;
  QNetworkReply* mNetReply;
  QByteArray mDataBuffer;
  QStringList mPosts;
  QQmlApplicationEngine mEngine;
};