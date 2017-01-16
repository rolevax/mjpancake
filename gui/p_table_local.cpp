#include "p_table_local.h"
#include "pport.h"

#include "libsaki/myrand.h"
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

    mHasInTile = false; // clear previous tsumo
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
    QVariantList list;
    for (int w = 0; w < 4; w++)
        list << createTilesVar(table.getHand(saki::Who(w)).closed());

    emit dealt(QVariant::fromValue(list));
}

void PTableLocal::onFlipped(const saki::Table &table)
{
    emit flipped(createTileVar(table.getMount().getDrids().back()));
}

void PTableLocal::onDrawn(const saki::Table &table, saki::Who who)
{
    mInTile = table.getHand(who).drawn();
    mHasInTile = true;
    emit drawn(who.index(), createTileVar(mInTile), table.duringKan());
}

void PTableLocal::onDiscarded(const saki::Table &table, bool spin)
{
    saki::Who who = table.getFocus().who();
    const saki::T37 &outTile = table.getFocusTile();
    bool lay = table.lastDiscardLay();

    int out = 13;
    int in = -1;
    if (!spin) {
        if (mHasInTile)
            outInIndices(table.getHand(who).closed(), outTile, out, in);
        else // after bark
            out = table.getHand(who).closed().preceders(outTile);

        if (who == mSelf) // use precise out-pos
            out = mOutPos;
    }

    mHasInTile =  false;

    emit discarded(who.index(), createTileVar(outTile, lay), out, in);
}

void PTableLocal::onRiichiCalled(saki::Who who)
{
    emit riichied(who.index());
}

void PTableLocal::onRiichiEstablished(saki::Who who)
{
    emit riichiPassed(who.index());
}

void PTableLocal::onBarked(const saki::Table &table, saki::Who who,
                      const saki::M37 &bark)
{
    const saki::TileCount &closed = table.getHand(who).closed();
    int index1 = -1; // float-button index
    int index2 = -1; // multiple use... design is fucking, though
    int fromWhom = -1;
    if (bark.type() == saki::M37::Type::ANKAN) {
        index1 = closed.preceders(bark[0]) + 2;
        assert(mHasInTile);
        if (mInTile.id34() < bark[0].id34()) // won't be same id34
            index1--; // recover insert-before-materials
        if (bark[0] != mInTile) // four continues, insert drawn
            index2 = closed.preceders(mInTile);
        mHasInTile = false;
    } else if (bark.type() == saki::M37::Type::KAKAN) {
        // equivalent to an out-in after discard
        assert(mHasInTile);
        if (bark[0] == mInTile) {
            index1 = 13;
        } else {
            outInIndices(closed, bark[3], index1, index2);
        }
        mHasInTile = false;
    } else {
        const saki::TableFocus &focus = table.getFocus();
        const saki::T34 &pick = table.getFocusTile();
        fromWhom = focus.who().index();
        // FUCK displace indices by aka5-remain settings
        switch (bark.type()) {
        case saki::M37::Type::CHII:
            if (pick == bark[0]) {
                index1 = closed.preceders(pick.next());
                index2 = closed.preceders(pick.nnext()) + 1;
            } else if (pick == bark[1]) {
                index1 = closed.preceders(pick.prev());
                index2 = closed.preceders(pick.next()) + 1;
            } else {
                assert(pick == bark[2]);
                index1 = closed.preceders(pick.pprev());
                index2 = closed.preceders(pick.prev()) + 1;
            }
            break;
        case saki::M37::Type::PON:
            index1 = closed.preceders(pick) + 1;
            break;
        case saki::M37::Type::DAIMINKAN:
            index1 = closed.preceders(pick) + 2;
            break;
        default:
            unreached("PTable::onBarked");
        }
    }

    emit barked(who.index(), fromWhom, QString(stringOf(bark.type())),
                index1, index2, createBarkVar(bark));
}

void PTableLocal::onRoundEnded(const saki::Table &table, saki::RoundResult result,
                          const std::vector<saki::Who> &openers, saki::Who gunner,
                          const std::vector<saki::Form> &forms)
{
    QVariantList openersList;
    QVariantList formsList;

    for (saki::Who who : openers)
        openersList << who.index();

    for (size_t i = 0; i < forms.size(); i++) {
        const saki::Hand &hand = table.getHand(openers[i]);
        const saki::Form &form = forms[i];
        const saki::T37 &pick = result == saki::RoundResult::RON ? table.getFocusTile()
                                                                 : hand.drawn();
        formsList << createFormVar(form.spell().c_str(), form.charge().c_str(),
                                   hand, pick);
    }

    emit roundEnded(QString(stringOf(result)),
                    QVariant::fromValue(openersList),
                    gunner.nobody() ? -1 : gunner.index(), formsList,
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

void PTableLocal::onPoppedUp(const saki::Table &table, saki::Who who, const saki::SkillExpr &expr)
{
    std::string str = table.getGirl(who).stringOf(expr);
    emit poppedUp(who.index(), QString::fromStdString(str));
}

void PTableLocal::onActivated(saki::Table &table)
{
    using ActCode = saki::ActCode;

    const saki::TableView view = table.getView(mSelf);

    if (table.riichiEstablished(mSelf) && view.iCanOnlySpin()) {
        emit justPause(500); // a little pause
        table.action(mSelf, saki::Action(ActCode::SPIN_OUT));
        return;
    }

    QVariantMap map;
    int focusWho = -1; // set in bark activation

    if (view.iCan(ActCode::SWAP_OUT)) {
        map.insert(stringOf(ActCode::SWAP_OUT),
                   createSwapMask(table.getHand(mSelf).closed(), view.mySwappables()));
    }

    if (view.iCan(ActCode::CHII_AS_LEFT)) {
        int push = view.myHand().closed().preceders(view.getFocusTile().next());
        map.insert(stringOf(ActCode::CHII_AS_LEFT), push);
        focusWho = view.getFocus().who().index();
    }

    if (view.iCan(ActCode::CHII_AS_MIDDLE)) {
        int push = view.myHand().closed().preceders(view.getFocusTile().prev());
        map.insert(stringOf(ActCode::CHII_AS_MIDDLE), push);
        focusWho = view.getFocus().who().index();
    }

    if (view.iCan(ActCode::CHII_AS_RIGHT)) {
        int push = view.myHand().closed().preceders(view.getFocusTile().pprev());
        map.insert(stringOf(ActCode::CHII_AS_RIGHT), push);
        focusWho = view.getFocus().who().index();
    }

    if (view.iCan(ActCode::PON)) {
        int push = view.myHand().closed().preceders(saki::T34(view.getFocusTile())) + 1;
        map.insert(stringOf(ActCode::PON), push);
        focusWho = view.getFocus().who().index();
    }

    if (view.iCan(ActCode::DAIMINKAN)) {
        int push = view.myHand().closed().preceders(saki::T34(view.getFocusTile())) + 2;
        map.insert(stringOf(ActCode::DAIMINKAN), push);
        focusWho = view.getFocus().who().index();
    }

    if (view.iCan(ActCode::ANKAN)) {
        QVariantList list;
        for (saki::T34 t : view.myAnkanables())
            list << view.myHand().closed().preceders(t) + 2;
        map.insert(stringOf(ActCode::ANKAN), QVariant::fromValue(list));
    }

    if (view.iCan(ActCode::KAKAN)) {
        QVariantList list;
        for (int barkId : view.myKakanables())
            list << barkId;
        map.insert(stringOf(ActCode::KAKAN), QVariant::fromValue(list));
    }

    if (view.iCan(ActCode::IRS_CHECK)) {
        const saki::Girl &girl = table.getGirl(mSelf);
        int prediceCount = girl.irsCheckCount();
        QVariantList list;
        for (int i = 0; i < prediceCount; i++)
            list << createIrsCheckRowVar(girl.irsCheckRow(i));
        map.insert(stringOf(ActCode::IRS_CHECK), QVariant::fromValue(list));
    }

    if (view.iCan(ActCode::IRS_RIVAL)) {
        const saki::Girl &girl = table.getGirl(mSelf);
        QVariantList list;
        for (int i = 0; i < 4; i++)
            if (girl.irsRivalMask()[i])
                list << i;
        map.insert(stringOf(ActCode::IRS_RIVAL), QVariant::fromValue(list));
    }

    if (view.iCan(ActCode::RON)) {
        map.insert(stringOf(ActCode::RON), true);
        focusWho = view.getFocus().who().index();
    }

    static const ActCode just[] = {
        ActCode::PASS, ActCode::SPIN_OUT, ActCode::RIICHI,
        ActCode::TSUMO, ActCode::RYUUKYOKU,
        ActCode::END_TABLE, ActCode::NEXT_ROUND,
        ActCode::DICE, ActCode::IRS_CLICK
    };

    for (ActCode code : just) {
        if (view.iCan(code))
            map.insert(stringOf(code), true);
    }

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

    QVariantMap map = gameRule.toMap();

    saki::RuleInfo rule;
    rule.fly = map["fly"].toBool();
    rule.headJump = map["headJump"].toBool();
    rule.nagashimangan = map["nagashimangan"].toBool();
    rule.ippatsu = map["ippatsu"].toBool();
    rule.uradora = map["uradora"].toBool();
    rule.kandora = map["kandora"].toBool();
    rule.akadora = saki::TileCount::AkadoraCount(map["akadora"].toInt());
    rule.returnLevel = map["returnLevel"].toInt();
    rule.hill = map["hill"].toInt();

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

void PTableLocal::action(int who, QString actStr, int arg)
{
    saki::Action action = makeAction(actStr, arg);
    mTable->action(saki::Who(who), action);
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

saki::Action PTableLocal::makeAction(const QString &actStr, int arg)
{
    using ActCode = saki::ActCode;

    ActCode act = saki::actCodeOf(actStr.toStdString().c_str());
    switch (act) {
    case ActCode::SWAP_OUT:
        mOutPos = arg;
    case ActCode::ANKAN:
        return saki::Action(act, mTable->getHand(mSelf).closed().pointOut(arg));
    case ActCode::CHII_AS_LEFT:
    case ActCode::CHII_AS_MIDDLE:
    case ActCode::CHII_AS_RIGHT:
    case ActCode::PON:
    case ActCode::KAKAN:
    case ActCode::IRS_CHECK:
    case ActCode::IRS_RIVAL:
        return saki::Action(act, arg);
    default:
        return saki::Action(act);
    }
}

void PTableLocal::outInIndices(const saki::TileCount &closed,
                          const saki::T34 &drop, int &out, int &in)
{
    out = closed.preceders(drop);
    in = closed.preceders(mInTile);
    out -= (out > in);
}




