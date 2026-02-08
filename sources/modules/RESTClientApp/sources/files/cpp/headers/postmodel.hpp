#pragma once

#include "datasource.hpp"

#include <QAbstractListModel>
#include <QObject>
#include <qqmlintegration.h>

class PostModel : public QAbstractListModel
{
  Q_OBJECT

  Q_PROPERTY(DataSource* datasource READ datasource CONSTANT)
  Q_PROPERTY(QString errorMessage READ errorMessage NOTIFY errorMessageChanged)
  Q_PROPERTY(bool hasError READ hasError NOTIFY errorMessageChanged)

  QML_ELEMENT
  QML_SINGLETON

  enum class PostModelRoles
  {
    PostDataRole = Qt::UserRole,
  };

public:
  explicit PostModel(QObject* parent = nullptr);

  int
  rowCount(const QModelIndex& parent = QModelIndex()) const;

  QVariant
  data(const QModelIndex& index, int role) const;

  bool
  setData(const QModelIndex& index, const QVariant& value, int role);

  Qt::ItemFlags
  flags(const QModelIndex& index) const;

  QHash<int, QByteArray>
  roleNames() const;

  DataSource*
  datasource() const;

  QString
  errorMessage() const;

  bool
  hasError() const;

  Q_INVOKABLE void
  fetchPosts();

  Q_INVOKABLE void
  removeLastPost();

  Q_INVOKABLE void
  removeAllPosts();

signals:
  void
  errorMessageChanged();

private:
  DataSource* m_datasource{nullptr};
};
