#ifndef P_GEN_H
#define P_GEN_H

#include "libsaki/pointinfo.h"
#include "libsaki/rand.h"

#include <QObject>



class PGen : public QObject
{
    Q_OBJECT
public:
    explicit PGen(QObject *parent = 0);

    /*
    Q_INVOKABLE void genPoint(int point, int selfWind, int roundWind, bool ron);
                              */
    Q_INVOKABLE void genFuHan(int fu, int han, int selfWind, int roundWind,
                              bool ron);

signals:
    void genned(const QVariant &how);

public slots:

private:
    saki::Rand mRand;
    saki::RuleInfo mRule;
};



#endif // P_GEN_H


