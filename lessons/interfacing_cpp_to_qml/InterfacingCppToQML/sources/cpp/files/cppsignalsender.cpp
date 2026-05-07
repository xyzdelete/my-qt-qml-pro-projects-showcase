#include "cppsignalsender.hpp"

CppSignalSender::CppSignalSender(QObject* parent)
  : QObject{parent}, m_timer{this}, m_value{0}
{
  connect(
    &m_timer,
    &QTimer::timeout,
    [this]()
    {
      ++m_value;
      emit cppTimer(QString::number(m_value));
    });

  m_timer.start(1000);
}

void CppSignalSender::cppSlot()
{
  emit callQml("Information from C++");
}