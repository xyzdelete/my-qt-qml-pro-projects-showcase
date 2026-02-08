#include "appwrapper.hpp"

#include <QGuiApplication>
#include <QQuickStyle>
#include <QTranslator>

// AppleClang ships no C++20 module dependency scanner (clang-scan-deps), so
// CMake cannot build the CXX_MODULES file sets on Apple platforms; fall back
// to the header-only *Apple.hpp equivalents there instead of `import`.
#if defined(__APPLE__)
#include "ModuleExampleApple.hpp"
#include "StaticLibModuleExampleApple.hpp"
#else
import StaticLibModuleExample;
import ModuleExample;
#endif

// namespace
// {
// // Needs to be used before engine setup
// void
// loadTranslationFile(const QGuiApplication& app)
// {
//   QTranslator translator;

//   const QLocale locale = QLocale::system();
//   qDebug() << "System locale:" << locale.name();

//   const auto trLoadRes =
//     translator.load(":/i18n/CVApp_" + locale.name() + ".qm");

//   if (trLoadRes)
//   {
//     app.installTranslator(&translator);
//   }
// }
// } // namespace

int
main(int argc, char* argv[])
{
  QGuiApplication app{argc, argv};
  QQuickStyle::setStyle("Material");
  StaticLibModuleExample::hello_world();
  ModuleExample::hello_world();

  // ::loadTranslationFile(app);

  AppWrapper wrapper;

  wrapper.initialize(&app);

  return app.exec();
}