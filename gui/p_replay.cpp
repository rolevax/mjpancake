#include "p_replay.h"
#include "p_port.h"
#include "p_global.h"
#include "p_client.h"

#include "libsaki/util/misc.h"

#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>

#include <cassert>


std::map<int, saki::Replay> PReplay::sCachedReplays;
std::map<int, QVariantList> PReplay::sCachedUsers;

PReplay::PReplay(QObject *parent)
    : QObject(parent)
{
    connect(&PClient::instance(), &PClient::replayListIn, this, &PReplay::onlineReplayListReady);
    connect(&PClient::instance(), &PClient::replayIn, this, &PReplay::replayDownloaded);
    if (PClient::instance().loggedIn())
        PClient::instance().getReplayList();
}

QStringList PReplay::ls()
{
    QDir dir(PGlobal::replayPath());

    dir.setNameFilters(QStringList { QString("*.pai.json") });
    dir.setSorting(QDir::Time); // latest first

    return dir.entryList();
}

void PReplay::rm(QString filename)
{
    QFile::remove(PGlobal::replayPath(filename));
}

void PReplay::load(QString filename)
{
    mUsers.clear();

    QFile file(PGlobal::replayPath(filename));
    file.open(QIODevice::ReadOnly | QIODevice::Text);
    QString val = file.readAll();
    file.close();

    QJsonDocument d = QJsonDocument::fromJson(val.toUtf8());
    QJsonObject obj = d.object();

    mReplay = readReplayJson(obj);
    loaded = true;
}

void PReplay::fetch(int replayId)
{
    if (sCachedReplays.find(replayId) != sCachedReplays.end()) {
        useOnlineReplay(replayId);
    } else {
        PClient::instance().getReplay(replayId);
    }
}

QVariantMap PReplay::meta()
{
    assert(loaded);

    QStringList roundNames;
    for (const saki::Replay::Round &round : mReplay.rounds) {
        std::array<const char *, 4> WINDS { "E", "S", "W", "N" };
        QString str(WINDS[round.round / 4]);
        str += QString::number(round.round % 4 + 1);
        str += ".";
        str += QString::number(round.extraRound);
        roundNames << str;
    }

    QVariantList girlIds;
    for (int w = 0; w < 4; w++)
        girlIds << static_cast<int>(mReplay.girls[w]);

    QVariantMap map;
    map.insert("roundNames", roundNames);
    map.insert("girlIds", girlIds);
    map.insert("seed", mReplay.seed);

    if (!mUsers.empty())
        map.insert("users", mUsers);

    return map;
}

QVariantMap PReplay::look(int roundId, int turn)
{
    assert(loaded);
    saki::TableSnap snap = mReplay.look(roundId, turn);
    return createTableSnapMap(snap);
}

void PReplay::replayDownloaded(int id, const QString &json)
{
    QJsonObject obj = QJsonDocument::fromJson(json.toUtf8()).object();
    sCachedReplays[id] = readReplayJson(obj);
    sCachedUsers[id] = obj["users"].toArray().toVariantList();
    useOnlineReplay(id);
}

void PReplay::useOnlineReplay(int id)
{
    mReplay = sCachedReplays[id];
    mUsers = sCachedUsers[id];
    loaded = true;
    emit onlineReplayReady();
}

