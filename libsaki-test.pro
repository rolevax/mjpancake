TEMPLATE = app

CONFIG += c++11
CONFIG(release, debug|release): DEFINES += NDEBUG

SOURCES += main_test.cpp \
    libsaki/action.cpp \
    libsaki/ai.cpp \
    libsaki/form.cpp \
    libsaki/girl.cpp \
    libsaki/hand.cpp \
    libsaki/mount.cpp \
    libsaki/table.cpp \
    libsaki/myrand.cpp \
    libsaki/gen.cpp \
    libsaki/tilecount.cpp \
    libsaki/explain.cpp \
    libsaki/princess.cpp \
    libsaki/girls_shiraitodai.cpp \
    libsaki/girls_kiyosumi.cpp \
    libsaki/girls_asakumi.cpp \
    libsaki/girls_achiga.cpp \
    libsaki/girls_senriyama.cpp \
    libsaki/girls_himematsu.cpp \
    libsaki/ai_senriyama.cpp \
    libsaki/ai_achiga.cpp \
    libsaki/ai_shiraitodai.cpp \
    libsaki/girls_other.cpp \
    libsaki/girls_usuzan.cpp \
    libsaki/ai_usuzan.cpp \
    libsaki/replay.cpp \
    libsaki/girls_eisui.cpp \
    libsaki/girls_miyamori.cpp \
    libsaki/ai_eisui.cpp \
    libsaki/string_enum.cpp \
    libsaki/tableview.cpp \
    libsaki/test.cpp \
    libsaki/girls_util_toki.cpp \
    libsaki/ticketfolder.cpp

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    libsaki/action.h \
    libsaki/ai.h \
    libsaki/form.h \
    libsaki/girl.h \
    libsaki/hand.h \
    libsaki/meld.h \
    libsaki/mount.h \
    libsaki/pointinfo.h \
    libsaki/table.h \
    libsaki/tableobserver.h \
    libsaki/tile.h \
    libsaki/myrand.h \
    libsaki/gen.h \
    libsaki/tilecount.h \
    libsaki/explain.h \
    libsaki/princess.h \
    libsaki/girls_shiraitodai.h \
    libsaki/girls_kiyosumi.h \
    libsaki/girls_asakumi.h \
    libsaki/girls_achiga.h \
    libsaki/girls_senriyama.h \
    libsaki/girls_himematsu.h \
    libsaki/ai_senriyama.h \
    libsaki/ai_achiga.h \
    libsaki/ai_shiraitodai.h \
    libsaki/girls_other.h \
    libsaki/girls_usuzan.h \
    libsaki/ai_usuzan.h \
    libsaki/replay.h \
    libsaki/girls_eisui.h \
    libsaki/girls_miyamori.h \
    libsaki/ai_eisui.h \
    libsaki/who.h \
    libsaki/tableoperator.h \
    libsaki/assume.h \
    libsaki/string_enum.h \
    libsaki/tableview.h \
    libsaki/tablefocus.h \
    libsaki/test.h \
    libsaki/util.h \
    libsaki/girls_util_toki.h \
    libsaki/ticketfolder.h

MOC_DIR = ./moc
RCC_DIR = ./qrc
OBJECTS_DIR = ./obj
