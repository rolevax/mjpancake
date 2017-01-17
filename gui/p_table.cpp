#include "gui/p_table.h"
#include "gui/p_port.h"

#include "libsaki/string_enum.h"
#include "libsaki/util.h"

#include <QEventLoop>

PTable::PTable(QObject *parent)
    : QObject(parent)
{
}

PTable::~PTable()
{
    workThread.quit();
    workThread.wait();
}

void PTable::startLocal(const QVariant &girlIdsVar, const QVariant &gameRule,
                              int tempDealer)
{
    PTableLocal *table = new PTableLocal;
    table->moveToThread(&workThread);
    workThread.start();

    connect(&workThread, &QThread::finished, table, &PTableLocal::deleteLater);

    connect(this, &PTable::action, table, &PTableLocal::action);
    connect(this, &PTable::saveRecord, table, &PTableLocal::saveRecord);

    connect(table, &PTableLocal::firstDealerChoosen,
            this, &PTable::firstDealerChoosen);
    connect(table, &PTableLocal::roundStarted, this, &PTable::roundStarted);
    connect(table, &PTableLocal::cleaned, this, &PTable::cleaned);
    connect(table, &PTableLocal::diced, this, &PTable::diced);
    connect(table, &PTableLocal::dealt, this, &PTable::dealt);
    connect(table, &PTableLocal::flipped, this, &PTable::flipped);
    connect(table, &PTableLocal::drawn, this, &PTable::drawn);
    connect(table, &PTableLocal::discarded, this, &PTable::discarded);
    connect(table, &PTableLocal::riichied, this, &PTable::riichied);
    connect(table, &PTableLocal::riichiPassed, this, &PTable::riichiPassed);
    connect(table, &PTableLocal::barked, this, &PTable::barked);
    connect(table, &PTableLocal::roundEnded, this, &PTable::roundEnded);
    connect(table, &PTableLocal::pointsChanged, this, &PTable::pointsChanged);
    connect(table, &PTableLocal::tableEnded, this, &PTable::tableEnded);
    connect(table, &PTableLocal::poppedUp, this, &PTable::poppedUp);
    connect(table, &PTableLocal::justPause, this, &PTable::justPause);
    connect(table, &PTableLocal::activated, this, &PTable::activated);

    table->start(girlIdsVar, gameRule, tempDealer);
}

void PTable::startOnline(PClient *client)
{
    assert(client != nullptr);

    connect(this, &PTable::action, client, &PClient::action);

    connect(client, &PClient::activated, this, &PTable::activated);

    client->sendReady();
}

void PTable::startSample()
{
    using namespace saki::tiles37;

    QVariantList list;
    list << 105700 << 90300 << 35800 << 168200;
    emit pointsChanged(list);
    emit cleaned();
    emit roundStarted(7, 0, 1, true, 0);
    emit justPause(1600);
    emit diced(1, 1);
    std::vector<saki::T37> init {
        1_p, 2_p, 2_p, 2_p, 3_p, 5_p, 2_f, 2_y, 3_y, 3_s, 9_s, 1_m, 4_m
    };
    emit dealt(createTilesVar(init));
    emit flipped(createTileVar(1_f));

    auto myInOut = [this](const saki::T37 &tin, const saki::T37 &tout, int outPos) {
        emit drawn(0, createTileVar(tin), false);
        emit justPause(500);
        emit justSetOutPos(outPos);
        emit discarded(0, createTileVar(tout), false);
    };

    auto oppoOut = [this](int w, const saki::T37 &tout, bool spin) {
        emit drawn(w, QVariant(), false);
        emit discarded(w, createTileVar(tout), spin);
    };

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

    saki::M37 kan1 = saki::M37::daiminkan(1_p, 1_p, 1_p, 1_p, 0);
    saki::M37 kan2 = saki::M37::ankan(2_p, 2_p, 2_p, 2_p);
    saki::M37 kan3 = saki::M37::ankan(3_p, 3_p, 3_p, 3_p);

    emit justPause(700);
    emit barked(0, 3, QString(saki::stringOf(kan1.type())), createBarkVar(kan1), false);
    emit drawn(0, createTileVar(4_p), true);

    emit justPause(700);
    emit barked(0, -1, QString(saki::stringOf(kan2.type())), createBarkVar(kan2), false);
    emit flipped(createTileVar(8_s));
    emit flipped(createTileVar(3_y));
    emit drawn(0, createTileVar(4_p), true);

    emit justPause(700);
    emit barked(0, -1, QString(saki::stringOf(kan3.type())), createBarkVar(kan3), false);
    emit flipped(createTileVar(2_f));
    emit drawn(0, createTileVar(0_p), true);
}



