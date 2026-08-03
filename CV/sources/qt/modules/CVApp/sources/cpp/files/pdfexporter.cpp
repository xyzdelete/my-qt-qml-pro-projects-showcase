#include "pdfexporter.hpp"
#include <QBuffer>
#include <QPageSize>
#include <QPainter>
#include <QPdfWriter>
#include <QPointer>
#include <QQmlProperty>
#include <QQuickWindow>

#ifdef Q_OS_WASM
#include <QFileDialog>
#endif

#include <QDebug>

void
PdfExporter::saveItemAsPdf(
  QQuickItem* const item, const QString& suggestedName, const QUrl& fileUrl
)
{
  if (!item)
  {
    emit exportFinished(false, QString());
    return;
  }

  const QQmlProperty isExportingProp{item, QStringLiteral("isExporting")};
  if (!isExportingProp.isValid())
  {
    qWarning(
      "PdfExporter: item has no 'isExporting' property; QML not updated?"
    );
    emit exportFinished(false, QString());
    return;
  }

  QQuickWindow* const window{item->window()};
  if (!window)
  {
    qWarning("PdfExporter: item has no window; cannot observe frameSwapped");
    emit exportFinished(false, QString());
    return;
  }

  // Drop any leftover connection from a previous/aborted export.
  QObject::disconnect(m_frameSwappedConnection);

  isExportingProp.write(true);

  const QPointer<QQuickItem> safeItem{item};

  // frameSwapped fires once a full frame — including the polish pass that
  // finalizes GridLayout/ColumnLayout/anchors geometry — has actually been
  // rendered and presented. Since our width change above requests exactly
  // such a frame, the very next firing of this signal guarantees the
  // print-width layout has fully settled, with no timing guesswork needed.
  m_frameSwappedConnection = QObject::connect(
    window,
    &QQuickWindow::frameSwapped,
    this,
    [this, safeItem, suggestedName, fileUrl]()
    {
      QObject::disconnect(m_frameSwappedConnection);

      if (!safeItem)
      {
        emit exportFinished(false, QString());
        return;
      }
      grabAndExport(safeItem, suggestedName, fileUrl);
    }
  );
}

void
PdfExporter::grabAndExport(
  QQuickItem* const item, const QString& suggestedName, const QUrl& fileUrl
)
{
  const qreal itemWidth{item->width()};
  const qreal itemHeight{item->height()};

  if (itemWidth <= 0 || itemHeight <= 0)
  {
    QQmlProperty{item, QStringLiteral("isExporting")}.write(false);
    emit exportFinished(false, QString());
    return;
  }

  // grabToImage's targetSize is in device-independent pixels, but the
  // underlying RHI texture it allocates is targetSize * devicePixelRatio,
  // in physical device pixels. On HiDPI displays (DPR 2, 3, ...) this
  // means the actual GPU texture request is a multiple of what our own
  // math below sees unless we account for it here too.
  const qreal devicePixelRatio{item->window()->effectiveDevicePixelRatio()};
  qDebug() << "devicePixelRatio:" << devicePixelRatio;

  // Stay under common GPU max-texture limits (some GPUs cap at 16384).
  // This must be checked against the final physical-pixel
  // texture size, i.e. including devicePixelRatio, not just our logical
  // scale factor.
  const qreal maxDimension{16384.0};
  const qreal rawWidth{itemWidth * devicePixelRatio};
  const qreal rawHeight{itemHeight * devicePixelRatio};
  qDebug() << "rawWidth:" << rawWidth;
  qDebug() << "rawHeight:" << rawHeight;
  const qreal maxScaleForWidth{maxDimension / (rawWidth)};
  const qreal maxScaleForHeight{maxDimension / (rawHeight)};
  qDebug() << "maxScaleForWidth:" << maxScaleForWidth;
  qDebug() << "maxScaleForHeight:" << maxScaleForHeight;

  const qreal scale{qMin(maxScaleForWidth, maxScaleForHeight)};
  qDebug() << "scale:" << scale;

  const QSize targetSize{qRound(itemWidth * scale), qRound(itemHeight * scale)};

  m_grabResult = item->grabToImage(targetSize);
  if (!m_grabResult)
  {
    QQmlProperty{item, QStringLiteral("isExporting")}.write(false);
    emit exportFinished(false, QString());
    return;
  }

  connect(
    m_grabResult.data(),
    &QQuickItemGrabResult::ready,
    this,
    [this, item, itemWidth, itemHeight, suggestedName, fileUrl]()
    {
      const QImage image{m_grabResult->image()};
      m_grabResult.reset();

      // Restore the live responsive layout now that the grab is done.
      QQmlProperty{item, QStringLiteral("isExporting")}.write(false);

      if (image.isNull())
      {
        emit exportFinished(false, QString());
        return;
      }

      writePdfAndFinish(image, itemWidth, itemHeight, suggestedName, fileUrl);
    }
  );
}

void
PdfExporter::writePdfAndFinish(
  const QImage&  image,
  const qreal    itemWidth,
  const qreal    itemHeight,
  const QString& suggestedName,
  const QUrl&    fileUrl
)
{
  const int dpi{96};
  QString   name{suggestedName};
#ifdef Q_OS_WASM
  // WASM: no real filesystem — write into memory, then trigger a browser
  // download
  QByteArray pdfBytes;
  QBuffer    buffer{&pdfBytes};
  buffer.open(QIODevice::WriteOnly);

  QPdfWriter pdfWriter{&buffer};
  pdfWriter.setResolution(dpi);
  pdfWriter.setPageSize(
    QPageSize{
      QSizeF{itemWidth / qreal(dpi), itemHeight / qreal(dpi)},
      QPageSize::Inch
  }
  );
  pdfWriter.setPageMargins(QMarginsF{0, 0, 0, 0});

  QPainter painter{&pdfWriter};
  painter.setRenderHint(QPainter::SmoothPixmapTransform);
  painter.drawImage(
    QRectF{0, 0, qreal(pdfWriter.width()), qreal(pdfWriter.height())}, image
  );
  painter.end();
  buffer.close();

  if (!name.endsWith(u".pdf", Qt::CaseInsensitive))
  {
    name += QStringLiteral(".pdf");
  }

  QFileDialog::saveFileContent(pdfBytes, name);
  emit exportFinished(true, name);

#else
  // Desktop: write directly to the chosen file path
  QString filePath{
    fileUrl.isLocalFile() ? fileUrl.toLocalFile() : fileUrl.toString()
  };
  if (!filePath.endsWith(u".pdf", Qt::CaseInsensitive))
  {
    filePath += QStringLiteral(".pdf");
  }

  QPdfWriter pdfWriter{filePath};
  pdfWriter.setResolution(dpi);
  pdfWriter.setPageSize(
    QPageSize{
      QSizeF{itemWidth / qreal(dpi), itemHeight / qreal(dpi)},
      QPageSize::Inch
  }
  );
  pdfWriter.setPageMargins(QMarginsF{0, 0, 0, 0});

  QPainter painter{&pdfWriter};
  painter.setRenderHint(QPainter::SmoothPixmapTransform);
  painter.drawImage(
    QRectF{0, 0, qreal(pdfWriter.width()), qreal(pdfWriter.height())}, image
  );
  painter.end();

  emit exportFinished(true, filePath);
#endif
}