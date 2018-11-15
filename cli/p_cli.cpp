#include "p_cli.h"

#include "gui/p_editor.h"
#include "gui/p_port.h"

#include "libsaki/app/girl_x.h"
#include "libsaki/ai/ai.h"

#include <QJsonDocument>
#include <QJsonArray>
#include <QDebug>

using namespace saki;

PCli::PCli(const QJsonObject &config)
{
    QJsonArray girlKeys = config["girls"].toArray();

    std::array<std::unique_ptr<Girl>, 4> girls;
    for (int w = 0; w < 4; w++) {
        QJsonObject girl = girlKeys[w].toObject();
        Girl::Id id = static_cast<Girl::Id>(girl["id"].toInt());
        QString path = girl["path"].toString();
        qDebug() << "create girl:" << static_cast<int>(id) << path;
        if (id == Girl::Id::CUSTOM) {
            QString luaCode = PEditor::instance().getLuaCode(path);
            girls[w] = std::make_unique<GirlX>(Who(w), luaCode.toStdString());
        } else {
            girls[w] = Girl::create(Who(w), id);
        }
    }

    TableServerAi3::Ai3 ai3;
    for (int w = 0; w < 3; w++)
        ai3[w] = Ai::create(girls[w + 1]->getId());

    Rule rule = readRuleJson(config["rule"].toObject());

    std::array<int, 4> points;
    points.fill(rule.returnLevel - rule.hill / 4);

    std::vector<TableObserver *> obs {};
    Table::InitConfig args { points, std::move(girls), rule, Who(1) };

    mServer = std::make_unique<TableServerAi3>(std::move(args), obs, mTableEnv, std::move(ai3));
    qDebug() << "table ai3 server created";
}

void PCli::command(const QString &line)
{
    QStringList split = line.split(' ');
    if (split.empty())
        return;

    QString cmd = split.front();
    split.pop_front();
    if (cmd == "start") {
        handleTableMsgs(mServer->start());
    } else if (cmd == "swap") {
        Action action = readAction("SWAP_OUT", 0, split[0]);
        handleTableMsgs(mServer->action(action));
    } else if (cmd == "spin") {
        Action action = readAction("SPIN_OUT", 0, "");
        handleTableMsgs(mServer->action(action));
    } else if (cmd == "pass") {
        Action action = readAction("PASS", 0, "");
        handleTableMsgs(mServer->action(action));
    } else if (cmd == "dice") {
        Action action = readAction("DICE", 0, "");
        handleTableMsgs(mServer->action(action));
    } else if (cmd == "hand") {
        printHand();
    } else {
        qDebug() << "unkown command:" << cmd;
    }
}

void PCli::handleTableMsgs(const TableServerAi3::Msgs &msgs)
{
    for (const TableMsgContent &msg : msgs)
        handleTableMsg(msg);
}

void PCli::handleTableMsg(const TableMsgContent &msg)
{
    QString event = QString::fromStdString(msg.event());
    QByteArray json = QByteArray::fromStdString(msg.args().dump());
    QJsonObject args = QJsonDocument::fromJson(json).object();

    if (event == "just-pause")
        return;

    if (event == "dealt") {
        mHand.clear();
        QJsonArray init = args["init"].toArray();
        for (QJsonValue value : init)
            mHand.insert(value.toString());
    } else if (event == "discarded") {
        QString who = QString("[%1] ->").arg(args["who"].toInt());
        QString tile = args["tile"].toString();
        QString spin = args["spin"].toBool() ? "spin" : "";
        qDebug().noquote() << who << tile << spin;
    } else if (event == "drawn") {
        //
    } else if (event == "cleaned") {
    } else if (event == "activated") {
        QJsonObject action = args["action"].toObject();
        qDebug() << "Action choices:";
        for (const auto &act : action.keys())
            qDebug() << "    " << act << action[act];
    } else if (event == "popped-up") {
        QString str = args["str"].toString();
        qDebug() << "==== pop up ====";
        qDebug().noquote() << str;
        qDebug() << "================";
    } else {
        qDebug() << event << args;
    }
}

void PCli::printHand()
{
    const Hand &hand = mServer->table().getHand(Who(0));
    std::cout << hand.closed().t37s13(true);
    if (hand.hasDrawn())
        std::cout << ' ' << hand.drawn();

    std::cout << std::endl;
}
