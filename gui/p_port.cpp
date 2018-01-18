#include "p_port.h"
#include "p_global.h"

#include "libsaki/table/table_observer.h"
#include "libsaki/table/table_view.h"
#include "libsaki/table/girl.h"
#include "libsaki/app/replay.h"
#include "libsaki/util/string_enum.h"
#include "libsaki/util/misc.h"
#include "libsaki/app/table_msg.h"

#include <bitset>
#include <sstream>
#include <cassert>
#include <cstdlib>



using namespace saki;

QJsonObject jsonOf(const std::string &json)
{
    QByteArray ba = QByteArray::fromStdString(json);
    QJsonDocument jd = QJsonDocument::fromJson(ba);
    return jd.object();
}

QVariant varOfJson(const std::string &json)
{
    QByteArray ba = QByteArray::fromStdString(json);
    QJsonDocument jd = QJsonDocument::fromJson(ba);
    if (jd.isArray()) {
        return jd.array().toVariantList();
    } else {
        return jd.object().toVariantMap();
    }
}

QString createTileVar(const T37 &t, bool lay)
{
    return QString::fromStdString(stringOf(t, lay));
}

QVariant createTilesVar(const util::Range<T37> &tiles)
{
    return varOfJson(saki::marshal(tiles));
}

QVariant createTileStrsVar(const util::Range<T34> &tiles)
{
    return varOfJson(saki::marshal(tiles));
}

unsigned createSwapMask(const TileCount &count,
                        const util::Stactor<T37, 13> &choices)
{
    return saki::createSwapMask(count, choices);
}

QVariant createBarkVar(const M37 &m)
{
    return varOfJson(saki::marshal(m));
}

QVariantMap createFormVar(const char *spell, const char *charge)
{
    QVariantMap map;

    map.insert("spell", QString(spell));
    map.insert("charge", QString(charge));

    return map;
}

QVariant createBarksVar(const util::Stactor<M37, 4> &ms)
{
    return varOfJson(saki::marshal(ms));
}

QVariantMap createTableSnapMap(const TableSnap &snap)
{
    QVariantMap map;

    map.insert("whoDrawn", snap.whoDrawn.somebody() ? snap.whoDrawn.index() : -1);
    map.insert("drawn", createTileVar(snap.drawn));

    QVariantList points;
    for (int p : snap.points)
        points << p;

    map.insert("points", points);

    map.insert("wallRemain", snap.wallRemain);
    map.insert("deadRemain", snap.deadRemain);
    map.insert("drids", createTilesVar(snap.drids.range()));
    map.insert("urids", createTilesVar(snap.urids.range()));

    QVariantList players;
    for (int w = 0; w < 4; w++) {
        const PlayerSnap &player = snap[w];
        QVariantMap playerMap;
        playerMap.insert("hand", createTilesVar(player.hand.range()));
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
    map.insert("result", QString(util::stringOf(snap.result)));
    map.insert("endOfRound", snap.endOfRound);
    map.insert("gunner", snap.gunner.somebody() ? snap.gunner.index() : -1);
    using RR = RoundResult;
    if (snap.endOfRound && (snap.result == RR::RON || snap.result == RR::SCHR))
        map.insert("cannon", createTileVar(snap.cannon));

    QVariantList openers;
    for (Who opener : snap.openers)
        openers << opener.index();

    map.insert("openers", openers);

    QVariantList forms;
    for (size_t i = 0; i < snap.spells.size(); i++)
        forms << createFormVar(snap.spells[i].c_str(), snap.charges[i].c_str());

    map.insert("forms", forms);

    return map;
}



QJsonObject createReplayJson(const Replay &replay)
{
    return jsonOf(saki::marshal(replay));
}

QJsonObject createRuleJson(const Rule &rule)
{
    return jsonOf(saki::marshal(rule));
}

///
/// \deprecated Will be moved to libsaki
///
Replay readReplayJson(const QJsonObject &obj)
{
    Replay replay;

    assert(obj["version"].toInt() == 3);
    for (int i = 0; i < 4; i++) {
        replay.girls[i] = Girl::Id(obj["girls"].toArray().at(i).toInt());
        replay.initPoints[i] = obj["initPoints"].toArray().at(i).toInt();
    }

    replay.rule = readRuleJson(obj["rule"].toObject());
    replay.seed = obj["seed"].toString().toUInt(); // assume UInt works for uint32_t

    const QJsonArray &arr = obj["rounds"].toArray();
    for (auto it = arr.begin(); it != arr.end(); ++it)
        replay.rounds.emplace_back(readRoundJson(it->toObject()));

    return replay;
}

///
/// \deprecated Will be moved to libsaki
///
Rule readRuleJson(const QJsonObject &obj)
{
    Rule rule;

    rule.fly = obj["fly"].toBool();
    rule.headJump = obj["headJump"].toBool();
    rule.nagashimangan = obj["nagashimangan"].toBool();
    rule.ippatsu = obj["ippatsu"].toBool();
    rule.uradora = obj["uradora"].toBool();
    rule.kandora = obj["kandora"].toBool();
    rule.akadora = TileCount::AkadoraCount(obj["akadora"].toInt());
    // no pao in version <= 0.6.3, so use default 'false'
    rule.daiminkanPao = obj["daiminkanPao"].toBool(false);
    rule.hill = obj["hill"].toInt();
    rule.returnLevel = obj["returnLevel"].toInt();
    rule.roundLimit = obj["roundLimit"].toInt();

    return rule;
}

///
/// \deprecated Will be moved to libsaki
///
Replay::Round readRoundJson(const QJsonObject &obj)
{
    Replay::Round round;

    round.round = obj["round"].toInt();
    round.extraRound = obj["extraRound"].toInt();
    round.dealer = Who(obj["dealer"].toInt());
    round.allLast = obj["allLast"].toBool();
    round.deposit = obj["deposit"].toInt();
    round.state = obj["state"].toString().toUInt(); // assume UInt work with uint32_t
    round.die1 = obj["die1"].toInt();
    round.die2 = obj["die2"].toInt();

    round.result = util::roundResultOf(obj["result"].toString().toLatin1().data());

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

///
/// \deprecated Will be moved to libsaki
///
Replay::Track readTrackJson(const QJsonObject &obj)
{
    // *INDENT-OFF*
    auto inAct = [](const QString &qstr) {
        using In = Replay::In;
        using InAct = Replay::InAct;
        QByteArray ba = qstr.toLatin1();
        const char *str = ba.data();

        if (std::isdigit(str[0])) {
            return InAct(In::DRAW, T37(str));
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
        using Out = Replay::Out;
        using OutAct = Replay::OutAct;
        QByteArray ba = qstr.toLatin1();
        const char *str = ba.data();

        if (std::isdigit(str[0])) {
            return OutAct(Out::ADVANCE, T37(str));
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
                return OutAct(Out::RIICHI_ADVANCE, T37(str + 1));
            }
        } else if (str[0] == 'a') {
            return OutAct(Out::ANKAN, T37(str + 1));
        } else if (str[0] == 'k') {
            return OutAct(Out::KAKAN, T37(str + 1));
        } else if (str[0] == '~') {
            return OutAct(Out::RYUUKYOKU);
        } else if (str[0] == 't') {
            return OutAct(Out::TSUMO);
        } else {
            unreached("corrupted replay json (out)");
        }
    };
    // *INDENT-ON*

    Replay::Track track;

    QJsonArray init = obj["init"].toArray();
    for (int i = 0; i < init.size(); i++)
        track.init[i] = T37(init[i].toString().toLatin1().data());

    QJsonArray in = obj["in"].toArray();
    for (auto it = in.begin(); it != in.end(); ++it)
        track.in.emplace_back(inAct(it->toString()));

    QJsonArray out = obj["out"].toArray();
    for (auto it = out.begin(); it != out.end(); ++it)
        track.out.emplace_back(outAct(it->toString()));

    return track;
}

Action readAction(const QString &actStr, int actArg, const QString &actTile)
{
    return saki::makeAction(actStr.toStdString(), actArg, actTile.toStdString());
}
