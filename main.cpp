#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QQuickView>
#include <QTextCodec>

#include "gui/p_table.h"
#include "gui/p_gen.h"
#include "gui/p_parse.h"
#include "gui/p_replay.h"
#include "gui/p_image_provider.h"
#include "gui/p_image_settings.h"
#include "gui/p_global.h"
#include "gui/p_client.h"
#include "gui/p_eff.h"
#include "gui/p_eff_gb.h"



int main(int argc, char *argv[])
{
#ifdef Q_OS_WIN
    // fix 'animation too fast' in some environment
    const QByteArray loopName = qgetenv("QSG_RENDER_LOOP");
    if (loopName.isEmpty())
        putenv("QSG_RENDER_LOOP=basic");

#endif

    QApplication app(argc, argv);

    QIcon icon(":/pic/icon/icon.ico");
    app.setWindowIcon(icon);

    QTextCodec *codec = QTextCodec::codecForName("UTF-8");
    QTextCodec::setCodecForLocale(codec);

    QQmlApplicationEngine engine;
    engine.addImageProvider(QString("impro"), new PImageProvider);

    qmlRegisterType<PTable>("rolevax.sakilogy", 1, 0, "PTable");
    qmlRegisterType<PParse>("rolevax.sakilogy", 1, 0, "PParse");
    qmlRegisterType<PGen>("rolevax.sakilogy", 1, 0, "PGen");
    qmlRegisterType<PReplay>("rolevax.sakilogy", 1, 0, "PReplay");
    qmlRegisterType<PImageSettings>("rolevax.sakilogy", 1, 0, "PImageSettings");
    qmlRegisterType<PEff>("rolevax.sakilogy", 1, 0, "PEff");
    qmlRegisterType<PEffGb>("rolevax.sakilogy", 1, 0, "PEffGb");

    qmlRegisterSingletonType<PGlobal>("rolevax.sakilogy", 1, 0, "PGlobal",
                                      pGlobalSingletonProvider);
    qmlRegisterSingletonType<PClient>("rolevax.sakilogy", 1, 0, "PClient",
                                      pClientSingletonProvider);

    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));

    return app.exec();
}
