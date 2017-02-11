#include "p_eff.h"
#include "p_port.h"

#include "libsaki/mount.h"
#include "libsaki/hand.h"

PEff::PEff(QObject *parent) : QObject(parent)
{

}

void PEff::deal()
{
    using namespace saki;
    Mount mount(TileCount::AKADORA0);
    Rand rand;
    TileCount init;
    Exist exist;
    mount.initFill(rand, init, exist);

    Hand hand(init);
    emit dealt(createTilesVar(hand.closed()));
}
