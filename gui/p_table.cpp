#include "gui/p_table.h"
#include "gui/pport.h"

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
    std::vector<saki::T37> initSaki {
        1_p, 2_p, 2_p, 2_p, 3_p, 5_p, 2_f, 2_y, 3_y, 3_s, 9_s, 1_m, 4_m
    };
    std::vector<saki::T37> initYumi {
        3_m, 9_m, 9_p, 9_p, 9_p, 1_s, 9_s, 2_f, 3_f, 4_f, 1_y, 2_y, 3_y
    };
    std::vector<saki::T37> initKana {
        2_s, 2_s, 5_s, 7_s, 9_s, 2_m, 5_m, 8_m, 8_m, 7_p, 8_p, 8_p, 4_f
    };
    std::vector<saki::T37> initKoromo {
        2_m, 4_m, 6_m, 7_m, 9_m, 1_s, 6_s, 9_s, 4_p, 6_p, 9_p, 1_y, 2_y
    };
    QVariantList inits;
    inits << createTilesVar(initSaki) << createTilesVar(initYumi)
          << createTilesVar(initKana) << createTilesVar(initKoromo);
    emit dealt(inits);
    emit flipped(createTileVar(1_f));

    auto inOut = [this](int w, const saki::T37 &tin, const saki::T37 &tout,
                        int inPos, int outPos) {
        emit drawn(w, createTileVar(tin), false);
        if (w == 0)
            emit justPause(500);
        emit discarded(w, createTileVar(tout), outPos, inPos);
    };

    inOut(1, 6_s, 3_f, 0, 0);
    inOut(2, 7_s, 4_f, 0, 0);
    inOut(3, 3_y, 9_s, 0, 0);
    inOut(0, 4_p, 1_m, 5, 11);

    inOut(1, 7_s, 6_s, 0, 0);
    inOut(2, 1_f, 1_f, -1, 13);
    inOut(3, 3_y, 9_p, 0, 0);
    inOut(0, 3_p, 9_s, 5, 11);

    inOut(1, 4_s, 7_s, 0, 0);
    inOut(2, 3_y, 3_y, -1, 13);
    inOut(3, 3_y, 1_s, 0, 0);
    inOut(0, 1_p, 3_s, 0, 11);

    inOut(1, 1_y, 4_s, 0, 0);
    inOut(2, 3_y, 2_m, 0, 0);
    inOut(3, 3_y, 1_y, 0, 0);
    inOut(0, 3_p, 4_m, 5, 12);

    inOut(1, 1_m, 1_y, 0, 0);
    inOut(2, 3_y, 9_s, 0, 0);
    inOut(3, 3_y, 2_y, 0, 0);
    inOut(0, 2_p, 2_y, 5, 11);

    inOut(1, 6_m, 6_m, -1, 13);
    inOut(2, 3_y, 5_m, 0, 0);
    inOut(3, 3_y, 8_s, -1, 13);
    inOut(0, 1_p, 3_y, 1, 12);

    inOut(1, 7_m, 7_m, -1, 13);
    inOut(2, 3_y, 5_s, 0, 0);
    inOut(3, 3_y, 9_m, 0, 0);
    inOut(0, 3_p, 2_f, 9, 12);

    inOut(1, 3_s, 3_s, -1, 13);
    inOut(2, 7_p, 7_p, -1, 13);
    inOut(3, 1_p, 1_p, -1, 13);

    saki::M37 kan1 = saki::M37::daiminkan(1_p, 1_p, 1_p, 1_p, 0);
    saki::M37 kan2 = saki::M37::ankan(2_p, 2_p, 2_p, 2_p);
    saki::M37 kan3 = saki::M37::ankan(3_p, 3_p, 3_p, 3_p);

    emit justPause(700);
    emit barked(0, 3, QString(saki::stringOf(kan1.type())), 2, -1, createBarkVar(kan1));
    emit drawn(0, createTileVar(4_p), true);

    emit justPause(700);
    emit barked(0, -1, QString(saki::stringOf(kan2.type())), 2, 5, createBarkVar(kan2));
    emit flipped(createTileVar(8_s));
    emit flipped(createTileVar(3_y));
    emit drawn(0, createTileVar(4_p), true);

    emit justPause(700);
    emit barked(0, -1, QString(saki::stringOf(kan3.type())), 2, 1, createBarkVar(kan3));
    emit flipped(createTileVar(2_f));
    emit drawn(0, createTileVar(0_p), true);
}



