#include "gui/p_port.h"
#include "libsaki/tableobserver.h"
#include "libsaki/myrand.h"
#include "libsaki/girl.h"
#include "libsaki/replay.h"
#include "libsaki/string_enum.h"
#include "libsaki/util.h"

#include <sstream>
#include <cassert>
#include <cstdlib>



QVariant createTileVar(const saki::T37 &t, bool lay)
{
    QVariantMap map;
    map.insert("modelTileStr", QString(t.str()));
    map.insert("modelLay", lay);
    return QVariant::fromValue(map);
}

QVariant createTilesVar(const saki::TileCount &count)
{
    QVariantList list;
    for (int ti = 0; ti < 34; ti++) {
        saki::T37 tile(ti);
        if (tile.val() == 5) {
            int red = count.ct(tile.toAka5());
            int black = count.ct(tile);
            while(red --> 0)
                list << createTileVar(tile.toAka5());
            while (black --> 0)
                list << createTileVar(tile);
        } else {
            int ct = count.ct(tile);
            while (ct --> 0)
                list << createTileVar(tile);
        }
    }

    return QVariant::fromValue(list);
}

QVariant createTilesVar(const std::vector<saki::T37> &tiles)
{
    QVariantList list;

    for (const saki::T37 &t : tiles)
        list << createTileVar(t, false);

    return QVariant::fromValue(list);
}

QVariant createTileStrsVar(const std::vector<saki::T34> &tiles)
{
    QVariantList list;

    for (saki::T34 t : tiles)
        list << QString(t.str());

    return QVariant::fromValue(list);
}

QVariant createSwapMask(const saki::TileCount &count,
                        const std::vector<saki::T37> &choices)
{
    // assume 'choices' is 34-sorted
    QVariantList list;

    auto it = choices.begin();
    for (const saki::T37 &t : saki::tiles37::ORDER37) {
        if (it == choices.end())
            break;
        int ct = count.ct(t);
        if (ct > 0) {
            bool val = t.looksSame(*it);
            while (ct --> 0)
                list << val;
            it += val; // consume choice if matched
        }
    }

    return QVariant::fromValue(list);
}

QVariant createBarkVar(const saki::M37 &m)
{
    QVariantMap map;

    // save typing
    using Type = saki::M37::Type;
    saki::M37::Type type = m.type();

    map.insert("type", type == Type::CHII ? 1 : (type == Type::PON ? 3 : 4));
    int open = m.layIndex();
    if (type != Type::ANKAN)
        map.insert("open", open);

    map.insert("0", createTileVar(m[0], open == 0));
    map.insert("1", createTileVar(m[1], open == 1));
    map.insert("2", createTileVar(m[2], open == 2));

    if (m.isKan()) {
        map.insert("3", createTileVar(m[3], type == Type::KAKAN));
        map.insert("isDaiminkan", type == Type::DAIMINKAN);
        map.insert("isAnkan", type == Type::ANKAN);
        map.insert("isKakan", type == Type::KAKAN);
    }

    return QVariant::fromValue(map);
}

QVariant createFormVar(const char *spell, const char *charge,
                       const saki::Hand &hand, const saki::T37 &pick)
{
    QVariantMap map;

    map.insert("spell", QString(spell));
    map.insert("charge", QString(charge));
    map.insert("hand", createTilesVar(hand.closed()));
    map.insert("pick", createTileVar(pick, true));
    map.insert("barks", createBarksVar(hand.barks()));

    return QVariant::fromValue(map);
}

QVariant createBarksVar(const std::vector<saki::M37> &ms)
{
    QVariantList list;
    for (const saki::M37 &m : ms)
        list << createBarkVar(m);
    return QVariant::fromValue(list);
}

QVariant createIrsCheckRowVar(const saki::IrsCheckRow &row)
{
    QVariantMap map;

    map.insert("modelMono", row.mono);
    map.insert("modelIndent", row.indent);
    map.insert("modelText", QString(row.name));
    map.insert("modelAble", row.able);
    map.insert("modelOn", row.on);

    return QVariant::fromValue(map);
}



QVariantMap createTableSnapMap(const saki::TableSnap &snap)
{
    QVariantMap map;

    map.insert("whoDrawn", snap.whoDrawn.somebody() ? snap.whoDrawn.index() : -1);
    map.insert("drawn", createTileVar(snap.drawn));

    QVariantList points;
    for (int p : snap.points)
        points << p;
    map.insert("points", points);

    map.insert("wallRemain", snap.wallRemain);
    map.insert("drids", createTilesVar(snap.drids));
    map.insert("urids", createTilesVar(snap.urids));

    QVariantList players;
    for (int w = 0; w < 4; w++) {
        const saki::PlayerSnap &player = snap[w];
        QVariantMap playerMap;
        playerMap.insert("hand", createTilesVar(player.hand));
        playerMap.insert("barks", createBarksVar(player.barks));
        QVariantList river;
        for (int i = 0; i < int(player.river.size()); i++)
            river << createTileVar(player.river[i], i == player.riichiPos);
        playerMap.insert("river", river);
        playerMap.insert("riichiBar", player.riichiBar);
        players.append(playerMap);
    }

    map.insert("players", players);

    map.insert("round", snap.round);
    map.insert("extraRound", snap.extraRound);
    map.insert("dealer", snap.dealer.index());
    map.insert("allLast", snap.allLast);
    map.insert("deposit", snap.deposit);
    map.insert("state", snap.state);
    map.insert("die1", snap.die1);
    map.insert("die2", snap.die2);
    map.insert("result", QString(saki::stringOf(snap.result)));
    map.insert("endOfRound", snap.endOfRound);
    map.insert("gunner", snap.gunner.somebody() ? snap.gunner.index() : -1);

    QVariantList openers;
    for (saki::Who opener : snap.openers)
        openers << opener.index();
    map.insert("openers", openers);

    QVariantList forms;
    for (size_t i = 0; i < snap.spells.size(); i++) {
        int opener = snap.openers[i].index();
        const saki::T37 &pick = snap.result == saki::RoundResult::TSUMO ? snap.drawn
                                                                        : snap.cannon;
        forms << createFormVar(snap.spells[i].c_str(), snap.charges[i].c_str(),
                               saki::Hand(saki::TileCount(snap[opener].hand),
                                          snap[opener].barks),
                               pick);
    }
    map.insert("forms", forms);

    return map;
}



QJsonObject createReplayJson(const saki::Replay &replay)
{
    QJsonObject root;

    root["version"] = 3;

    QVariantList girls;
    for (saki::Girl::Id v : replay.girls)
        girls << static_cast<int>(v);
    root["girls"] = QJsonArray::fromVariantList(girls);

    root["initPoints"] = std2json(replay.initPoints);
    root["rule"] = createRuleJson(replay.rule);
    root["seed"] = QString::number(replay.seed);

    QJsonArray arr;
    for (const saki::Replay::Round &round : replay.rounds)
        arr.append(createRoundJson(round));
    root["rounds"] = arr;

    return root;
}

QJsonObject createRuleJson(const saki::RuleInfo &rule)
{
    QJsonObject obj;

    obj["fly"] = rule.fly;
    obj["headJump"] = rule.headJump;
    obj["nagashimangan"] = rule.nagashimangan;
    obj["ippatsu"] = rule.ippatsu;
    obj["uradora"] = rule.uradora;
    obj["kandora"] = rule.kandora;
    obj["akadora"] = int(rule.akadora);
    obj["hill"] = rule.hill;
    obj["returnLevel"] = rule.returnLevel;
    obj["roundLimit"] = rule.roundLimit;

    return obj;
}

QJsonObject createRoundJson(const saki::Replay::Round &round)
{
    QJsonObject obj;

    obj["round"] = round.round;
    obj["extraRound"] = round.extraRound;
    obj["dealer"] = round.dealer.index();
    obj["allLast"] = round.allLast;
    obj["deposit"] = round.deposit;
    obj["state"] = QString::number(round.state);
    obj["die1"] = round.die1;
    obj["die2"] = round.die2;
    obj["result"] = saki::stringOf(round.result);
    obj["resultPoints"] = std2json(round.resultPoints);

    QJsonArray spells;
    for (const std::string &spell : round.spells)
        spells.append(QString::fromStdString(spell));
    obj["spells"] = spells;

    QJsonArray charges;
    for (const std::string &charge : round.charges)
        charges.append(QString::fromStdString(charge));
    obj["charges"] = charges;

    QJsonArray drids;
    for (const saki::T37 &t : round.drids)
        drids.append(t.str());
    obj["drids"] = drids;

    QJsonArray urids;
    for (const saki::T37 &t : round.urids)
        urids.append(t.str());
    obj["urids"] = urids;

    obj["tracks"] = QJsonArray {
        createTrackJson(round.tracks[0]), createTrackJson(round.tracks[1]),
        createTrackJson(round.tracks[2]), createTrackJson(round.tracks[3])
    };

    return obj;
}

QJsonObject createTrackJson(const saki::Replay::Track &track)
{
    auto inJson = [](saki::Replay::InAct inAct) {
        using In = saki::Replay::In;
        switch (inAct.act) {
        case In::DRAW:
            return QString(inAct.t37.str());
        case In::CHII_AS_LEFT: // 'b' means 'begin'
            return QString("b") + QString::number(inAct.showAka5);
        case In::CHII_AS_MIDDLE: // 'm' means 'middle'
            return QString("m") + QString::number(inAct.showAka5);
        case In::CHII_AS_RIGHT: // 'e' means 'end'
            return QString("e") + QString::number(inAct.showAka5);
        case In::PON:
            return QString("p") + QString::number(inAct.showAka5);
        case In::DAIMINKAN:
            return QString("d");
        case In::RON:
            return QString("r");
        case In::SKIP_IN:
            return QString("--");
        default:
            return QString("err");
        }
    };

    auto outJson = [](saki::Replay::OutAct outAct) {
        using Out = saki::Replay::Out;
        switch (outAct.act) {
        case Out::ADVANCE:
            return QString(outAct.t37.str());
        case Out::SPIN:
            return QString("->");
        case Out::RIICHI_ADVANCE:
            return QString("!") + outAct.t37.str();
        case Out::RIICHI_SPIN:
            return QString("!->");
        case Out::ANKAN:
            return QString("a") + outAct.t37.str();
        case Out::KAKAN:
            return QString("k") + outAct.t37.str();
        case Out::RYUUKYOKU:
            return QString("~");
        case Out::TSUMO:
            return QString("t");
        case Out::SKIP_OUT:
            return QString("--");
        default:
            return QString("err");
        }
    };

    QJsonObject obj;

    QJsonArray initArr;
    for (const saki::T37 &t : track.init)
        initArr.append(t.str());
    obj["init"] = initArr;

    QJsonArray inArr;
    for (const saki::Replay::InAct &inAct : track.in)
        inArr.append(inJson(inAct));
    obj["in"] = inArr;

    QJsonArray outArr;
    for (const saki::Replay::OutAct &outAct : track.out)
        outArr.append(outJson(outAct));
    obj["out"] = outArr;

    return obj;
}



saki::Replay readReplayJson(const QJsonObject &obj)
{
    saki::Replay replay;

    assert(obj["version"].toInt() == 3);
    for (int i = 0; i < 4; i++) {
        replay.girls[i] = saki::Girl::Id(obj["girls"].toArray().at(i).toInt());
        replay.initPoints[i] = obj["initPoints"].toArray().at(i).toInt();
    }

    replay.rule = readRuleJson(obj["rule"].toObject());
    replay.seed = obj["seed"].toString().toUInt(); // assume UInt works for uint32_t

    const QJsonArray &arr = obj["rounds"].toArray();
    for (auto it = arr.begin(); it != arr.end(); ++it)
        replay.rounds.emplace_back(readRoundJson(it->toObject()));

    return replay;
}

saki::RuleInfo readRuleJson(const QJsonObject &obj)
{
    saki::RuleInfo rule;

    rule.fly = obj["fly"].toBool();
    rule.headJump = obj["headJump"].toBool();
    rule.nagashimangan = obj["nagashimangan"].toBool();
    rule.ippatsu = obj["ippatsu"].toBool();
    rule.uradora = obj["uradora"].toBool();
    rule.kandora = obj["kandora"].toBool();
    rule.akadora = saki::TileCount::AkadoraCount(obj["akadora"].toInt());
    rule.hill = obj["hill"].toInt();
    rule.returnLevel = obj["returnLevel"].toInt();
    rule.roundLimit = obj["roundLimit"].toInt();

    return rule;
}

saki::Replay::Round readRoundJson(const QJsonObject &obj)
{
    saki::Replay::Round round;

    round.round = obj["round"].toInt();
    round.extraRound = obj["extraRound"].toInt();
    round.dealer = saki::Who(obj["dealer"].toInt());
    round.allLast = obj["allLast"].toBool();
    round.deposit = obj["deposit"].toInt();
    round.state = obj["state"].toString().toUInt(); // assume UInt work with uint32_t
    round.die1 = obj["die1"].toInt();
    round.die2 = obj["die2"].toInt();

    round.result = saki::roundResultOf(obj["result"].toString().toLatin1().data());

    for (int i = 0; i < 4; i++)
        round.resultPoints[i] = obj["resultPoints"].toArray().at(i).toInt();

    QJsonArray drids = obj["drids"].toArray();
    for (auto it = drids.begin(); it != drids.end(); ++it)
        round.drids.emplace_back(it->toString().toLatin1().data());

    QJsonArray urids = obj["urids"].toArray();
    for (auto it = urids.begin(); it != urids.end(); ++it)
        round.urids.emplace_back(it->toString().toLatin1().data());

    QJsonArray tracks = obj["tracks"].toArray();
    for (int i = 0; i < 4; i++)
        round.tracks[i] = readTrackJson(tracks.at(i).toObject());

    QJsonArray spells = obj["spells"].toArray();
    for (auto it = spells.begin(); it != spells.end(); ++it)
        round.spells.push_back(it->toString().toStdString());

    QJsonArray charges = obj["charges"].toArray();
    for (auto it = charges.begin(); it != charges.end(); ++it)
        round.charges.push_back(it->toString().toStdString());

    return round;
}

saki::Replay::Track readTrackJson(const QJsonObject &obj)
{
    auto inAct = [](const QString &qstr) {
        using In = saki::Replay::In;
        using InAct = saki::Replay::InAct;
        QByteArray ba = qstr.toLatin1();
        const char *str = ba.data();

        if (std::isdigit(str[0])) {
            return InAct(In::DRAW, saki::T37(str));
        } else if (str[0] == 'b') {
            return InAct(In::CHII_AS_LEFT, str[1] - '0');
        } else if (str[0] == 'm') {
            return InAct(In::CHII_AS_MIDDLE, str[1] - '0');
        } else if (str[0] == 'e') {
            return InAct(In::CHII_AS_RIGHT, str[1] - '0');
        } else if (str[0] == 'p') {
            return InAct(In::PON, str[1] - '0');
        } else if (str[0] == 'd') {
            return InAct(In::DAIMINKAN);
        } else if (str[0] == 'r') {
            return InAct(In::RON);
        } else if (str[0] == '-') {
            assert(str[1] == '-');
            return InAct(In::SKIP_IN);
        } else {
            unreached("corrupted replay json (in)");
        }
    };

    auto outAct = [](const QString &qstr) {
        using Out = saki::Replay::Out;
        using OutAct = saki::Replay::OutAct;
        QByteArray ba = qstr.toLatin1();
        const char *str = ba.data();

        if (std::isdigit(str[0])) {
            return OutAct(Out::ADVANCE, saki::T37(str));
        } else if (str[0] == '-') {
            if (str[1] == '>') {
                return OutAct(Out::SPIN);
            } else {
                assert(str[1] == '-');
                return OutAct(Out::SKIP_OUT);
            }
        } else if (str[0] == '!') {
            if (str[1] == '-') {
                assert(str[2] == '>');
                return OutAct(Out::RIICHI_SPIN);
            } else {
                assert(std::isdigit(str[1]));
                return OutAct(Out::RIICHI_ADVANCE, saki::T37(str + 1));
            }
        } else if (str[0] == 'a') {
            return OutAct(Out::ANKAN, saki::T37(str + 1));
        } else if (str[0] == 'k') {
            return OutAct(Out::KAKAN, saki::T37(str + 1));
        } else if (str[0] == '~') {
            return OutAct(Out::RYUUKYOKU);
        } else if (str[0] == 't') {
            return OutAct(Out::TSUMO);
        } else {
            unreached("corrupted replay json (out)");
        }
    };

    saki::Replay::Track track;

    QJsonArray init = obj["init"].toArray();
    for (int i = 0; i < init.size(); i++)
        track.init[i] = saki::T37(init[i].toString().toLatin1().data());

    QJsonArray in = obj["in"].toArray();
    for (auto it = in.begin(); it != in.end(); ++it)
        track.in.emplace_back(inAct(it->toString()));

    QJsonArray out = obj["out"].toArray();
    for (auto it = out.begin(); it != out.end(); ++it)
        track.out.emplace_back(outAct(it->toString()));

    return track;
}



template<typename T>
QJsonArray std2json(const T &arr) {
    QVariantList list;
    for (int v : arr)
        list << v;
    return QJsonArray::fromVariantList(list);
}


