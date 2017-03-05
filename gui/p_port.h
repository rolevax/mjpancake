#ifndef P_PORT_H
#define P_PORT_H

#include "libsaki/tilecount.h"
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
    class IrsCheckRow;
    enum class RoundResult;
}



QString createTileVar(const saki::T37 &t, bool lay = false);
QStringList createTilesVar(const saki::TileCount &count);
QStringList createTilesVar(const std::vector<saki::T37> &tiles);
QVariant createTileStrsVar(const std::vector<saki::T34> &tiles);
unsigned createSwapMask(const saki::TileCount &count,
                        const std::vector<saki::T37> &choices);
QVariant createBarkVar(const saki::M37 &m);
QVariant createBarksVar(const std::vector<saki::M37> &ms);
QVariantMap createFormVar(const char *spell, const char *charge);
QVariant createIrsCheckRowVar(const saki::IrsCheckRow &row);

QVariantMap createTableSnapMap(const saki::TableSnap &snap);

QJsonObject createReplayJson(const saki::Replay &replay);
QJsonObject createRuleJson(const saki::RuleInfo &rule);
QJsonObject createRoundJson(const saki::Replay::Round &round);
QJsonObject createTrackJson(const saki::Replay::Track &track);

saki::Replay readReplayJson(const QJsonObject &obj);
saki::RuleInfo readRuleJson(const QJsonObject &obj);
saki::Replay::Round readRoundJson(const QJsonObject &obj);
saki::Replay::Track readTrackJson(const QJsonObject &obj);

saki::Action readAction(const QString &actStr, const QVariant &actArg);

template<typename T>
QJsonArray std2json(const T &arr);



#endif // P_PORT_H


