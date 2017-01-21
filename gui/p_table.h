#ifndef P_TABLE_H
#define P_TABLE_H

#include "gui/p_table_local.h"
#include "gui/p_client.h"

#include <QObject>
#include <QThread>

class PTable : public QObject
{
    Q_OBJECT
public:
    explicit PTable(QObject *parent = 0);
    ~PTable();

    Q_PROPERTY(bool online READ online NOTIFY onlineChanged)

    Q_INVOKABLE void startLocal(const QVariant &girlIds, const QVariant &gameRule,
                                int tempDealer);
    Q_INVOKABLE void startOnline(PClient *client);
    Q_INVOKABLE void startSample();

    bool online() const;

signals:
    void onlineChanged();

    void action(QString actStr, const QVariant &actArg);
    void saveRecord();

    void firstDealerChoosen(int dealer);
    void roundStarted(int round, int extra, int dealer, bool allLast, int deposit);
    void cleaned();
    void diced(int die1, int die2);
    void dealt(const QVariant &init);
    void flipped(const QVariant &newIndic);
    void activated(const QVariant &action, int lastDiscarder);
    void drawn(int who, const QVariant &tile, bool rinshan);
    void discarded(int who, const QVariant &tile, bool spin);
    void riichiCalled(int who);
    void riichiEstablished(int who);
    void barked(int who, int fromWhom, QString actStr, const QVariant &bark, bool spin);
    void roundEnded(QString result, const QVariant &openers, int gunner,
                    const QVariant &hands, const QVariant &forms, const QVariant &urids);
    void pointsChanged(const QVariant &points);
    void tableEnded(const QVariant &rank, const QVariant &scores);
    void poppedUp(int who, QString str);

    void justPause(int ms);
    void justSetOutPos(int outPos);

public slots:

private:
    QThread workThread;
    bool mOnline = false;
};

#endif // P_TABLE_H
