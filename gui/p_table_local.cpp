#include "p_table_local.h"
#include "p_port.h"
#include "p_global.h"
#include "p_editor.h"

#include "libsaki/app/girl_x.h"
#include "libsaki/ai/ai_stub.h"
#include "libsaki/util/rand.h"
#include "libsaki/util/string_enum.h"
#include "libsaki/util/misc.h"

#include <QFile>
#include <QDateTime>
#include <QStandardPaths>
#include <QJsonDocument>
#include <QJsonObject>

#include <sstream>
#include <fstream>
#include <iostream>
#include <cassert>



using namespace saki;



PTableLocal::PTableLocal(QObject *parent)
    : QObject(parent)
{
}

void PTableLocal::start(const QVariant &girlKeys, const QVariant &gameRule, int tempDelaer)
{
    QVariantList list = girlKeys.toList();
    std::array<Girl::Id, 4> girlIds;
    std::array<QString, 4> girlPaths;
    for (int w = 0; w < 4; w++) {
        QVariantMap map = list[w].toMap();
        girlIds[w] = static_cast<Girl::Id>(map["id"].toInt());
        girlPaths[w] = map["path"].toString();
    }

    Rule rule = readRuleJson(QJsonObject::fromVariantMap(gameRule.toMap()));

    std::array<int, 4> points {
        rule.returnLevel - rule.hill / 4,
        rule.returnLevel - rule.hill / 4,
        rule.returnLevel - rule.hill / 4,
        rule.returnLevel - rule.hill / 4,
    };

    std::array<std::unique_ptr<Girl>, 4> girls;
    for (int w = 0; w < 4; w++) {
        if (girlIds[w] == Girl::Id::CUSTOM) {
            QString luaCode = PEditor::instance().getLuaCode(girlPaths[w]);
            girls[w] = std::make_unique<GirlX>(Who(w), luaCode.toStdString());
        } else {
            girls[w] = Girl::create(Who(w), girlIds[w]);
        }
    }

    TableServerAi3::Ai3 ai3;
    for (int w = 0; w < 3; w++)
        ai3[w] = Ai::create(girls[w + 1]->getId());

    std::vector<TableObserver *> obs { &mReplay };
    Table::InitConfig config { points, std::move(girls), rule, Who(tempDelaer) };

    mServer = std::make_unique<TableServerAi3>(std::move(config), obs, mTableEnv, std::move(ai3));
    auto msgs = mServer->start();
    handleTableMsgs(msgs);
}

void PTableLocal::action(const QString &actStr, int actArg, const QString &actTile, int nonce)
{
    (void) nonce;

    Action action = readAction(actStr, actArg, actTile);
    auto msgs = mServer->action(action);
    handleTableMsgs(msgs);
}

void PTableLocal::saveRecord()
{
    QString path(PGlobal::replayPath());

    QString datetime(QDateTime::currentDateTime().toString("yyMMdd_HHmm"));
    QString extension(".pai.json");
    int serial = 0;

    // *INDENT-OFF*
    auto makeFilename = [&]() {
        return path + '/' + datetime + '_' + QString::number(serial++) + extension;
    };
    // *INDENT-ON*

    QString filename;
    // this loop is useless in most cases, but just to be robust.
    do {
        filename = makeFilename();
    } while (QFile(filename).exists());

    QJsonDocument doc(createReplayJson(mReplay));

    QFile file(filename);
    if (file.open(QIODevice::WriteOnly | QIODevice::Text))
        file.write(doc.toJson(QJsonDocument::Compact));

    file.close();
}

void PTableLocal::emitJustPause(int ms)
{
    QVariantMap args;
    args["ms"] = ms;
    emit tableEvent("just-pause", args);
}

void PTableLocal::handleTableMsgs(const TableServerAi3::Msgs &msgs)
{
    for (const TableMsgContent &msg : msgs)
        handleTableMsg(msg);
}

void PTableLocal::handleTableMsg(const TableMsgContent &msg)
{
//    if (mPrac && choices.can(ActCode::PASS)) {
//        mTableServer->action(whos::HUMAN, Action(ActCode::PASS), choices.nonce());
//        return false;
//    }

    QString event = QString::fromStdString(msg.event());
    QByteArray json = QByteArray::fromStdString(msg.args().dump());
    QJsonObject args = QJsonDocument::fromJson(json).object();
    emit tableEvent(event, args.toVariantMap());
}
