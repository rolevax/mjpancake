TEMPLATE = app

format.target = formatted
linux: format.commands = (cd $$PWD; ./bin/format.linux.sh)
win32: format.commands = (cd $$PWD && .\bin\format.win.bat)
mac: format.commands = (cd $$PWD; ./bin/format.mac.sh)
format.depends =

QMAKE_EXTRA_TARGETS += format
PRE_TARGETDEPS = formatted

QT += qml quick widgets network multimedia

android: QT += androidextras

CONFIG += c++11
CONFIG(release, debug|release): DEFINES += NDEBUG

SOURCES += main.cpp \
    gui/p_client.cpp \
    gui/p_eff.cpp \
    gui/p_eff_gb.cpp \
    gui/p_gen.cpp \
    gui/p_global.cpp \
    gui/p_image_provider.cpp \
    gui/p_parse.cpp \
    gui/p_port.cpp \
    gui/p_replay.cpp \
    gui/p_table.cpp \
    gui/p_table_env.cpp \
    gui/p_table_local.cpp \
    gui/p_json_tcp.cpp \
    gui/p_image_settings.cpp \
    libsaki/ai/ai.cpp \
    libsaki/ai/ai_achiga.cpp \
    libsaki/ai/ai_eisui.cpp \
    libsaki/ai/ai_kiyosumi.cpp \
    libsaki/ai/ai_miyamori.cpp \
    libsaki/ai/ai_senriyama.cpp \
    libsaki/ai/ai_shiraitodai.cpp \
    libsaki/ai/ai_stub.cpp \
    libsaki/ai/ai_usuzan.cpp \
    libsaki/app/gen.cpp \
    libsaki/app/replay.cpp \
    libsaki/form/explain.cpp \
    libsaki/form/form.cpp \
    libsaki/form/form_gb.cpp \
    libsaki/form/hand.cpp \
    libsaki/form/parsed.cpp \
    libsaki/form/tile_count.cpp \
    libsaki/girl/girl.cpp \
    libsaki/girl/girls_achiga.cpp \
    libsaki/girl/girls_asakumi.cpp \
    libsaki/girl/girls_eisui.cpp \
    libsaki/girl/girls_himematsu.cpp \
    libsaki/girl/girls_kiyosumi.cpp \
    libsaki/girl/girls_miyamori.cpp \
    libsaki/girl/girls_other.cpp \
    libsaki/girl/girls_rinkai.cpp \
    libsaki/girl/girls_senriyama.cpp \
    libsaki/girl/girls_shiraitodai.cpp \
    libsaki/girl/girls_usuzan.cpp \
    libsaki/girl/girls_util_toki.cpp \
    libsaki/table/choices.cpp \
    libsaki/table/mount.cpp \
    libsaki/table/princess.cpp \
    libsaki/table/table.cpp \
    libsaki/table/table_env_stub.cpp \
    libsaki/table/table_view_hand.cpp \
    libsaki/table/table_view_real.cpp \
    libsaki/test/test.cpp \
    libsaki/util/rand.cpp \
    libsaki/util/string_enum.cpp



RESOURCES += qrc/qml.qrc \
    qrc/pic.qrc \
    qrc/font.qrc \
    qrc/sound.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    gui/p_client.h \
    gui/p_eff.h \
    gui/p_eff_gb.h \
    gui/p_gen.h \
    gui/p_global.h \
    gui/p_image_provider.h \
    gui/p_image_settings.h \
    gui/p_json_tcp.h \
    gui/p_parse.h \
    gui/p_port.h \
    gui/p_replay.h \
    gui/p_table.h \
    gui/p_table_env.h \
    gui/p_table_local.h \
    libsaki/ai/ai.h \
    libsaki/ai/ai_achiga.h \
    libsaki/ai/ai_eisui.h \
    libsaki/ai/ai_kiyosumi.h \
    libsaki/ai/ai_miyamori.h \
    libsaki/ai/ai_senriyama.h \
    libsaki/ai/ai_shiraitodai.h \
    libsaki/ai/ai_stub.h \
    libsaki/ai/ai_usuzan.h \
    libsaki/app/gen.h \
    libsaki/app/replay.h \
    libsaki/form/explain.h \
    libsaki/form/form.h \
    libsaki/form/form_ctx.h \
    libsaki/form/form_gb.h \
    libsaki/form/hand.h \
    libsaki/form/parsed.h \
    libsaki/form/rule.h \
    libsaki/form/tile_count.h \
    libsaki/girl/girl.h \
    libsaki/girl/girls_achiga.h \
    libsaki/girl/girls_asakumi.h \
    libsaki/girl/girls_eisui.h \
    libsaki/girl/girls_himematsu.h \
    libsaki/girl/girls_kiyosumi.h \
    libsaki/girl/girls_miyamori.h \
    libsaki/girl/girls_other.h \
    libsaki/girl/girls_rinkai.h \
    libsaki/girl/girls_senriyama.h \
    libsaki/girl/girls_shiraitodai.h \
    libsaki/girl/girls_usuzan.h \
    libsaki/girl/girls_util_toki.h \
    libsaki/table/choices.h \
    libsaki/table/kan_ctx.h \
    libsaki/table/mount.h \
    libsaki/table/princess.h \
    libsaki/table/table.h \
    libsaki/table/table_env.h \
    libsaki/table/table_env_stub.h \
    libsaki/table/table_focus.h \
    libsaki/table/table_observer.h \
    libsaki/table/table_operator.h \
    libsaki/table/table_view.h \
    libsaki/table/table_view_hand.h \
    libsaki/table/table_view_real.h \
    libsaki/test/test.h \
    libsaki/unit/action.h \
    libsaki/unit/comeld.h \
    libsaki/unit/meld.h \
    libsaki/unit/tile.h \
    libsaki/unit/who.h \
    libsaki/util/assume.h \
    libsaki/util/debug_cheat.h \
    libsaki/util/misc.h \
    libsaki/util/rand.h \
    libsaki/util/stactor.h \
    libsaki/util/string_enum.h \
    libsaki/util/version.h



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

mac {
    QMAKE_CXXFLAGS_WARN_ON = -Wall -Wextra -Wno-missing-braces
}

ios {
    QMAKE_INFO_PLIST = ios/Info.plist
}


