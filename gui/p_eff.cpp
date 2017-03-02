#include "p_eff.h"
#include "p_port.h"

#include "libsaki/util.h"

#include <numeric>
#include <sstream>

PEff::PEff(QObject *parent)
    : QObject(parent)
    , mMount(mRule.akadora)
{
    mInfo.roundWind = 1;
    mInfo.selfWind = 2;
}

QVariantList PEff::nanikiru(const saki::Hand &hand, const saki::Mount &mount)
{
    using namespace saki;

    std::vector<T34> choices;
    std::vector<std::vector<T34>> waits;
    std::vector<int> remains;
    int minStep = 13;

    auto update = [&](const HandDream &dream, T34 t) {
        int step = dream.step();

        if (step < minStep) {
            minStep = step;
            choices.clear();
            waits.clear();
            remains.clear();
        }

        if (step == minStep && !util::has(choices, T34(t))) { // dup by aka5
            auto wait = dream.effA();
            auto aux = [&](int s, T34 t) { return s + mount.remainA(t); };
            int remain = std::accumulate(wait.begin(), wait.end(), 0, aux);
            size_t pos = 0;
            while (pos < remains.size() && remain <= remains[pos])
                pos++;
            remains.insert(remains.begin() + pos, remain);
            choices.insert(choices.begin() + pos, t);
            waits.emplace(waits.begin() + pos, wait);
        }
    };

    for (const T37 &t : hand.closed().t37s())
        update(hand.withSwap(t), t);
    update(hand.withSpin(), hand.drawn());

    QVariantList list;
    for (size_t i = 0; i < choices.size(); i++) {
        QVariantMap map;
        map["out"] = choices[i].str();
        std::stringstream ss;
        ss << waits[i];
        map["waits"] = ss.str().c_str();
        map["remain"] = remains[i];
        list << map;
    }

    return list;
}

void PEff::deal()
{
    using namespace saki;

    mTurn = 0;
    mInfo.riichi = 0;

    mMount = Mount(mRule.akadora);
    TileCount init;
    Exist exist;
    mMount.initFill(mRand, init, exist);
    mHand = Hand(init);
    mMount.flipIndic(mRand);

    emit dealt(createTilesVar(mHand.closed()), createTileVar(mMount.getDrids().back()));
    draw();
}

void PEff::action(const QString &actStr, const QString &actArg)
{
    using namespace saki;
    Action action = readAction(actStr, actArg);
    switch (action.act()) {
    case ActCode::SWAP_OUT:
        mInfo.duringKan = false;
        mInfo.ippatsu = false;
        mHand.swapOut(action.tile());
        draw();
        break;
    case ActCode::SPIN_OUT:
        mInfo.duringKan = false;
        mInfo.ippatsu = false;
        mHand.spinOut();
        draw();
        break;
    case ActCode::RIICHI:
        declareRiichi();
        break;
    case ActCode::ANKAN:
        mInfo.ippatsu = false;
        ankan(action.tile());
        break;
    case ActCode::TSUMO:
        tsumo();
        break;
    default:
        break;
    }
}

QVariantList PEff::answer()
{
    return nanikiru(mHand, mMount);
}

bool PEff::uradora() const
{
    return mRule.uradora;
}

void PEff::setUradora(bool v)
{
    mRule.uradora = v;
    emit uradoraChanged();
}

bool PEff::kandora() const
{
    return mRule.kandora;
}

void PEff::setKandora(bool v)
{
    mRule.kandora = v;
    emit kandoraChanged();
}

int PEff::akadora() const
{
    return static_cast<int>(mRule.akadora);
}

void PEff::setAkadora(int v)
{
    mRule.akadora = static_cast<saki::TileCount::AkadoraCount>(v);
    emit akadoraChanged();
}

bool PEff::ippatsu()
{
    return mRule.ippatsu;
}

void PEff::setIppatsu(bool v)
{
    mRule.ippatsu = v;
    emit ippatsuChanged();
}

void PEff::draw()
{
    if (mTurn++ == 27) {
        emit exhausted();
        return;
    }

mMount.lightA(saki::T34(saki::Suit::M, 1), 2000);
    mHand.draw(mMount.wallPop(mRand));
    emit drawn(createTileVar(mHand.drawn()));

    mInfo.emptyMount = mTurn == 27;

    QVariantMap actions;
    std::vector<saki::T34> ankanables;
    bool canTsumo = mHand.canTsumo(mInfo, mRule);
    bool canAnkan = mHand.canAnkan(ankanables, mInfo.riichi);
    if (canTsumo)
        actions["TSUMO"] = true;
    if (canAnkan)
        actions["ANKAN"] = createTileStrsVar(ankanables);
    actions["SPIN_OUT"] = true;

    if (mInfo.riichi) {
        if (canTsumo || canAnkan) {
            emit activated(actions);
        } else {
            emit autoSpin();
            mHand.spinOut();
            draw();
        }
    } else {
        actions["SWAP_OUT"] = 8191; // 0111_1111_1111
        if (!mInfo.emptyMount && mHand.canRiichi())
            actions["RIICHI"] = true;
        emit activated(actions);
    }
}

void PEff::declareRiichi()
{
    using namespace saki;

    mInfo.riichi = mTurn == 1 ? 2 : 1;
    mInfo.ippatsu = true;
    std::vector<T37> swappables;
    bool spinnable = false;
    mHand.declareRiichi(swappables, spinnable);

    QVariantMap actions;
    actions["SWAP_OUT"] = createSwapMask(mHand.closed(), swappables);
    if (spinnable)
        actions["SPIN_OUT"] = true;

    emit activated(actions);
}

void PEff::ankan(saki::T34 t)
{
    bool spin = t == mHand.drawn();
    mHand.ankan(t);
    if (mRule.kandora)
        mMount.flipIndic(mRand);
    emit ankaned(createBarkVar(mHand.barks().back()), spin,
                 createTileVar(mMount.getDrids().back()));
    mInfo.duringKan = true;
    draw();
}

void PEff::tsumo()
{
    using namespace saki;
    if (mRule.uradora && mInfo.riichi > 0)
        mMount.digIndic(mRand);
    Form form(mHand, mInfo, mRule, mMount.getDrids(), mMount.getUrids());
    emit finished(createFormVar(form.spell().c_str(), form.charge().c_str()),
                  form.gain(), mTurn, createTilesVar(mMount.getUrids()));
}
