#include "postmodel.hpp"

PostModel::PostModel(QObject* parent)
  : QAbstractListModel(parent)
  , m_datasource{new DataSource{this}}
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
    &DataSource::preItemsAdded,
    this,
    [this](int first, int last)
    {
      beginInsertRows(QModelIndex(), first, last);
    }
  );

  connect(
    m_datasource,
    &DataSource::postItemsAdded,
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

  connect(
    m_datasource,
    &DataSource::preItemsRemoved,
    this,
    [this](int first, int last)
    {
      beginRemoveRows(QModelIndex(), first, last);
    }
  );

  connect(
    m_datasource,
    &DataSource::postItemsRemoved,
    this,
    [this]()
    {
      endRemoveRows();
    }
  );

  connect(
    m_datasource,
    &DataSource::errorMessageChanged,
    this,
    &PostModel::errorMessageChanged
  );
}

int
PostModel::rowCount(const QModelIndex& parent) const
{
  if (parent.isValid())
  {
    return 0;
  }

  int count = {0};
  if (m_datasource)
  {
    count = m_datasource->dataItems().size();
  }

  return count;
}

QVariant
PostModel::data(const QModelIndex& index, int role) const
{
  if (
    !m_datasource || !index.isValid() || index.column() != 0 ||
    index.row() < 0 || index.row() >= m_datasource->dataItems().size()
  )
  {
    return QVariant();
  }

  Post* const post = {m_datasource->dataItems().at(index.row())};
  if (role == static_cast<int>(PostModelRoles::PostDataRole))
  {
    return post->post();
  }

  return QVariant();
}

bool
PostModel::setData(const QModelIndex& index, const QVariant& value, int role)
{
  if (
    !m_datasource || !index.isValid() || index.column() != 0 ||
    index.row() < 0 || index.row() >= m_datasource->dataItems().size()
  )
  {
    return false;
  }

  Post* const post               = {m_datasource->dataItems().at(index.row())};
  bool        isSomethingChanged = {false};

  if (role == static_cast<int>(PostModelRoles::PostDataRole))
  {
    if (post->post() != value.toString())
    {
      post->setPost(value.toString());
      isSomethingChanged = true;
      emit dataChanged(index, index, QVector<int>() << role);
    }
  }

  return isSomethingChanged;
}

Qt::ItemFlags
PostModel::flags(const QModelIndex& index) const
{
  Qt::ItemFlags itemFlags = {Qt::NoItemFlags};
  if (index.isValid() && index.column() == 0)
  {
    itemFlags = Qt::ItemIsEnabled | Qt::ItemIsSelectable | Qt::ItemIsEditable;
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

QString
PostModel::errorMessage() const
{
  return m_datasource->errorMessage();
}

bool
PostModel::hasError() const
{
  return !m_datasource->errorMessage().isEmpty();
}

void
PostModel::fetchPosts()
{
  m_datasource->fetchPosts();
}

void
PostModel::removeLastPost()
{
  m_datasource->removeLastPost();
}

void
PostModel::removeAllPosts()
{
  m_datasource->removeAllPosts();
}
