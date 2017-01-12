#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QQuickView>

#include "gui/ptablethread.h"
#include "gui/pgen.h"
#include "gui/preplay.h"
#include "gui/pimageprovider.h"
#include "gui/psettings.h"
#include "gui/pglobal.h"



int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QIcon icon(":/pic/icon/icon.ico");
    app.setWindowIcon(icon);

    QQmlApplicationEngine engine;

    engine.addImageProvider(QString("impro"), new PImageProvider);

    qmlRegisterType<PTableThread>("rolevax.sakilogy", 1, 0, "PTable");
//    qmlRegisterType<PGen>("rolevax.sakilogy", 1, 0, "PGen");
    qmlRegisterType<PReplay>("rolevax.sakilogy", 1, 0, "PReplay");
    qmlRegisterType<PSettings>("rolevax.sakilogy", 1, 0, "PSettings");

    qmlRegisterSingletonType<PGlobal>("rolevax.sakilogy", 1, 0, "PGlobal",
                                      pGlobalSingletonProvider);

    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));

    return app.exec();
}
