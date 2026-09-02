#pragma once

#include "player.hpp"

#include <QObject>
#include <QtQml>

class Defender : public Player
{
  Q_OBJECT
  QML_ELEMENT
public:
  explicit Defender(QObject* parent = nullptr);

  void play();

  void defend();

signals:

public slots:
};
