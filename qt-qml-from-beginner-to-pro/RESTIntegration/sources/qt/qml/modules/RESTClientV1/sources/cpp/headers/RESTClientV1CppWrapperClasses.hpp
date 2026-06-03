#pragma once

#include "appwrapper.hpp"

#include <QtQml>

struct AppWrapperWrapper
{
  Q_GADGET
  QML_FOREIGN(AppWrapper)
  QML_NAMED_ELEMENT(AppWrapper)
};
