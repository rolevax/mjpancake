#include "p_eff_gb.h"
#include "p_port.h"
#include "p_eff.h"



PEffGb::PEffGb(QObject *parent)
    : QObject(parent)
    , mMount(saki::TileCount::AKADORA0)
{

}

void PEffGb::deal()
{
    using namespace saki;

    mTurn = 0;

    mMount = Mount(saki::TileCount::AKADORA0);
    TileCount init;
    Exist exist;
    mMount.initFill(mRand, init, exist);
    mHand = Hand(init);

    emit dealt(createTilesVar(mHand.closed()));
    draw();
}

void PEffGb::action(const QString &actStr, const QString &actArg)
{
    using namespace saki;
    Action action = readAction(actStr, actArg);
    switch (action.act()) {
    case ActCode::SWAP_OUT:
        mInfo.duringKan = false;
        mHand.swapOut(action.tile());
        draw();
        break;
    case ActCode::SPIN_OUT:
        mInfo.duringKan = false;
        mHand.spinOut();
        draw();
        break;
    case ActCode::ANKAN:
        angang(action.tile());
        break;
    case ActCode::TSUMO:
        zimo();
        break;
    default:
        break;
    }
}

QVariantList PEffGb::answer()
{
    return PEff::nanikiru(mHand, mMount);
}

void PEffGb::draw()
{
    if (mTurn++ == 27) {
        emit exhausted();
        return;
    }

    mHand.draw(mMount.wallPop(mRand));
    emit drawn(createTileVar(mHand.drawn()));

    mInfo.emptyMount = mTurn == 27;

    QVariantMap actions;
    std::vector<saki::T34> ankanables;
    bool canTsumo = mHand.canTsumo(mInfo, saki::RuleInfo());
    bool canAnkan = mHand.canAnkan(ankanables, false);
    if (canTsumo)
        actions["TSUMO"] = true;
    if (canAnkan)
        actions["ANKAN"] = createTileStrsVar(ankanables);
    actions["SPIN_OUT"] = true;

    QVariantList mask;
    for (int i = 0; i < 13; i++)
        mask << true;
    actions["SWAP_OUT"] = mask;
    emit activated(actions);
}

void PEffGb::angang(saki::T34 t)
{
    bool spin = t == mHand.drawn();
    mHand.ankan(t);
    emit anganged(createBarkVar(mHand.barks().back()), spin);
    mInfo.duringKan = true;
    draw();
}

void PEffGb::zimo()
{
    /* FUCK use GB form
    Form form(mHand, mInfo, mRule, drids, urids);
    emit finished(createFormVar(form.spell().c_str(), form.charge().c_str()),
                  form.gain(), mTurn);
                  */
}
