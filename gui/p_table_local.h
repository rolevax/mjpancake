#ifndef P_TABLE_LOCAL_H
#define P_TABLE_LOCAL_H

#include "p_table.h"
#include "p_table_env.h"

#include "libsaki/app/table_server_ai3.h"
#include "libsaki/app/replay.h"

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <memory>
#include <vector>



class PTableLocal : public QObject
{
    Q_OBJECT

public:
    explicit PTableLocal(QObject *parent = nullptr);

    using Table = saki::Table;

signals:
    void tableEvent(const QString &type, const QVariantMap &args);

public slots:
    void start(const QVariant &girlKeys, const QVariant &gameRule, int tempDelaer);
    void action(const QString &actStr, int actArg, const QString &actTile, int nonce);
    void saveRecord();

private:
    void emitJustPause(int ms);
    void handleTableMsgs(const saki::TableServerAi3::Msgs &msgs);
    void handleTableMsg(const saki::TableMsgContent &msg);

private:
    std::unique_ptr<saki::TableServerAi3> mServer;
    saki::Replay mReplay;
    PTableEnv mTableEnv;
};

#endif // P_TABLE_LOCAL_H
