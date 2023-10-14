TEMPLATE = app

QT += qml quick widgets network multimedia

android: QT += androidextras

CONFIG += c++1z
CONFIG(release, debug|release): DEFINES += NDEBUG
DEFINES += QT_DISABLE_DEPRECATED_UP_TO=0x050F00

# Please make the look-and-feel significantly different from
# the official version if you are releasing a MOD
#DEFINES += PANCAKE_OFFICIAL

HEADERS += \
    gui/p_client.h \
    gui/p_editor.h \
    gui/p_eff.h \
    gui/p_eff_gb.h \
    gui/p_gen.h \
    gui/p_girl_down.h \
    gui/p_global.h \
    gui/p_image_provider.h \
    gui/p_image_settings.h \
    gui/p_json_tcp.h \
    gui/p_parse.h \
    gui/p_port.h \
    gui/p_replay.h \
    gui/p_table.h \
    gui/p_table_env.h \
    gui/p_table_local.h

SOURCES += main.cpp \
    gui/p_client.cpp \
    gui/p_editor.cpp \
    gui/p_eff.cpp \
    gui/p_eff_gb.cpp \
    gui/p_gen.cpp \
    gui/p_girl_down.cpp \
    gui/p_global.cpp \
    gui/p_image_provider.cpp \
    gui/p_parse.cpp \
    gui/p_port.cpp \
    gui/p_replay.cpp \
    gui/p_table.cpp \
    gui/p_table_env.cpp \
    gui/p_table_local.cpp \
    gui/p_json_tcp.cpp \
    gui/p_image_settings.cpp

RESOURCES += qrc/qml.qrc \
    qrc/pic.qrc \
    qrc/font.qrc \
    qrc/sound.qrc \
    qrc/json.qrc

include(libsaki.pri)

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

android {
    DISTFILES += \
        android/AndroidManifest.xml \
        android/gradle/wrapper/gradle-wrapper.jar \
        android/gradlew \
        android/res/values/libs.xml \
        android/build.gradle \
        android/gradle/wrapper/gradle-wrapper.properties \
        android/gradlew.bat \
        android/src/rolevax/sakilogy/ImagePickerActivity.java
}

OTHER_FILES += \
    qrc/qml/*.qml \
    qrc/qml/area/*.qml \
    qrc/qml/game/*.qml \
    qrc/qml/room/*.qml \
    qrc/qml/widget/*.qml \
    qrc/qml/js/*.js

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

MOC_DIR = ./moc
RCC_DIR = ./qrc
OBJECTS_DIR = ./obj

contains(ANDROID_TARGET_ARCH,armeabi-v7a) {
    ANDROID_EXTRA_LIBS =
}

mac|android {
    QMAKE_CXXFLAGS_WARN_ON = -Wall -Wextra -Wno-missing-braces
}

ios {
    QMAKE_INFO_PLIST = ios/Info.plist
}

ANDROID_ABIS = armeabi-v7a
