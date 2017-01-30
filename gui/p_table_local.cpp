#include "p_table_local.h"
#include "p_port.h"

#include "libsaki/rand.h"
#include "libsaki/string_enum.h"
#include "libsaki/util.h"

#include <QDir>
#include <QFile>
#include <QDateTime>
#include <QStandardPaths>

#include <QJsonDocument>
#include <QJsonObject>

#include <sstream>
#include <fstream>
#include <iostream>
#include <cassert>

PTableLocal::PTableLocal(QObject *parent)
    : QObject(parent)
    , TableOperator(saki::Who(saki::Who::HUMAN))
    , mTable(nullptr)
{
}

void PTableLocal::onTableStarted(const saki::Table &table, uint32_t seed)
{
    (void) seed;
    onPointsChanged(table);
}

void PTableLocal::onFirstDealerChoosen(saki::Who initDealer)
{
    emit firstDealerChoosen(initDealer.index());
}

void PTableLocal::onRoundStarted(int round, int extra, saki::Who dealer,
                            bool al, int deposit, uint32_t seed)
{
    std::cout << 'r' << round << '.' << extra << " dl" << dealer.index()
              << " al" << al << " dp" << deposit
              << ' ' << seed << std::endl;

    emit roundStarted(round, extra, dealer.index(), al, deposit);
}

void PTableLocal::onCleaned()
{
    emit cleaned();
}

void PTableLocal::onDiced(const saki::Table &table, int die1, int die2)
{
    if (!table.getDealer().human())
        emit justPause(700);
    emit diced(die1, die2);
}

void PTableLocal::onDealt(const saki::Table &table)
{
    emit dealt(createTilesVar(table.getHand(mSelf).closed()));
}

void PTableLocal::onFlipped(const saki::Table &table)
{
    emit flipped(createTileVar(table.getMount().getDrids().back()));
}

void PTableLocal::onDrawn(const saki::Table &table, saki::Who who)
{
    const saki::T37 &in = table.getHand(who).drawn();
    emit drawn(who.index(), createTileVar(in), table.duringKan());
}

void PTableLocal::onDiscarded(const saki::Table &table, bool spin)
{
    saki::Who who = table.getFocus().who();
    const saki::T37 &outTile = table.getFocusTile();
    bool lay = table.lastDiscardLay();

    if (!who.human())
        emit justPause(500);
    emit discarded(who.index(), createTileVar(outTile, lay), spin);
}

void PTableLocal::onRiichiCalled(saki::Who who)
{
    if (!who.human())
        emit justPause(500);
    emit riichiCalled(who.index());
}

void PTableLocal::onRiichiEstablished(saki::Who who)
{
    emit riichiEstablished(who.index());
}

void PTableLocal::onBarked(const saki::Table &table, saki::Who who,
                      const saki::M37 &bark, bool spin)
{
    int fromWhom = bark.isCpdmk() ? table.getFocus().who().index() : -1;
    if (!who.human())
        emit justPause(500);
    emit barked(who.index(), fromWhom, QString(stringOf(bark.type())),
                createBarkVar(bark), spin);
}

void PTableLocal::onRoundEnded(const saki::Table &table, saki::RoundResult result,
                          const std::vector<saki::Who> &openers, saki::Who gunner,
                          const std::vector<saki::Form> &forms)
{
    using RR = saki::RoundResult;

    QVariantList openersList;
    QVariantList formsList;
    QVariantList handsList;

    for (saki::Who who : openers) {
        openersList << who.index();

        const saki::Hand &hand = table.getHand(who);

        QVariantMap handMap;
        handMap.insert("closed", createTilesVar(hand.closed()));
        handMap.insert("barks", createBarksVar(hand.barks()));

        if (result == RR::TSUMO)
            handMap.insert("pick", createTileVar(hand.drawn(), true));
        else if (result == RR::RON || result == RR::SCHR)
            handMap.insert("pick", createTileVar(table.getFocusTile(), true));

        handsList << handMap;
    }

    for (size_t i = 0; i < forms.size(); i++) {
        const saki::Form &form = forms[i];
        formsList << createFormVar(form.spell().c_str(), form.charge().c_str());
    }

    if ((result == RR::TSUMO || result == RR::RON || result == RR::SCHR)
            && (openers.size() > 1 || !openers[0].human())) {
        emit justPause(700);
    }

    emit roundEnded(QString(stringOf(result)),
                    openersList, gunner.nobody() ? -1 : gunner.index(),
                    handsList, formsList,
                    createTilesVar(table.getMount().getUrids()));
}

void PTableLocal::onPointsChanged(const saki::Table &table)
{
    const std::array<int, 4> &points = table.getPoints();
    QVariantList list;
    for (int i = 0; i < 4; i++)
        list << points[i];
    emit pointsChanged(QVariant::fromValue(list));
}

void PTableLocal::onTableEnded(const std::array<saki::Who, 4> &rank,
                          const std::array<int, 4> &scores)
{
    QVariantList rankList, pointsList;
    for (int i = 0; i < 4; i++) {
        rankList << rank[i].index();
        pointsList << scores[i];
    }
    emit tableEnded(rankList, pointsList);
}

void PTableLocal::onPoppedUp(const saki::Table &table, saki::Who who)
{
    emit poppedUp(QString::fromStdString(table.getGirl(who).popUpStr()));
}

void PTableLocal::onActivated(saki::Table &table)
{
    using AC = saki::ActCode;

    const saki::TableView view = table.getView(mSelf);

    if (table.riichiEstablished(mSelf) && view.iCanOnlySpin()) {
        emit justPause(500); // a little pause
        table.action(mSelf, saki::Action(AC::SPIN_OUT));
        return;
    }


    int focusWho;
    if (view.iCan(AC::CHII_AS_LEFT)
            || view.iCan(AC::CHII_AS_MIDDLE)
            || view.iCan(AC::CHII_AS_RIGHT)
            || view.iCan(AC::PON)
            || view.iCan(AC::DAIMINKAN)
            || view.iCan(AC::RON)) {
        focusWho = view.getFocus().who().index();
    } else {
        focusWho = -1;
    }

    QVariantMap map;

    if (view.iCan(AC::SWAP_OUT)) {
        map.insert(stringOf(AC::SWAP_OUT),
                   createSwapMask(table.getHand(mSelf).closed(), view.mySwappables()));
    }

    if (view.iCan(AC::ANKAN)) {
        map.insert(stringOf(AC::ANKAN), createTileStrsVar(view.myAnkanables()));
    }

    if (view.iCan(AC::KAKAN)) {
        QVariantList list;
        for (int barkId : view.myKakanables())
            list << barkId;
        map.insert(stringOf(AC::KAKAN), QVariant::fromValue(list));
    }

    if (view.iCan(AC::IRS_CHECK)) {
        const saki::Girl &girl = table.getGirl(mSelf);
        int prediceCount = girl.irsCheckCount();
        QVariantList list;
        for (int i = 0; i < prediceCount; i++)
            list << createIrsCheckRowVar(girl.irsCheckRow(i));
        map.insert(stringOf(AC::IRS_CHECK), QVariant::fromValue(list));
    }

    if (view.iCan(AC::IRS_RIVAL)) {
        const saki::Girl &girl = table.getGirl(mSelf);
        QVariantList list;
        for (int i = 0; i < 4; i++)
            if (girl.irsRivalMask()[i])
                list << i;
        map.insert(stringOf(AC::IRS_RIVAL), QVariant::fromValue(list));
    }

    static const AC just[] = {
        AC::PASS, AC::SPIN_OUT,
        AC::CHII_AS_LEFT, AC::CHII_AS_MIDDLE, AC::CHII_AS_RIGHT,
        AC::PON, AC::DAIMINKAN, AC::RIICHI,
        AC::RON, AC::TSUMO, AC::RYUUKYOKU,
        AC::END_TABLE, AC::NEXT_ROUND, AC::DICE, AC::IRS_CLICK
    };

    for (AC code : just)
        if (view.iCan(code))
            map.insert(stringOf(code), true);

    emit activated(QVariant::fromValue(map), focusWho);
}

void PTableLocal::start(const QVariant &girlIdsVar, const QVariant &gameRule,
                   int tempDelaer)
{
    QVariantList list = girlIdsVar.toList();
    std::array<int, 4> girlIds {
        list[0].toInt(), list[1].toInt(), list[2].toInt(), list[3].toInt()
    };

    assert(girlIds[0] == 0 || girlIds[0] != girlIds[1]);
    assert(girlIds[0] == 0 || girlIds[0] != girlIds[2]);
    assert(girlIds[0] == 0 || girlIds[0] != girlIds[3]);
    assert(girlIds[1] == 0 || girlIds[1] != girlIds[2]);
    assert(girlIds[1] == 0 || girlIds[1] != girlIds[3]);
    assert(girlIds[2] == 0 || girlIds[2] != girlIds[3]);

    saki::RuleInfo rule = readRuleJson(QJsonObject::fromVariantMap(gameRule.toMap()));

    std::array<int, 4> points {
        rule.returnLevel - rule.hill / 4,
        rule.returnLevel - rule.hill / 4,
        rule.returnLevel - rule.hill / 4,
        rule.returnLevel - rule.hill / 4,
    };

    for (int w = 1; w < 4; w++)
        mAis[w - 1].reset(saki::Ai::create(saki::Who(w), saki::Girl::Id(girlIds[w])));
    std::array<saki::TableOperator*, 4> operators {
        this, mAis.at(0).get(), mAis.at(1).get(), mAis.at(2).get()
    };

    std::vector<saki::TableObserver*> observers { this, &mReplay };

    mTable.reset(new saki::Table(points, girlIds, operators, observers,
                                 rule, saki::Who(tempDelaer)));
    mTable->start();
}

void PTableLocal::action(QString actStr, const QVariant &actArg)
{
    saki::Action action = makeAction(actStr, actArg);
    mTable->action(saki::Who(0), action);
}

void PTableLocal::saveRecord()
{
    QString path("user/replay");
    QDir().mkpath(path);

    QString datetime(QDateTime::currentDateTime().toString("yyMMdd_HHmm"));
    QString extension(".pai.json");
    int serial = 0;

    auto makeFilename = [&]() {
        return path + '/' + datetime + '_' + QString::number(serial++) + extension;
    };

    QString filename;
    // this loop is useless in most cases, but just to be robust.
    do {
        filename = makeFilename();
    } while(QFile(filename).exists());

    QJsonDocument doc(createReplayJson(mReplay));

    QFile file(filename);
    bool ok = file.open(QIODevice::WriteOnly | QIODevice::Text);
    assert(ok);

    file.write(doc.toJson(QJsonDocument::Compact));

    file.close();
}

saki::Action PTableLocal::makeAction(const QString &actStr, const QVariant &actArg)
{
    using ActCode = saki::ActCode;

    ActCode act = saki::actCodeOf(actStr.toStdString().c_str());
    switch (act) {
    case ActCode::SWAP_OUT:
    case ActCode::ANKAN:
        return saki::Action(act, saki::T37(actArg.toString().toLatin1().data()));
    case ActCode::CHII_AS_LEFT:
    case ActCode::CHII_AS_MIDDLE:
    case ActCode::CHII_AS_RIGHT:
    case ActCode::PON:
    case ActCode::KAKAN:
    case ActCode::IRS_CHECK:
    case ActCode::IRS_RIVAL:
        return saki::Action(act, actArg.toInt());
    default:
        return saki::Action(act);
    }
}


