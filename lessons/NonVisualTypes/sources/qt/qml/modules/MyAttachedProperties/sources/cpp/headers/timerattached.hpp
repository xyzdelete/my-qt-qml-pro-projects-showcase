#pragma once

#include <QObject>
#include <QTimer>
#include <QtQml>

// The attached class

class TimerAttached : public QObject
{
  Q_OBJECT
  QML_ANONYMOUS
  Q_PROPERTY(
    int interval READ interval WRITE setInterval NOTIFY intervalChanged)
  Q_PROPERTY(bool running READ running WRITE setRunning NOTIFY runningChanged)
public:
  explicit TimerAttached(QObject* parent = nullptr);
  int interval() const;
  bool running() const;
  void setInterval(int interval);
  void setRunning(bool running);
signals:
  void timerOut();
  void intervalChanged(int interval);
  void runningChanged(bool running);

private:
  QTimer* m_timer;
  int m_interval;
  bool m_running;
};
