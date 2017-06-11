#include "p_table_local.h"
#include "p_port.h"
#include "p_global.h"

#include "libsaki/rand.h"
#include "libsaki/string_enum.h"
#include "libsaki/util.h"

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
    QVariantMap args;
    args["dealer"] = initDealer.index();
    emit tableEvent(PTable::FirstDealerChoosen, args);
}

void PTableLocal::onRoundStarted(int round, int extra, saki::Who dealer,
                            bool al, int deposit, uint32_t seed)
{
    std::cout << 'r' << round << '.' << extra << " dl" << dealer.index()
              << " al" << al << " dp" << deposit
              << ' ' << seed << std::endl;

    QVariantMap args;
    args["round"] = round;
    args["extra"] = extra;
    args["dealer"] = dealer.index();
    args["allLast"] = al;
    args["deposit"] = deposit;
    emit tableEvent(PTable::RoundStarted, args);
}

void PTableLocal::onCleaned()
{
    emit tableEvent(PTable::Cleaned, QVariantMap());
}

void PTableLocal::onDiced(const saki::Table &table, int die1, int die2)
{
    if (!table.getDealer().human())
        emitJustPause(700);

    QVariantMap args;
    args["die1"] = die1;
    args["die2"] = die2;
    emit tableEvent(PTable::Diced, args);
}

void PTableLocal::onDealt(const saki::Table &table)
{
    QVariantMap args;
    args["init"] = createTilesVar(table.getHand(mSelf).closed());
    emit tableEvent(PTable::Dealt, args);
}

void PTableLocal::onFlipped(const saki::Table &table)
{
    QVariantMap args;
    args["newIndic"] = createTileVar(table.getMount().getDrids().back());
    emit tableEvent(PTable::Flipped, args);
}

void PTableLocal::onDrawn(const saki::Table &table, saki::Who who)
{
    QVariantMap args;
    args["who"] = who.index();
    args["tile"] = createTileVar(table.getHand(who).drawn());
    args["rinshan"] = table.duringKan();
    emit tableEvent(PTable::Drawn, args);
}

void PTableLocal::onDiscarded(const saki::Table &table, bool spin)
{
    saki::Who who = table.getFocus().who();
    const saki::T37 &outTile = table.getFocusTile();
    bool lay = table.lastDiscardLay();

    if (!who.human())
        emitJustPause(300);

    QVariantMap args;
    args["who"] = who.index();
    args["tile"] = createTileVar(outTile, lay);
    args["spin"] = spin;
    emit tableEvent(PTable::Discarded, args);
}

void PTableLocal::onRiichiCalled(saki::Who who)
{
    if (!who.human())
        emitJustPause(300);

    QVariantMap args;
    args["who"] = who.index();
    emit tableEvent(PTable::RiichiCalled, args);
}

void PTableLocal::onRiichiEstablished(saki::Who who)
{
    QVariantMap args;
    args["who"] = who.index();
    emit tableEvent(PTable::RiichiEstablished, args);
}

void PTableLocal::onBarked(const saki::Table &table, saki::Who who,
                      const saki::M37 &bark, bool spin)
{
    int fromWhom = bark.isCpdmk() ? table.getFocus().who().index() : -1;
    if (!who.human())
        emitJustPause(500);

    QVariantMap args;
    args["who"] = who.index();
    args["fromWhom"] = fromWhom;
    args["actStr"] = QString(stringOf(bark.type()));
    args["bark"] = createBarkVar(bark);
    args["spin"] = spin;
    emit tableEvent(PTable::Barked, args);
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

        if (result == RR::TSUMO || result == RR::KSKP)
            handMap.insert("pick", createTileVar(hand.drawn()));
        else if (result == RR::RON || result == RR::SCHR)
            handMap.insert("pick", createTileVar(table.getFocusTile()));

        handsList << handMap;
    }

    for (size_t i = 0; i < forms.size(); i++) {
        const saki::Form &form = forms[i];
        formsList << createFormVar(form.spell().c_str(), form.charge().c_str());
    }

    if ((result == RR::TSUMO || result == RR::RON || result == RR::SCHR)
            && (openers.size() > 1 || !openers[0].human())) {
        emitJustPause(700);
    }


    QVariantMap args;
    args["result"] = QString(stringOf(result));
    args["openers"] = openersList;
    args["gunner"] = gunner.nobody() ? -1 : gunner.index();
    args["hands"] = handsList;
    args["forms"] = formsList;
    args["urids"] = createTilesVar(table.getMount().getUrids().range());
    emit tableEvent(PTable::RoundEnded, args);
}

void PTableLocal::onPointsChanged(const saki::Table &table)
{
    const std::array<int, 4> &points = table.getPoints();
    QVariantList list;
    for (int i = 0; i < 4; i++)
        list << points[i];

    QVariantMap args;
    args["points"] = list;
    emit tableEvent(PTable::PointsChanged, args);
}

void PTableLocal::onTableEnded(const std::array<saki::Who, 4> &rank,
                          const std::array<int, 4> &scores)
{
    QVariantList rankList, scoresList;
    for (int i = 0; i < 4; i++) {
        rankList << rank[i].index();
        scoresList << scores[i];
    }

    QVariantMap args;
    args["rank"] = rankList;
    args["scores"] = scoresList;
    emit tableEvent(PTable::TableEnded, args);
}

void PTableLocal::onPoppedUp(const saki::Table &table, saki::Who who)
{
    if (who == mSelf) {
        QVariantMap args;
        args["str"] = QString::fromStdString(table.getGirl(who).popUpStr());
        emit tableEvent(PTable::PoppedUp, args);
    }
}

void PTableLocal::onActivated(saki::Table &table)
{
    using AC = saki::ActCode;
    using Mode = saki::Choices::Mode;

    const saki::TableView view = table.getView(mSelf);
    const saki::Choices &choices = view.myChoices();

    if (table.riichiEstablished(mSelf) && choices.spinOnly()) {
        emitJustPause(300); // a little pause
        table.action(mSelf, saki::Action(AC::SPIN_OUT));
        return;
    }

    QVariantMap map;
    int focusWho = -1;

    switch (choices.mode()) {
    case Mode::WATCH:
        break;
    case Mode::CUT:
        activateIrsCheck(map, view);
        break;
    case Mode::DICE:
        map.insert(stringOf(AC::DICE), true);
        break;
    case Mode::DRAWN:
        activateDrawn(map, view);
        break;
    case Mode::BARK:
        focusWho = view.getFocus().who().index();
        activateBark(map, view);
        break;
    case Mode::END:
        if (choices.can(AC::END_TABLE))
            map.insert(stringOf(AC::END_TABLE), true);
        if (choices.can(AC::NEXT_ROUND))
            map.insert(stringOf(AC::NEXT_ROUND), true);
        break;
    }

    if (choices.can(AC::IRS_CLICK))
        map.insert(stringOf(AC::NEXT_ROUND), true);

    QVariantMap args;
    args["action"] = map;
    args["lastDiscarder"] = focusWho;
    args["green"] = view.myChoices().forwardAll();
    args["nonce"] = -1;
    emit tableEvent(PTable::Activated, args);
}

void PTableLocal::start(const QVariant &girlIdsVar, const QVariant &gameRule, int tempDelaer)
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

void PTableLocal::action(QString actStr, int actArg, const QString &actTile)
{
    saki::Action action = readAction(actStr, actArg, actTile);
    mTable->action(saki::Who(0), action);
}

void PTableLocal::saveRecord()
{
    QString path(PGlobal::replayPath());

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

void PTableLocal::emitJustPause(int ms)
{
    QVariantMap args;
    args["ms"] = ms;
    emit tableEvent(PTable::JustPause, args);
}

void PTableLocal::activateDrawn(QVariantMap &map, const saki::TableView &view)
{
    using AC = saki::ActCode;

    for (AC ac : { AC::SPIN_OUT, AC::SPIN_RIICHI, AC::TSUMO, AC::RYUUKYOKU })
        if (view.myChoices().can(ac))
            map.insert(stringOf(ac), true);

    const saki::Choices::ModeDrawn &mode = view.myChoices().drawn();

    if (mode.swapOut)
        map.insert(stringOf(AC::SWAP_OUT), (1 << 13) - 1);

    if (!mode.swapRiichis.empty())
        map.insert(stringOf(AC::SWAP_RIICHI), createSwapMask(view.myHand().closed(), mode.swapRiichis));

    if (!mode.ankans.empty())
        map.insert(stringOf(AC::ANKAN), createTileStrsVar(mode.ankans.range()));

    if (!mode.kakans.empty()) {
        QVariantList list;
        for (int barkId : mode.kakans)
            list << barkId;
        map.insert(stringOf(AC::KAKAN), QVariant::fromValue(list));
    }
}

void PTableLocal::activateBark(QVariantMap &map, const saki::TableView &view)
{
    using AC = saki::ActCode;

    std::array<AC, 7> just {
        AC::PASS,
        AC::CHII_AS_LEFT, AC::CHII_AS_MIDDLE, AC::CHII_AS_RIGHT,
        AC::PON, AC::DAIMINKAN, AC::RON
    };

    for (AC ac : just)
        if (view.myChoices().can(ac))
            map.insert(stringOf(ac), true);
}

void PTableLocal::activateIrsCheck(QVariantMap &map, const saki::TableView &view)
{
    const saki::Girl &girl = view.me();
    int prediceCount = girl.irsCheckCount();
    QVariantList list;
    for (int i = 0; i < prediceCount; i++)
        list << createIrsCheckRowVar(girl.irsCheckRow(i));
    map.insert(stringOf(saki::ActCode::IRS_CHECK), QVariant::fromValue(list));
}


