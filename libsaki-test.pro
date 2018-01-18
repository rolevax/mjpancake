TEMPLATE = app

CONFIG += c++11
CONFIG(release, debug|release): DEFINES += NDEBUG

SOURCES += main_test.cpp \
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
    libsaki/table/table_tester.cpp \
    libsaki/table/table_view_hand.cpp \
    libsaki/table/table_view_real.cpp \
    libsaki/test/test.cpp \
    libsaki/util/rand.cpp \
    libsaki/util/string_enum.cpp

# Default rules for deployment.
include(deployment.pri)

MOC_DIR = ./moc
RCC_DIR = ./qrc
OBJECTS_DIR = ./obj

HEADERS += \
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
    libsaki/form/rule.h \
    libsaki/form/parsed.h \
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
    libsaki/table/table_focus.h \
    libsaki/table/table_observer.h \
    libsaki/table/table_view.h \
    libsaki/table/table_env_stub.h \
    libsaki/table/table_tester.h \
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
    libsaki/util/string_enum.h

mac {
    QMAKE_CXXFLAGS_WARN_ON = -Wall -Wextra -Wno-missing-braces
}
