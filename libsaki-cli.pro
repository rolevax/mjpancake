TEMPLATE = app

# Actually not needed, need to fuck the fucking dependancy
QT += qml quick

CONFIG += c++1z
CONFIG(release, debug|release): DEFINES += NDEBUG

HEADERS += cli/p_cli.h \
           gui/p_editor.h \
           gui/p_global.h \
           gui/p_port.h

SOURCES += main_cli.cpp \
           cli/p_cli.cpp \
           gui/p_editor.cpp \
           gui/p_global.cpp \
           gui/p_port.cpp

# Default rules for deployment.
include(deployment.pri)

include(libsaki.pri)

MOC_DIR = ./moc
RCC_DIR = ./qrc
OBJECTS_DIR = ./obj

mac|android {
    QMAKE_CXXFLAGS_WARN_ON = -Wall -Wextra -Wno-missing-braces
}
