#include "timer.hpp"

TimerAttached* MyTimer::qmlAttachedProperties(QObject* object)
{
  return new TimerAttached(object);
}
