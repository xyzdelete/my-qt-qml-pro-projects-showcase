#pragma once

#include <QDateTime>
#include <QObject>
#include <QTime>
#include <QtQml/qqmlregistration.h>

class CppClass : public QObject
{
  Q_OBJECT
  QML_ELEMENT
public:
  explicit CppClass(QObject* parent = nullptr);

signals:
  void sendDateTime(QDateTime datetimeparam);
  void sendTime(QTime timeparam);

public slots:
  void cppSlot();
  void timeSlot(QTime time);
  void dateTimeSlot(QDateTime datetime);
};
