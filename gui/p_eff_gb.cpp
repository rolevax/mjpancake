#include "p_eff_gb.h"
#include "p_port.h"

#include "libsaki/form_gb.h"
#include "libsaki/girls_rinkai.h"
#include "libsaki/util.h"



PEffGb::PEffGb(QObject *parent)
    : QObject(parent)
    , mMount(saki::TileCount::AKADORA0)
{
    mInfo.roundWind = 1;
    mInfo.selfWind = 2;
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

bool PEffGb::skill() const
{
    return mSkill;
}

void PEffGb::setSkill(bool v)
{
    mSkill = v;
    emit skillChanged();
}

void PEffGb::draw()
{
    using namespace saki;

    if (mTurn++ == 27) {
        emit exhausted();
        return;
    }

    if (mSkill)
        Huiyu::skill(mMount, mHand);

    mHand.draw(mMount.wallPop(mRand));
    emit drawn(createTileVar(mHand.drawn()));

    mInfo.emptyMount = mTurn == 27;

    QVariantMap actions;
    std::vector<T34> ankanables;
    bool canTsumo = mHand.stepGb() == -1;
    bool canAnkan = mHand.canAnkan(ankanables, false);
    if (canTsumo)
        actions["TSUMO"] = true;
    if (canAnkan)
        actions["ANKAN"] = createTileStrsVar(ankanables);
    actions["SPIN_OUT"] = true;
    actions["SWAP_OUT"] = 8191; // 0111_1111_1111
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
    using namespace saki;
    bool juezhang = mMount.remainA(mHand.drawn()) == 0 && mHand.ct(mHand.drawn()) == 1;
    FormGb form(mHand, mInfo, juezhang);
    QVariantList fans;
    for (Fan f : form.fans())
        fans << static_cast<int>(f);
    emit finished(fans, form.fan(), mTurn);
}
