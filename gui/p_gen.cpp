#include "gui/p_gen.h"
#include "gui/p_port.h"
#include "libsaki/gen.h"

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

void PGen::genFuHan(int fu, int han, int selfWind, int roundWind, bool ron)
{
    RuleInfo rule;

    Gen g = fu == 0 ? Gen::genForm4Mangan(han, selfWind, roundWind, rule, ron)
                    : Gen::genForm4FuHan(fu, han, selfWind, roundWind, rule, ron);
    const Form &form = *g.form;

    QVariant formVar = createFormVar(form.spell().c_str(), form.charge().c_str(),
                                     g.hand.getHand(),
                                     g.hand.getBarks(), g.pick);
    emit genned(formVar);
}
    */



