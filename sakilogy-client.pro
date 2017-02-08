TEMPLATE = app

QT += qml quick widgets network

android: QT += androidextras

CONFIG += c++11
CONFIG(release, debug|release): DEFINES += NDEBUG

SOURCES += main.cpp \
    libsaki/action.cpp \
    libsaki/ai.cpp \
    libsaki/ai_achiga.cpp \
    libsaki/ai_eisui.cpp \
    libsaki/ai_senriyama.cpp \
    libsaki/ai_shiraitodai.cpp \
    libsaki/ai_usuzan.cpp \
    libsaki/explain.cpp \
    libsaki/form.cpp \
    libsaki/gen.cpp \
    libsaki/girl.cpp \
    libsaki/girls_achiga.cpp \
    libsaki/girls_asakumi.cpp \
    libsaki/girls_eisui.cpp \
    libsaki/girls_himematsu.cpp \
    libsaki/girls_kiyosumi.cpp \
    libsaki/girls_miyamori.cpp \
    libsaki/girls_other.cpp \
    libsaki/girls_senriyama.cpp \
    libsaki/girls_shiraitodai.cpp \
    libsaki/girls_usuzan.cpp \
    libsaki/girls_util_toki.cpp \
    libsaki/hand.cpp \
    libsaki/mount.cpp \
    libsaki/princess.cpp \
    libsaki/replay.cpp \
    libsaki/string_enum.cpp \
    libsaki/table.cpp \
    libsaki/tableview.cpp \
    libsaki/test.cpp \
    libsaki/ticketfolder.cpp \
    libsaki/tilecount.cpp \
    gui/p_client.cpp \
    gui/p_gen.cpp \
    gui/p_global.cpp \
    gui/p_image_provider.cpp \
    gui/p_port.cpp \
    gui/p_replay.cpp \
    gui/p_table.cpp \
    gui/p_table_local.cpp \
    gui/p_json_tcp.cpp \
    libsaki/rand.cpp \
    gui/p_image_settings.cpp



RESOURCES += qml.qrc \
    pic.qrc \
    font.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    libsaki/action.h \
    libsaki/ai_achiga.h \
    libsaki/ai_eisui.h \
    libsaki/ai.h \
    libsaki/ai_shiraitodai.h \
    libsaki/ai_senriyama.h \
    libsaki/ai_usuzan.h \
    libsaki/assume.h \
    libsaki/debug_cheat.h \
    libsaki/explain.h \
    libsaki/form.h \
    libsaki/gen.h \
    libsaki/girl.h \
    libsaki/girls_achiga.h \
    libsaki/girls_asakumi.h \
    libsaki/girls_eisui.h \
    libsaki/girls_himematsu.h \
    libsaki/girls_kiyosumi.h \
    libsaki/girls_miyamori.h \
    libsaki/girls_other.h \
    libsaki/girls_senriyama.h \
    libsaki/girls_shiraitodai.h \
    libsaki/girls_usuzan.h \
    libsaki/girls_util_toki.h \
    libsaki/hand.h \
    libsaki/meld.h \
    libsaki/mount.h \
    libsaki/pointinfo.h \
    libsaki/princess.h \
    libsaki/rand.h \
    libsaki/replay.h \
    libsaki/string_enum.h \
    libsaki/tablefocus.h \
    libsaki/table.h \
    libsaki/tableview.h \
    libsaki/tableobserver.h \
    libsaki/tableoperator.h \
    libsaki/test.h \
    libsaki/ticketfolder.h \
    libsaki/tilecount.h \
    libsaki/tile.h \
    libsaki/util.h \
    libsaki/who.h \
    gui/p_client.h \
    gui/p_gen.h \
    gui/p_global.h \
    gui/p_image_provider.h \
    gui/p_image_settings.h \
    gui/p_json_tcp.h \
    gui/p_port.h \
    gui/p_replay.h \
    gui/p_table.h \
    gui/p_table_local.h



DISTFILES += \
    android/AndroidManifest.xml \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradlew \
    android/res/values/libs.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew.bat \
    android/src/rolevax/sakilogy/ImagePickerActivity.java

OTHER_FILES += \
    qml/*.qml \
    qml/area/*.qml \
    qml/game/*.qml \
    qml/room/*.qml \
    qml/widget/*.qml \
    qml/js/*.js

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

MOC_DIR = ./moc
RCC_DIR = ./qrc
OBJECTS_DIR = ./obj
