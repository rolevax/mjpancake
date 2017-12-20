#include "p_table.h"
#include "p_table_local.h"
#include "p_client.h"
#include "p_port.h"

#include "libsaki/util/string_enum.h"
#include "libsaki/util/misc.h"

#include <QEventLoop>



using namespace saki;



PTable::PTable(QObject *parent)
    : QObject(parent)
{
}

PTable::~PTable()
{
    clearLogicFeeds();
}

void PTable::startPrac(const int &girlId)
{
    clearLogicFeeds();
    mOnline = false;

    PTableLocal *table = new PTableLocal;
    table->moveToThread(&mWorkThread);
    mWorkThread.start();

    connect(&mWorkThread, &QThread::finished, table, &PTableLocal::deleteLater);

    connect(this, &PTable::action, table, &PTableLocal::action);
    connect(table, &PTableLocal::tableEvent, this, &PTable::tableEvent);

    table->startPrac(girlId);
}

void PTable::startLocal(const QVariant &girlIdsVar, const QVariant &gameRule,
                        int tempDealer)
{
    clearLogicFeeds();
    mOnline = false;

    PTableLocal *table = new PTableLocal;
    table->moveToThread(&mWorkThread);
    mWorkThread.start();

    connect(&mWorkThread, &QThread::finished, table, &PTableLocal::deleteLater);

    connect(this, &PTable::action, table, &PTableLocal::action);
    connect(this, &PTable::saveRecord, table, &PTableLocal::saveRecord);
    connect(table, &PTableLocal::tableEvent, this, &PTable::tableEvent);

    table->start(girlIdsVar, gameRule, tempDealer);
}

void PTable::startOnline(PClient *client)
{
    assert(client != nullptr);

    clearLogicFeeds();
    mOnline = true;

    connect(this, &PTable::action, client, &PClient::action);
    connect(client, &PClient::tableEvent, this, &PTable::tableEvent);
}

void PTable::startSample()
{
    clearLogicFeeds();
    mOnline = false;

    std::vector<std::pair<Event, const char *>> scene {
        { PointsChanged, R"({"points":[105700,90300,35800,168200]})" },
        { Cleaned, "" },
        { RoundStarted, R"({"round":7,"extra":0,"dealer":1,"allLast":true,"deposit":0})" },
        { JustPause, R"({"ms":1600})" },
        { Diced, R"({"die1":1,"die2":1})" },
        { Dealt, R"({"init":["1p","2p","2p","2p","3p","5p","2f","2y","3y","3s","9s","1m","4m"]})" },
        { Flipped, R"({"newIndic":"1f"})" },
    };

    for (const auto &pair : scene) {
        QJsonDocument doc = QJsonDocument::fromJson(QString(pair.second).toUtf8());
        QVariantMap args = doc.object().toVariantMap();
        emit tableEvent(pair.first, args);
    }

    // *INDENT-OFF*
    auto myInOut = [this](const T37 &tin, const T37 &tout, int outPos) {
        emit tableEvent(Drawn, QVariantMap { { "who", 0 }, { "tile", tin.str() } });
        emit tableEvent(JustPause, QVariantMap { { "ms", 300 } });
        emit tableEvent(JustSetOutPos, QVariantMap { { "outPos", outPos } });
        emit tableEvent(Discarded, QVariantMap { { "who", 0 }, { "tile", tout.str() } });
    };

    auto oppoOut = [this](int w, const T37 &tout, bool spin) {
        emit tableEvent(Drawn, QVariantMap { { "who", w } });
        emit tableEvent(JustPause, QVariantMap { { "ms", 300 } });
        QVariantMap args { { "who", w }, { "tile", tout.str() }, { "spin", spin } };
        emit tableEvent(Discarded, args);
    };
    // *INDENT-ON*

    using namespace tiles37;

    oppoOut(1, 3_f, false);
    oppoOut(2, 4_f, false);
    oppoOut(3, 9_s, false);
    myInOut(4_p, 1_m, 11);

    oppoOut(1, 6_s, false);
    oppoOut(2, 1_f, true);
    oppoOut(3, 9_p, false);
    myInOut(3_p, 9_s, 11);

    oppoOut(1, 7_s, false);
    oppoOut(2, 3_y, true);
    oppoOut(3, 1_s, false);
    myInOut(1_p, 3_s, 11);

    oppoOut(1, 4_s, false);
    oppoOut(2, 2_m, false);
    oppoOut(3, 1_y, false);
    myInOut(3_p, 4_m, 12);

    oppoOut(1, 1_y, false);
    oppoOut(2, 9_s, false);
    oppoOut(3, 2_y, false);
    myInOut(2_p, 2_y, 11);

    oppoOut(1, 6_m, true);
    oppoOut(2, 5_m, false);
    oppoOut(3, 8_s, true);
    myInOut(1_p, 3_y, 12);

    oppoOut(1, 7_m, true);
    oppoOut(2, 5_s, false);
    oppoOut(3, 9_m, false);
    myInOut(3_p, 2_f, 12);

    oppoOut(1, 3_s, true);
    oppoOut(2, 7_p, true);
    oppoOut(3, 1_p, true);

    M37 kan1 = M37::daiminkan(1_p, 1_p, 1_p, 1_p, 0);
    M37 kan2 = M37::ankan(2_p, 2_p, 2_p, 2_p);
    M37 kan3 = M37::ankan(3_p, 3_p, 3_p, 3_p);

    emit tableEvent(JustPause, QVariantMap { { "ms", 500 } });
    QVariantMap args1 {
        { "who", 0 },
        { "fromWhom", 3 },
        { "actStr", QString(util::stringOf(kan1.type())) },
        { "bark", createBarkVar(kan1) }
    };
    emit tableEvent(Barked, args1);
    emit tableEvent(Drawn, QVariantMap { { "who", 0 }, { "tile", "4p" }, { "rinshan", true } });

    emit tableEvent(JustPause, QVariantMap { { "ms", 500 } });
    QVariantMap args2 {
        { "who", 0 },
        { "fromWhom", -1 },
        { "actStr", QString(util::stringOf(kan2.type())) },
        { "bark", createBarkVar(kan2) }
    };
    emit tableEvent(Barked, args2);
    emit tableEvent(Flipped, QVariantMap { { "newIndic", "8s" } });
    emit tableEvent(Flipped, QVariantMap { { "newIndic", "3y" } });
    emit tableEvent(Drawn, QVariantMap { { "who", 0 }, { "tile", "4p" }, { "rinshan", true } });

    emit tableEvent(JustPause, QVariantMap { { "ms", 500 } });
    QVariantMap args3 {
        { "who", 0 },
        { "fromWhom", -1 },
        { "actStr", QString(util::stringOf(kan3.type())) },
        { "bark", createBarkVar(kan3) }
    };
    emit tableEvent(Barked, args3);
    emit tableEvent(Flipped, QVariantMap { { "newIndic", "2f" } });
    emit tableEvent(Drawn, QVariantMap { { "who", 0 }, { "tile", "0p" }, { "rinshan", true } });
}

bool PTable::online() const
{
    return mOnline;
}

void PTable::clearLogicFeeds()
{
    // clear table-local
    if (mWorkThread.isRunning()) {
        mWorkThread.quit();
        mWorkThread.wait();
    }
}
