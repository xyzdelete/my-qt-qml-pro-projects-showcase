#pragma once

#include <QObject>

class ErrorLevel : public QObject
{
  Q_OBJECT
  // Q_GADGET
public:
  explicit ErrorLevel(QObject* parent = nullptr);
  // explicit ErrorLevel();

  enum ErrorValue
  {
    INFORAMATION,
    WARNING,
    DEBUG,
    MESSAGE
  };

  Q_ENUM(ErrorValue)

  // signals:
};
