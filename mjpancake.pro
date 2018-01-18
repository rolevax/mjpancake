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
exists($$PWD/.official): DEFINES += PANCAKE_OFFICIAL

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
    libsaki/ai/ai_achiga_kuro.cpp \
    libsaki/ai/ai_eisui_hatsumi.cpp \
    libsaki/ai/ai_eisui_kasumi.cpp \
    libsaki/ai/ai_kiyosumi_nodoka.cpp \
    libsaki/ai/ai_miyamori_toyone.cpp \
    libsaki/ai/ai_shiraitodai_awai.cpp \
    libsaki/ai/ai_shiraitodai_seiko.cpp \
    libsaki/ai/ai_shiraitodai_takami.cpp \
    libsaki/ai/ai_stub.cpp \
    libsaki/ai/ai_usuzan_sawaya.cpp \
    libsaki/app/gen.cpp \
    libsaki/app/replay.cpp \
    libsaki/app/table_msg.cpp \
    libsaki/app/table_server.cpp \
    libsaki/app/table_server_ai3.cpp \
    libsaki/form/explain.cpp \
    libsaki/form/form.cpp \
    libsaki/form/form_gb.cpp \
    libsaki/form/hand.cpp \
    libsaki/form/parsed.cpp \
    libsaki/form/tile_count.cpp \
    libsaki/girl/achiga_ako.cpp \
    libsaki/girl/achiga_kuro.cpp \
    libsaki/girl/achiga_yuu.cpp \
    libsaki/girl/eisui_hatsumi.cpp \
    libsaki/girl/eisui_kasumi.cpp \
    libsaki/girl/himematsu_kyouko.cpp \
    libsaki/girl/himematsu_suzu.cpp \
    libsaki/girl/kiyosumi_nodoka.cpp \
    libsaki/girl/kiyosumi_yuuki.cpp \
    libsaki/girl/miyamori_toyone.cpp \
    libsaki/girl/rinkai_huiyu.cpp \
    libsaki/girl/senriyama_sera.cpp \
    libsaki/girl/senriyama_toki.cpp \
    libsaki/girl/shiraitodai_awai.cpp \
    libsaki/girl/shiraitodai_seiko.cpp \
    libsaki/girl/shiraitodai_sumire.cpp \
    libsaki/girl/shiraitodai_takami.cpp \
    libsaki/girl/shiraitodai_teru.cpp \
    libsaki/girl/usuzan_sawaya.cpp \
    libsaki/girl/x_kazue.cpp \
    libsaki/girl/x_kyouka.cpp \
    libsaki/girl/x_rio.cpp \
    libsaki/girl/x_shino.cpp \
    libsaki/girl/x_uta.cpp \
    libsaki/girl/x_yue.cpp \
    libsaki/girl/x_yui.cpp \
    libsaki/table/choices.cpp \
    libsaki/table/girl.cpp \
    libsaki/table/mount.cpp \
    libsaki/table/princess.cpp \
    libsaki/table/table.cpp \
    libsaki/table/table_env_stub.cpp \
    libsaki/table/table_tester.cpp \
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
    libsaki/ai/ai_achiga_kuro.h \
    libsaki/ai/ai_eisui_hatsumi.h \
    libsaki/ai/ai_eisui_kasumi.h \
    libsaki/ai/ai_kiyosumi_nodoka.h \
    libsaki/ai/ai_miyamori_toyone.h \
    libsaki/ai/ai_shiraitodai_awai.h \
    libsaki/ai/ai_shiraitodai_seiko.h \
    libsaki/ai/ai_shiraitodai_takami.h \
    libsaki/ai/ai_stub.h \
    libsaki/ai/ai_usuzan_sawaya.h \
    libsaki/app/gen.h \
    libsaki/app/replay.h \
    libsaki/app/table_msg.h \
    libsaki/app/table_server.h \
    libsaki/app/table_server_ai3.h \
    libsaki/form/explain.h \
    libsaki/form/form.h \
    libsaki/form/form_ctx.h \
    libsaki/form/form_gb.h \
    libsaki/form/hand.h \
    libsaki/form/parsed.h \
    libsaki/form/rule.h \
    libsaki/form/tile_count.h \
    libsaki/girl/achiga_ako.h \
    libsaki/girl/achiga_kuro.h \
    libsaki/girl/achiga_yuu.h \
    libsaki/girl/eisui_hatsumi.h \
    libsaki/girl/eisui_kasumi.h \
    libsaki/girl/himematsu_kyouko.h \
    libsaki/girl/himematsu_suzu.h \
    libsaki/girl/kiyosumi_nodoka.h \
    libsaki/girl/kiyosumi_yuuki.h \
    libsaki/girl/miyamori_toyone.h \
    libsaki/girl/rinkai_huiyu.h \
    libsaki/girl/senriyama_sera.h \
    libsaki/girl/senriyama_toki.h \
    libsaki/girl/shiraitodai_awai.h \
    libsaki/girl/shiraitodai_seiko.h \
    libsaki/girl/shiraitodai_sumire.h \
    libsaki/girl/shiraitodai_takami.h \
    libsaki/girl/shiraitodai_teru.h \
    libsaki/girl/usuzan_sawaya.h \
    libsaki/girl/x_kazue.h \
    libsaki/girl/x_kyouka.h \
    libsaki/girl/x_rio.h \
    libsaki/girl/x_shino.h \
    libsaki/girl/x_uta.h \
    libsaki/girl/x_yue.h \
    libsaki/girl/x_yui.h \
    libsaki/table/choices.h \
    libsaki/table/girl.h \
    libsaki/table/kan_ctx.h \
    libsaki/table/mount.h \
    libsaki/table/princess.h \
    libsaki/table/table.h \
    libsaki/table/table_env.h \
    libsaki/table/table_env_stub.h \
    libsaki/table/table_event.h \
    libsaki/table/table_focus.h \
    libsaki/table/table_observer.h \
    libsaki/table/table_tester.h \
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
    libsaki/util/int_iter.h \
    libsaki/util/misc.h \
    libsaki/util/rand.h \
    libsaki/util/stactor.h \
    libsaki/util/string_enum.h \
    libsaki/util/version.h \
    libsaki/table/irs_ctrl.h



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


