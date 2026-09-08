#pragma once

#include <QMetaObject>
#include <QObject>
#include <QQuickItem>
#include <QQuickItemGrabResult>
#include <QSharedPointer>
#include <QString>
#include <QUrl>
#include <qqmlintegration.h>

class PdfExporter : public QObject
{
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

public:
  explicit PdfExporter(QObject* const parent = nullptr)
    : QObject(parent)
  {
  }

  Q_INVOKABLE static bool
  isWasm()
  {
#ifdef Q_OS_WASM
    return true;
#else
    return false;
#endif
  }

  Q_INVOKABLE void
  saveItemAsPdf(
    QQuickItem* const item,
    const QString&    suggestedName,
    const QUrl&       fileUrl = QUrl()
  );

signals:
  void
  exportFinished(bool success, const QString& path);

private:
  void
  grabAndExport(
    QQuickItem* const item, const QString& suggestedName, const QUrl& fileUrl
  );

  void
  writePdfAndFinish(
    const QImage&  image,
    const qreal    itemWidth,
    const qreal    itemHeight,
    const QString& suggestedName,
    const QUrl&    fileUrl
  );

  QSharedPointer<QQuickItemGrabResult> m_grabResult;
  QMetaObject::Connection              m_frameSwappedConnection;
};