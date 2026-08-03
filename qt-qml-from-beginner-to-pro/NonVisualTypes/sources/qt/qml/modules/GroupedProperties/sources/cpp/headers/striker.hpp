#pragma once

#include "player.hpp"

#include <QObject>
#include <QtQml>

class Striker : public Player
{
  Q_OBJECT
  QML_ELEMENT
public:
  explicit Striker(QObject* parent = nullptr);

  void play();

  void strike();

signals:

public slots:
};
