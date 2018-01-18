#include "gui/p_gen.h"
#include "gui/p_port.h"

#include "libsaki/app/gen.h"

#include <QVariantMap>
#include <iostream>

PGen::PGen(QObject *parent) : QObject(parent)
{
//    auto seed = mySrand();
//    std::cout << "gen: seed is " << seed << std::endl;
}

/*
   void PGen::genPoint(int point, int selfWind, int roundWind, bool ron)
   {
   RuleInfo rule;

   Gen g = Gen::genForm4Point(point, selfWind, roundWind, rule, ron);
   const Form &form = *g.form;

   QVariant formVar = createFormVar(form.spell().c_str(), form.charge().c_str(),
                                 g.hand.getHand(),
                                 g.hand.getBarks(), g.pick);
   emit genned(formVar);
   }
 */

void PGen::genFuHan(int fu, int han, int selfWind, int roundWind, bool ron)
{
    using namespace saki;

    Gen g = fu == 0 ? Gen::genForm4Mangan(mRand, han, selfWind, roundWind, mRule, ron)
                    : Gen::genForm4FuHan(mRand, fu, han, selfWind, roundWind, mRule, ron);

    QVariantMap how = createFormVar(g.form.spell().c_str(), g.form.charge().c_str());
    how["hand"] = createTilesVar(g.hand.closed().t37s13(true).range());
    how["barks"] = createBarksVar(g.hand.barks());
    how["pick"] = createTileVar(g.pick);

    emit genned(how);
}
