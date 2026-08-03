#pragma once

#include "cppclass.hpp"

#include <QtQml>


struct CppClassWrapper
{
  Q_GADGET
  QML_FOREIGN(CppClass)
  QML_NAMED_ELEMENT(CppClass)
};
