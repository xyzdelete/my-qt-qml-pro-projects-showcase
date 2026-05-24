#pragma once

#include <QColor>
#include <QDate>
#include <QFont>
#include <QObject>
#include <QPoint>
#include <QPointF>
#include <QRect>
#include <QRectF>
#include <QSize>
#include <QSizeF>
#include <QUrl>

class CppClass : public QObject
{
  Q_OBJECT

public:
  explicit CppClass(QObject* parent = nullptr);

signals:
  void sendInt(int parama);
  void sendDouble(double param);
  void sendBoolRealFloat(bool boolparam, qreal realparam, float floatparam);

  void sendStringUrl(QString stringparam, QUrl urlparam);
  void sendColorFont(QColor colorparam, QFont fontparam);
  void sendDate(QDate dateparam);
  void sendPoint(QPoint pointparam, QPointF pointfparam);
  void sendSize(QSize sizeparam, QSizeF sizefparam);
  void sendRect(QRect rectparam, QRectF rectfparam);

public slots:
  void cppSlot();

  // Recieve data from QML
  void receivePoint(QPoint point);
  void receiveRect(QRect rect);
};
