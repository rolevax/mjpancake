#ifndef P_TABLE_LOCAL_H
#define P_TABLE_LOCAL_H

#include "libsaki/table.h"
#include "libsaki/ai.h"
#include "libsaki/replay.h"

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <memory>
#include <vector>



class PTableLocal : public QObject, saki::TableObserver, saki::TableOperator
{
    Q_OBJECT
public:
    explicit PTableLocal(QObject *parent = nullptr);

    void onTableStarted(const saki::Table &table, uint32_t seed) override;
    void onFirstDealerChoosen(saki::Who initDealer) override;
    void onRoundStarted(int round, int extra, saki::Who dealer,
                        bool al, int deposit, uint32_t seed) override;
    void onCleaned() override;
    void onDiced(const saki::Table &table, int die1, int die2) override;
    void onDealt(const saki::Table &table) override;
    void onFlipped(const saki::Table &table) override;
    void onDrawn(const saki::Table &table, saki::Who who) override;
    void onDiscarded(const saki::Table &table, bool spin) override;
    void onRiichiCalled(saki::Who who) override;
    void onRiichiEstablished(saki::Who who) override;
    void onBarked(const saki::Table &table, saki::Who who,
                  const saki::M37 &bark, bool spin) override;
    void onRoundEnded(const saki::Table &table, saki::RoundResult result,
                      const std::vector<saki::Who> &openers, saki::Who gunner,
                      const std::vector<saki::Form> &fs) override;
    void onPointsChanged(const saki::Table &table) override;
    void onTableEnded(const std::array<saki::Who, 4> &rank,
                      const std::array<int, 4> &scores) override;
    void onPoppedUp(const saki::Table &table, saki::Who who,
                    const saki::SkillExpr &expr) override;

    void onActivated(saki::Table &table) override;

signals:
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

public slots:
    void start(const QVariant &girlIdsVar, const QVariant &gameRule,
               int tempDelaer);
    void action(QString actStr, const QVariant &actArg);
    void saveRecord();

private:
    saki::Action makeAction(const QString &actStr, const QVariant &actArg);

private:
    std::unique_ptr<saki::Table> mTable;
    std::array<std::unique_ptr<saki::Ai>, 3> mAis;
    saki::Replay mReplay;
};

#endif // P_TABLE_LOCAL_H
