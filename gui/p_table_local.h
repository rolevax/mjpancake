#ifndef P_TABLE_LOCAL_H
#define P_TABLE_LOCAL_H

#include "p_table.h"

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
    void onPoppedUp(const saki::Table &table, saki::Who who) override;

    void onActivated(saki::Table &table) override;

signals:
    void tableEvent(PTable::Event type, const QVariantMap &args);

public slots:
    void start(const QVariant &girlIdsVar, const QVariant &gameRule, int tempDelaer);
    void startPrac(int girlId);
    void action(const QString &actStr, int actArg, const QString &actTile);
    void saveRecord();

private:
    void emitJustPause(int ms);

private:
    std::unique_ptr<saki::Table> mTable;
    std::array<std::unique_ptr<saki::Ai>, 3> mAis;
    saki::Replay mReplay;
    bool mPrac;
};

#endif // P_TABLE_LOCAL_H
