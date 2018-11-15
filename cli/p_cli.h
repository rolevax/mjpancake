#ifndef P_CLI_H
#define P_CLI_H

#include "libsaki/app/table_server_ai3.h"
#include "libsaki/table/table_env_stub.h"

#include <QJsonObject>
#include <QSet>



class PCli
{
public:
    explicit PCli(const QJsonObject &config);
    void command(const QString &cmd);

private:
    void handleTableMsgs(const saki::TableServerAi3::Msgs &msgs);
    void handleTableMsg(const saki::TableMsgContent &msg);

    void printHand();

private:
    std::unique_ptr<saki::TableServerAi3> mServer;
    saki::TableEnvStub mTableEnv;
    QSet<QString> mHand;
};



#endif // P_CLI_H
