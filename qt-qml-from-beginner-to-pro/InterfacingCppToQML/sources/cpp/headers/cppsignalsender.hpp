#pragma once

#include <QObject>
#include <QTimer>

class CppSignalSender : public QObject
{
  Q_OBJECT
public:
  explicit CppSignalSender(QObject* parent = nullptr);

signals:
  void callQml(QString parameter);
  void cppTimer(QString value);
public slots:
  void cppSlot();

private:
  QTimer m_timer;
  int m_value;
};