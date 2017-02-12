#ifndef P_EFF_GB_H
#define P_EFF_GB_H

#include "libsaki/mount.h"
#include "libsaki/hand.h"

#include <QObject>
#include <QVariantList>



class PEffGb : public QObject
{
    Q_OBJECT
public:
    explicit PEffGb(QObject *parent = nullptr);

    Q_INVOKABLE void deal();
    Q_INVOKABLE void action(const QString &actStr, const QString &actArg);
    Q_INVOKABLE QVariantList answer();

signals:
    void dealt(const QVariantList &init);
    void drawn(const QVariant &tile);
    void anganged(const QVariant &bark, bool spin);
    void activated(const QVariantMap &actions);
    void finished(const QVariant &form, int gain, int turn);
    void exhausted();

private:
    void draw();
    void angang(saki::T34 t);
    void zimo();

private:
    saki::Rand mRand;
    saki::Mount mMount;
    saki::Hand mHand;
    saki::PointInfo mInfo;
    int mTurn;
};



#endif // P_EFF_GB_H


