#include "postmodel.hpp"

PostModel::PostModel(QObject* parent)
  : QAbstractListModel(parent)
{
  setDatasource(new DataSource(this));
}

int
PostModel::rowCount(const QModelIndex& parent) const
{
  Q_UNUSED(parent);
  int count{};
  if (m_datasource)
  {
    count = m_datasource->dataItems().count();
  }

  return count;
}

QVariant
PostModel::data(const QModelIndex& index, int role) const
{
  QString result{};

  if (!m_datasource)
  {
    return result;
  }

  if (index.row() < 0 || index.row() >= m_datasource->dataItems().count())
  {
    return result;
  }

  Post* const post{m_datasource->dataItems().at(index.row())};

  switch (static_cast<PostModelRoles>(role))
  {
  case PostModelRoles::PostDataRole:
    result = post->post();
    break;
  default:
    break;
  }

  return result;
}

bool
PostModel::setData(const QModelIndex& index, const QVariant& value, int role)
{
  Post* const post{m_datasource->dataItems().at(index.row())};
  bool        isSomethingChanged{false};

  switch (static_cast<PostModelRoles>(role))
  {
  case PostModelRoles::PostDataRole:
    if (post->post() != value.toString())
    {
      post->setPost(value.toString());
      isSomethingChanged = true;
      emit dataChanged(index, index, QVector<int>() << role);
    }
    break;
  default:
    break;
  }

  return isSomethingChanged;
}

Qt::ItemFlags
PostModel::flags(const QModelIndex& index) const
{
  Qt::ItemFlags itemFlags{Qt::NoItemFlags};
  if (index.isValid())
  {
    itemFlags = Qt::ItemIsEditable;
  }

  return itemFlags;
}

QHash<int, QByteArray>
PostModel::roleNames() const
{
  return {
    {static_cast<int>(PostModelRoles::PostDataRole), "post"},
  };
}

DataSource*
PostModel::datasource() const
{
  return m_datasource;
}

void
PostModel::setDatasource(DataSource* datasource)
{
  beginResetModel();

  if (m_datasource)
  {
    m_datasource->disconnect(this);
  }

  m_datasource = datasource;

  if (m_datasource)
  {
    connect(
      m_datasource,
      &DataSource::preItemAdded,
      this,
      [this]()
      {
        const int index = rowCount();
        beginInsertRows(QModelIndex(), index, index);
      }
    );

    connect(
      m_datasource,
      &DataSource::postItemAdded,
      this,
      [this]()
      {
        endInsertRows();
      }
    );

    connect(
      m_datasource,
      &DataSource::preItemRemoved,
      this,
      [this](int index)
      {
        beginRemoveRows(QModelIndex(), index, index);
      }
    );

    connect(
      m_datasource,
      &DataSource::postItemRemoved,
      this,
      [this]()
      {
        endRemoveRows();
      }
    );
  }

  endResetModel();
  emit datasourceChanged();
}