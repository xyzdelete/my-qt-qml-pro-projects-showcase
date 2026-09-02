#pragma once

#include "cppclass.hpp"

#include <QtQml>

class CppClassWrapper
{
  Q_GADGET
  QML_FOREIGN(CppClass)
  QML_NAMED_ELEMENT(CppClass)
};
