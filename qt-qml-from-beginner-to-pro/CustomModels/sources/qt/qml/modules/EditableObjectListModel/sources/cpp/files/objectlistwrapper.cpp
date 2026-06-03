#include "objectlistwrapper.hpp"

#include "person.hpp"

#include <QDebug>

ObjectListWrapper::ObjectListWrapper(QObject* parent) : QObject(parent)
{
  populateModelWithData();
}

bool ObjectListWrapper::initialize(QGuiApplication* app)
{
  resetModel();

  app->setOrganizationDomain("github.com/xyzdelete");
  app->setOrganizationName("xyzdelete");
  app->setApplicationName("NonVisualTypes");
  QStringList paths = mEngine.importPathList();
  paths << ":/CustomModels";
  paths.removeDuplicates();
  mEngine.setImportPathList(paths);

  mEngine.loadFromModule("CustomModels", "Main");

  QObject::connect(
    &mEngine,
    &QQmlApplicationEngine::objectCreationFailed,
    app,
    []()
    {
      QCoreApplication::exit(-1);
    },
    Qt::QueuedConnection);

  if (mEngine.rootObjects().isEmpty())
    return false;

  return true;
}

void ObjectListWrapper::setNames(int index, const QString& names)
{
  qDebug() << "Changing names to : " << names;
  if (index >= mPersons.size())
    return;
  Person* person = static_cast<Person*>(mPersons.at(index));
  if (names != person->names())
  {
    person->setNames(names);
    resetModel();
  }
  printPersons();
}

void ObjectListWrapper::setAge(int index, const int& age)
{
  if (index >= mPersons.size())
    return;
  Person* person = static_cast<Person*>(mPersons.at(index));
  if (age != person->age())
  {
    person->setAge(age);
    resetModel();
  }
  printPersons();
}

void ObjectListWrapper::setFavoriteColor(
  int index, const QString& favoriteColor)
{
  if (index >= mPersons.size())
    return;
  Person* person = static_cast<Person*>(mPersons.at(index));
  if (favoriteColor != person->favoriteColor())
  {
    person->setFavoriteColor(favoriteColor);
    resetModel();
  }
  printPersons();
}

QList<QObject*> ObjectListWrapper::persons() const
{
  return mPersons;
}

void ObjectListWrapper::addPerson()
{
  mPersons.append(new Person("New Person", "green", 32, this));
  resetModel();
}

void ObjectListWrapper::populateModelWithData()
{
  mPersons.append(new Person("John Doe", "green", 32, this));
  mPersons.append(new Person("Mary Green", "blue", 23, this));
  mPersons.append(new Person("Mitch Nathson", "dodgerblue", 30, this));
}

void ObjectListWrapper::resetModel()
{
  emit personsChanged();
}

void ObjectListWrapper::printPersons()
{
  qDebug() << "-------------Persons--------------------";
  foreach (QObject* obj, mPersons)
  {
    Person* person = static_cast<Person*>(obj);
    qDebug() << person->names() << " " << person->age() << " "
             << person->favoriteColor();
  }
}
