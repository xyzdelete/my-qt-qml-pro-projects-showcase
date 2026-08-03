#pragma once

#include "datasource.hpp"

#include <QAbstractListModel>
#include <QObject>
#include <QQmlApplicationEngine>
#include <qqmlintegration.h>

class PostModel : public QAbstractListModel
{
  Q_OBJECT

  Q_PROPERTY(
    DataSource* datasource READ datasource WRITE setDatasource NOTIFY
      datasourceChanged
  )

  QML_ELEMENT
  QML_SINGLETON

  enum class PostModelRoles
  {
    PostDataRole = Qt::UserRole
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
  roleNames() const; // Allows to expose our custom roles(
                     // names,favoritecolor,age) to a qml ListView

  DataSource*
  datasource() const;

  void
  setDatasource(DataSource* datasource);
signals:
  void
  datasourceChanged();

private:
  DataSource* m_datasource{nullptr};
};
