#include "movie.hpp"

Movie::Movie(QObject* parent) : QObject{parent}
{
}

const QString& Movie::mainCharacter() const
{
  return m_mainCharacter;
}

void Movie::setMainCharacter(const QString& newMainCharacter)
{
  if (m_mainCharacter == newMainCharacter)
    return;
  m_mainCharacter = newMainCharacter;
  emit mainCharacterChanged();
}

const QString& Movie::title() const
{
  return m_title;
}

void Movie::setTitle(const QString& newTitle)
{
  if (m_title == newTitle)
    return;
  m_title = newTitle;
  emit titleChanged();
}