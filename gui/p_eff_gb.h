#ifndef P_EFF_GB_H
#define P_EFF_GB_H

#include "libsaki/table/mount.h"
#include "libsaki/form/hand.h"

#include <QObject>
#include <QVariantList>



class PEffGb : public QObject
{
    Q_OBJECT

public:
    explicit PEffGb(QObject *parent = nullptr);

    Q_PROPERTY(bool skill READ skill WRITE setSkill NOTIFY skillChanged)

    Q_INVOKABLE void deal();
    Q_INVOKABLE void action(const QString &actStr, int actArg, const QString &actTile);

    bool skill() const;
    void setSkill(bool v);

signals:
    void dealt(const QVariant &init);
    void drawn(const QVariant &tile);
    void anganged(const QVariant &bark, bool spin);
    void activated(const QVariantMap &actions);
    void finished(const QVariantList &fans, int fan, int turn);
    void exhausted();

    void skillChanged();

private:
    void draw();
    void angang(saki::T34 t);
    void zimo();

private:
    saki::util::Rand mRand;
    saki::Mount mMount;
    saki::Hand mHand;
    saki::FormCtx mFormCtx;
    int mTurn;
    bool mSkill = false;
};



#endif // P_EFF_GB_H
