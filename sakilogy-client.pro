TEMPLATE = app

QT += qml quick widgets network

android: QT += androidextras

CONFIG += c++11
CONFIG(release, debug|release): DEFINES += NDEBUG

SOURCES += main.cpp \
    libsaki/action.cpp \
    libsaki/ai.cpp \
    libsaki/form.cpp \
    libsaki/girl.cpp \
    libsaki/hand.cpp \
    libsaki/mount.cpp \
    libsaki/table.cpp \
    libsaki/myrand.cpp \
    libsaki/gen.cpp \
    gui/pgen.cpp \
    gui/pport.cpp \
    libsaki/tilecount.cpp \
    libsaki/explain.cpp \
    libsaki/princess.cpp \
    libsaki/girls_shiraitodai.cpp \
    libsaki/girls_kiyosumi.cpp \
    libsaki/girls_asakumi.cpp \
    libsaki/girls_achiga.cpp \
    libsaki/girls_senriyama.cpp \
    libsaki/girls_himematsu.cpp \
    gui/pimageprovider.cpp \
    gui/psettings.cpp \
    gui/pglobal.cpp \
    libsaki/ai_senriyama.cpp \
    libsaki/skillpop.cpp \
    libsaki/ai_achiga.cpp \
    libsaki/ai_shiraitodai.cpp \
    libsaki/girls_other.cpp \
    libsaki/girls_usuzan.cpp \
    libsaki/ai_usuzan.cpp \
    libsaki/replay.cpp \
    gui/preplay.cpp \
    libsaki/girls_eisui.cpp \
    libsaki/girls_miyamori.cpp \
    libsaki/ai_eisui.cpp \
    libsaki/string_enum.cpp \
    libsaki/tableview.cpp \
    libsaki/test.cpp \
    libsaki/girls_util_toki.cpp \
    libsaki/ticketfolder.cpp \
    gui/p_table_local.cpp \
    gui/p_client.cpp \
    gui/p_table.cpp

RESOURCES += qml.qrc \
    pic.qrc \
    font.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    gui/pgen.h \
    gui/pport.h \
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
    gui/pimageprovider.h \
    gui/psettings.h \
    gui/pglobal.h \
    libsaki/ai_senriyama.h \
    libsaki/skillpop.h \
    libsaki/ai_achiga.h \
    libsaki/ai_shiraitodai.h \
    libsaki/girls_other.h \
    libsaki/girls_usuzan.h \
    libsaki/ai_usuzan.h \
    libsaki/replay.h \
    gui/preplay.h \
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
    libsaki/ticketfolder.h \
    libsaki/debug_cheat.h \
    gui/p_table_local.h \
    gui/p_client.h \
    gui/p_table.h

DISTFILES += \
    android/AndroidManifest.xml \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradlew \
    android/res/values/libs.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew.bat \
    android/src/rolevax/sakilogy/ImagePickerActivity.java \

OTHER_FILES += \
    qml/main.qml \
    qml/Room.qml \
    qml/RoomHelp.qml \
    qml/RoomHelpOp.qml \
    qml/RoomHelpRules.qml \
    qml/RoomHelpFaq.qml \
    qml/RoomHelpGirls.qml \
    qml/RoomReplay.qml \
    qml/RoomGameFree.qml \
    qml/RoomGen.qml \
    qml/RoomSettings.qml \
    qml/RoomClient.qml \
    qml/RuleConfig.qml \
    qml/Table.qml \
    qml/Game.qml \
    qml/Tile.qml \
    qml/TileStand.qml \
    qml/PlayerControl.qml \
    qml/OppoControl.qml \
    qml/River.qml \
    qml/RiverRow.qml \
    qml/Middle.qml \
    qml/MiddleNameBar.qml \
    qml/IrsCheckBox.qml \
    qml/ResultWindow.qml \
    qml/PointBoard.qml \
    qml/PointItem.qml \
    qml/LogBox.qml \
    qml/GirlPhoto.qml \
    qml/GirlBox.qml \
    qml/Buddon.qml \
    qml/Buzzon.qml \
    qml/GomboBuddon.qml \
    qml/GomboMenu.qml \
    qml/GomboToggle.qml \
    qml/FloatButton.qml \
    qml/ActionButton.qml \
    qml/ActionButtonBar.qml \
    qml/Texd.qml \
    qml/TexdInput.qml \
    qml/AnimadionBuffer.qml \
    qml/spell.js \
    qml/girlnames.js \

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

MOC_DIR = ./moc
RCC_DIR = ./qrc
OBJECTS_DIR = ./obj
