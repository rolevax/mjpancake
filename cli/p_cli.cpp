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
            girls[decltype(girls)::size_type(w)] = std::make_unique<GirlX>(Who(w), luaCode.toStdString());
        } else {
            girls[decltype(girls)::size_type(w)] = Girl::create(Who(w), id);
        }
    }

    TableServerAi3::Ai3 ai3;
    for (decltype(ai3)::size_type w = 0; w < 3; w++)
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

    auto simpleCmd = [this](const QString &cmd) {
        Action action = readAction(cmd, 0, "");
        handleTableMsgs(mServer->action(action));
    };

    QString cmd = split.front();
    split.pop_front();
    if (cmd == "start") {
        handleTableMsgs(mServer->start());
    } else if (cmd == "swap") {
        Action action = readAction("SWAP_OUT", 0, split[0]);
        handleTableMsgs(mServer->action(action));
    } else if (cmd == "spin") {
        simpleCmd("SPIN_OUT");
    } else if (cmd == "irs_check") {
        if (split.size() != 1) {
            qDebug() << "need one argument: irs_check binary mask";
            return;
        }

        Action action = readAction("IRS_CHECK", split[0].toInt(nullptr, 2), "");
        handleTableMsgs(mServer->action(action));
    } else if (cmd == "next") {
        simpleCmd("NEXT_ROUND");
    } else if (cmd == "pass"
            || cmd == "spin"
            || cmd == "dice"
            || cmd == "tsumo"
            || cmd == "ron"
            || cmd == "irs_click"
            || cmd == "next_round") {
        simpleCmd(cmd.toUpper());
    } else if (cmd == "hand") {
        int who = 0;
        if (!split.empty())
            who = split[0].toInt();

        printHand(who);
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

    if (event == "round-started"
            || event == "first-dealer-chosen") {
        // nop
    } else if (event == "flipped") {
        qDebug() << "new dora indic:" << args["newIndic"].toString();
    } else if (event == "diced") {
        qDebug() << "dice:" << args["die1"].toInt() << args["die2"].toInt();
    } else if (event == "points-changed") {
        QJsonArray array = args["points"].toArray();
        std::array<int, 4> points;
        std::transform(array.begin(), array.end(), points.begin(),
                       [](const QJsonValue &v) { return v.toInt(); });
        qDebug().nospace() << "       " << points[2] << '\n'
                           << points[3] << "         " << points[1] << '\n'
                           << "       " << points[0];
    } else if (event == "dealt") {
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

        if (!action["SPIN_OUT"].isNull())
            printHand(0);
    } else if (event == "popped-up") {
        QString str = args["str"].toString();
        qDebug() << "==== pop up ====";
        qDebug().noquote() << str;
        qDebug() << "================";
    } else {
        QString json = QJsonDocument(args).toJson();
        qDebug().noquote() << event << json;
    }
}

void PCli::printHand(int who)
{
    const Hand &hand = mServer->table().getHand(Who(who));
    auto closed = hand.closed().t37s13(true);
    for (auto it = closed.begin(); it != closed.end(); ++it) {
        const T37 &curr = *it;
        if (it != closed.begin()) {
            const T37 &prev = *(it - 1);
            if (curr.suit() != prev.suit())
                std::cout << T34::charOf(prev.suit()) << ' ';
        }

        std::cout << (curr.isAka5() ? 0 : curr.val());
    }

    std::cout << T34::charOf(closed.back().suit());

    if (hand.hasDrawn())
        std::cout << ' ' << hand.drawn();

    std::cout << std::endl;
}
