#ifndef P_EFF_H
#define P_EFF_H

#include "libsaki/mount.h"
#include "libsaki/hand.h"

#include <QObject>
#include <QVariantList>
#include <QVariantMap>



class PEff : public QObject
{
    Q_OBJECT
public:
    explicit PEff(QObject *parent = nullptr);

    Q_PROPERTY(bool uradora READ uradora WRITE setUradora NOTIFY uradoraChanged)
    Q_PROPERTY(bool kandora READ kandora WRITE setKandora NOTIFY kandoraChanged)
    Q_PROPERTY(int akadora READ akadora WRITE setAkadora NOTIFY akadoraChanged)
    Q_PROPERTY(bool ippatsu READ ippatsu WRITE setIppatsu NOTIFY ippatsuChanged)

    Q_INVOKABLE void deal();
    Q_INVOKABLE void action(const QString &actStr, const QString &actArg);
    Q_INVOKABLE QVariantList answer();

    bool uradora() const;
    void setUradora(bool v);
    bool kandora() const;
    void setKandora(bool v);
    int akadora() const;
    void setAkadora(int v);
    bool ippatsu();
    void setIppatsu(bool v);

signals:
    void dealt(const QVariantList &init);
    void drawn(const QVariant &tile);
    void ankaned(const QVariant &bark, bool spin);
    void activated(const QVariantMap &actions);
    void autoSpin();
    void finished(const QVariant &form, int gain, int turn);
    void exhausted();

    void uradoraChanged();
    void kandoraChanged();
    void akadoraChanged();
    void ippatsuChanged();

private:
    void draw();
    void declareRiichi();
    void ankan(saki::T34 t);
    void tsumo();

private:
    saki::RuleInfo mRule;
    saki::PointInfo mInfo;
    saki::Rand mRand;
    saki::Mount mMount;
    saki::Hand mHand;
    int mTurn;
    int mRiichi;
};



#endif // P_EFF_H


