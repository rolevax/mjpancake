TEMPLATE = app

CONFIG += c++1z
CONFIG(release, debug|release): DEFINES += NDEBUG

SOURCES += main_test.cpp

# Default rules for deployment.
include(deployment.pri)

include(libsaki.pri)

MOC_DIR = ./moc
RCC_DIR = ./qrc
OBJECTS_DIR = ./obj

mac|android {
    QMAKE_CXXFLAGS_WARN_ON = -Wall -Wextra -Wno-missing-braces
}
