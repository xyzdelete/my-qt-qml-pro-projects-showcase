#pragma once

#include "timerattached.hpp"

#include <QObject>
#include <QtQml>
#include <qqml.h>

// The attaching class: what we reference in QML files.
class MyTimer : public QObject
{
  Q_OBJECT
  QML_ELEMENT
  QML_ATTACHED(TimerAttached)
public:
  static TimerAttached* qmlAttachedProperties(QObject* object);
};
