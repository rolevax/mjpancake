#include "p_eff_gb.h"
#include "p_port.h"

#include "libsaki/form/form_gb.h"
#include "libsaki/girl/rinkai_huiyu.h"
#include "libsaki/util/misc.h"



PEffGb::PEffGb(QObject *parent)
    : QObject(parent)
    , mMount(saki::TileCount::AKADORA0)
{
    mFormCtx.roundWind = 1;
    mFormCtx.selfWind = 2;
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

    emit dealt(createTilesVar(mHand.closed().t37s13(true).range()));
    draw();
}

void PEffGb::action(const QString &actStr, int actArg, const QString &actTile)
{
    using namespace saki;
    Action action = readAction(actStr, actArg, actTile);
    switch (action.act()) {
    case ActCode::SWAP_OUT:
        mFormCtx.duringKan = false;
        mHand.swapOut(action.t37());
        draw();
        break;
    case ActCode::SPIN_OUT:
        mFormCtx.duringKan = false;
        mHand.spinOut();
        draw();
        break;
    case ActCode::ANKAN:
        angang(action.t34());
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
        Huiyu::skill(mMount, mHand, mFormCtx);

    mHand.draw(mMount.pop(mRand));
    emit drawn(createTileVar(mHand.drawn()));

    mFormCtx.emptyMount = mTurn == 27;

    QVariantMap actions;
    saki::util::Stactor<T34, 3> ankanables;
    bool canTsumo = mHand.stepGb() == -1;
    bool canAnkan = mHand.canAnkan(ankanables, false);
    if (canTsumo)
        actions["TSUMO"] = true;

    if (canAnkan)
        actions["ANKAN"] = createTileStrsVar(ankanables.range());

    actions["SPIN_OUT"] = true;
    actions["SWAP_OUT"] = 8191; // 0111_1111_1111
    emit activated(actions);
}

void PEffGb::angang(saki::T34 t)
{
    bool spin = t == mHand.drawn();
    mHand.ankan(t);
    emit anganged(createBarkVar(mHand.barks().back()), spin);
    mFormCtx.duringKan = true;
    draw();
}

void PEffGb::zimo()
{
    using namespace saki;
    bool juezhang = mMount.remainA(mHand.drawn()) == 0 && mHand.ct(mHand.drawn()) == 1;
    FormGb form(mHand, mFormCtx, juezhang);
    QVariantList fans;
    for (Fan f : form.fans())
        fans << static_cast<int>(f);

    emit finished(fans, form.fan(), mTurn);
}
