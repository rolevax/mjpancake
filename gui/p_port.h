#ifndef P_PORT_H
#define P_PORT_H

#include "libsaki/tile_count.h"
#include "libsaki/form.h"
#include "libsaki/replay.h"

#include <QVariant>
#include <QVariantList>
#include <QVariantMap>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

#include <vector>



namespace saki
{
    struct IrsCheckRow;
    enum class RoundResult;
    class TableView;
}



QString createTileVar(const saki::T37 &t, bool lay = false);
QStringList createTilesVar(const saki::TileCount &count);
QStringList createTilesVar(const std::vector<saki::T37> &tiles);
QStringList createTilesVar(const saki::util::Range<saki::T37> &tiles);
QVariant createTileStrsVar(const saki::util::Range<saki::T34> &tiles);
unsigned createSwapMask(const saki::TileCount &count,
                        const saki::util::Stactor<saki::T37, 13> &choices);
QVariant createBarkVar(const saki::M37 &m);
QVariant createBarksVar(const saki::util::Stactor<saki::M37, 4> &ms);
QVariantMap createFormVar(const char *spell, const char *charge);
QVariant createIrsCheckRowVar(const saki::IrsCheckRow &row);

QVariantMap createTableSnapMap(const saki::TableSnap &snap);

QJsonObject createReplayJson(const saki::Replay &replay);
QJsonObject createRuleJson(const saki::RuleInfo &rule);
QJsonObject createRoundJson(const saki::Replay::Round &round);
QJsonObject createTrackJson(const saki::Replay::Track &track);

QVariantMap createActivation(const saki::TableView &view);

saki::Replay readReplayJson(const QJsonObject &obj);
saki::RuleInfo readRuleJson(const QJsonObject &obj);
saki::Replay::Round readRoundJson(const QJsonObject &obj);
saki::Replay::Track readTrackJson(const QJsonObject &obj);

saki::Action readAction(const QString &actStr, int actArg, const QString &actTile);

template<typename T>
QJsonArray std2json(const T &arr);



#endif // P_PORT_H


