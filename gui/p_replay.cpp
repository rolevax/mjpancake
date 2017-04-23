#include "p_replay.h"
#include "p_port.h"
#include "p_global.h"

#include "libsaki/util.h"

#include <QDir>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>

#include <cassert>



PReplay::PReplay(QObject *parent)
    : QObject(parent)
{

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
    QFile file(PGlobal::replayPath(filename));
    file.open(QIODevice::ReadOnly | QIODevice::Text);
    QString val = file.readAll();
    file.close();

    QJsonDocument d = QJsonDocument::fromJson(val.toUtf8());
    QJsonObject obj = d.object();

    replay = readReplayJson(obj);
    loaded = true;
}

QVariantMap PReplay::meta()
{
    assert(loaded);

    QStringList roundNames;
    for (const saki::Replay::Round &round : replay.rounds) {
        std::array<const char *, 4> WINDS { "E", "S", "W", "N" };
        QString str(WINDS[round.round / 4]);
        str += QString::number(round.round % 4 + 1);
        str += ".";
        str += QString::number(round.extraRound);
        roundNames << str;
    }

    QVariantList girlIds;
    for (int w = 0; w < 4; w++)
        girlIds << static_cast<int>(replay.girls[w]);

    QVariantMap map;
    map.insert("roundNames", roundNames);
    map.insert("girlIds", girlIds);
    map.insert("seed", replay.seed);

    return map;
}

QVariantMap PReplay::look(int roundId, int turn)
{
    assert(loaded);
    saki::TableSnap snap = replay.look(roundId, turn);
    return createTableSnapMap(snap);
}

