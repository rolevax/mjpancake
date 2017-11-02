#include "p_table_local.h"
#include "p_port.h"
#include "p_global.h"

#include "libsaki/ai/ai_stub.h"
#include "libsaki/util/rand.h"
#include "libsaki/util/string_enum.h"
#include "libsaki/util/misc.h"

#include <QFile>
#include <QDateTime>
#include <QStandardPaths>
#include <QJsonDocument>
#include <QJsonObject>

#include <sstream>
#include <fstream>
#include <iostream>
#include <cassert>



using namespace saki;



PTableLocal::PTableLocal(QObject *parent)
    : QObject(parent)
    , TableOperator(Who(Who::HUMAN))
{
}

void PTableLocal::onTableStarted(const Table &table, uint32_t seed)
{
    (void) seed;
    onPointsChanged(table);
}

void PTableLocal::onFirstDealerChoosen(Who initDealer)
{
    QVariantMap args;
    args["dealer"] = initDealer.index();
    emit tableEvent(PTable::FirstDealerChoosen, args);
}

void PTableLocal::onRoundStarted(int round, int extra, Who dealer,
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

void PTableLocal::onDiced(const Table &table, int die1, int die2)
{
    if (!table.getDealer().human())
        emitJustPause(700);

    QVariantMap args;
    args["die1"] = die1;
    args["die2"] = die2;
    emit tableEvent(PTable::Diced, args);
}

void PTableLocal::onDealt(const Table &table)
{
    QVariantMap args;
    args["init"] = createTilesVar(table.getHand(mSelf).closed());
    emit tableEvent(PTable::Dealt, args);
}

void PTableLocal::onFlipped(const Table &table)
{
    QVariantMap args;
    args["newIndic"] = createTileVar(table.getMount().getDrids().back());
    emit tableEvent(PTable::Flipped, args);
}

void PTableLocal::onDrawn(const Table &table, Who who)
{
    if (mPrac && who != mSelf)
        return;

    QVariantMap args;
    args["who"] = who.index();
    args["tile"] = createTileVar(table.getHand(who).drawn());
    args["rinshan"] = table.duringKan();
    emit tableEvent(PTable::Drawn, args);
}

void PTableLocal::onDiscarded(const Table &table, bool spin)
{
    Who who = table.getFocus().who();
    if (mPrac && who != mSelf)
        return;

    const T37 &outTile = table.getFocusTile();
    bool lay = table.lastDiscardLay();

    if (!who.human())
        emitJustPause(300);

    QVariantMap args;
    args["who"] = who.index();
    args["tile"] = createTileVar(outTile, lay);
    args["spin"] = spin;
    emit tableEvent(PTable::Discarded, args);
}

void PTableLocal::onRiichiCalled(Who who)
{
    if (!who.human())
        emitJustPause(300);

    QVariantMap args;
    args["who"] = who.index();
    emit tableEvent(PTable::RiichiCalled, args);
}

void PTableLocal::onRiichiEstablished(Who who)
{
    QVariantMap args;
    args["who"] = who.index();
    emit tableEvent(PTable::RiichiEstablished, args);
}

void PTableLocal::onBarked(const Table &table, Who who,
                      const M37 &bark, bool spin)
{
    int fromWhom = bark.isCpdmk() ? table.getFocus().who().index() : -1;
    if (!who.human())
        emitJustPause(500);

    QVariantMap args;
    args["who"] = who.index();
    args["fromWhom"] = fromWhom;
    args["actStr"] = QString(util::stringOf(bark.type()));
    args["bark"] = createBarkVar(bark);
    args["spin"] = spin;
    emit tableEvent(PTable::Barked, args);
}

void PTableLocal::onRoundEnded(const Table &table, RoundResult result,
                          const std::vector<Who> &openers, Who gunner,
                          const std::vector<Form> &forms)
{
    using RR = RoundResult;

    QVariantList openersList;
    QVariantList formsList;
    QVariantList handsList;

    for (Who who : openers) {
        openersList << who.index();

        const Hand &hand = table.getHand(who);

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
        const Form &form = forms[i];
        formsList << createFormVar(form.spell().c_str(), form.charge().c_str());
    }

    if ((result == RR::TSUMO || result == RR::RON || result == RR::SCHR)
            && (openers.size() > 1 || !openers[0].human())) {
        emitJustPause(700);
    }


    QVariantMap args;
    args["result"] = QString(util::stringOf(result));
    args["openers"] = openersList;
    args["gunner"] = gunner.nobody() ? -1 : gunner.index();
    args["hands"] = handsList;
    args["forms"] = formsList;
    args["urids"] = createTilesVar(table.getMount().getUrids().range());
    emit tableEvent(PTable::RoundEnded, args);
}

void PTableLocal::onPointsChanged(const Table &table)
{
    const std::array<int, 4> &points = table.getPoints();
    QVariantList list;
    for (int i = 0; i < 4; i++)
        list << points[i];

    QVariantMap args;
    args["points"] = list;
    emit tableEvent(PTable::PointsChanged, args);
}

void PTableLocal::onTableEnded(const std::array<Who, 4> &rank,
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

void PTableLocal::onPoppedUp(const Table &table, Who who)
{
    if (who == mSelf) {
        QVariantMap args;
        args["str"] = QString::fromStdString(table.getGirl(who).popUpStr());
        emit tableEvent(PTable::PoppedUp, args);
    }
}

void PTableLocal::onActivated(Table &table)
{
    const std::unique_ptr<TableView> view = table.getView(mSelf);

    if (table.riichiEstablished(mSelf) && view->myChoices().spinOnly()) {
        emitJustPause(300); // a little pause
        table.action(mSelf, Action(ActCode::SPIN_OUT));
        return;
    }

    if (mPrac && view->myChoices().can(ActCode::PASS)) {
        table.action(mSelf, Action(ActCode::PASS));
        return;
    }

    emit tableEvent(PTable::Activated, createActivation(*view));
}

void PTableLocal::start(const QVariant &girlIdsVar, const QVariant &gameRule, int tempDelaer)
{
    mPrac = false;

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

    Rule rule = readRuleJson(QJsonObject::fromVariantMap(gameRule.toMap()));

    std::array<int, 4> points {
        rule.returnLevel - rule.hill / 4,
        rule.returnLevel - rule.hill / 4,
        rule.returnLevel - rule.hill / 4,
        rule.returnLevel - rule.hill / 4,
    };

    for (int w = 1; w < 4; w++)
        mAis[w - 1].reset(Ai::create(Who(w), Girl::Id(girlIds[w])));
    std::array<TableOperator*, 4> operators {
        this, mAis.at(0).get(), mAis.at(1).get(), mAis.at(2).get()
    };

    std::vector<TableObserver*> observers { this, &mReplay };

    mTable.reset(new Table(points, girlIds, operators, observers,
                                 rule, Who(tempDelaer)));
    mTable->start();
}

void PTableLocal::startPrac(int girlId)
{
    mPrac = true;

    std::array<int, 4> girlIds { girlId, 0, 0, 0 };
    Rule rule;

    std::array<int, 4> points {
        rule.returnLevel - rule.hill / 4,
        rule.returnLevel - rule.hill / 4,
        rule.returnLevel - rule.hill / 4,
        rule.returnLevel - rule.hill / 4,
    };

    for (int w = 1; w < 4; w++)
        mAis[w - 1].reset(new AiStub(Who(w)));
    std::array<TableOperator*, 4> operators {
        this, mAis.at(0).get(), mAis.at(1).get(), mAis.at(2).get()
    };

    std::vector<TableObserver*> observers { this };

    mTable.reset(new Table(points, girlIds, operators, observers,
                                 rule, Who(0)));
    mTable->start();
}

void PTableLocal::action(const QString &actStr, int actArg, const QString &actTile)
{
    Action action = readAction(actStr, actArg, actTile);
    mTable->action(Who(0), action);
}

void PTableLocal::saveRecord()
{
    if (mPrac)
        return;

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


