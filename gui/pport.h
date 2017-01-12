#ifndef PPORT_H
#define PPORT_H

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



QVariant createTileVar(const saki::T37 &t, bool lay = false);
QVariant createTilesVar(const saki::TileCount &count);
QVariant createTilesVar(const std::vector<saki::T37> &tiles);
QVariant createSwapMask(const saki::TileCount &count,
                        const std::vector<saki::T37> &choices);
QVariant createBarkVar(const saki::M37 &m);
QVariant createBarksVar(const std::vector<saki::M37> &ms);
QVariant createFormVar(const char *spell, const char *charge,
                       const saki::Hand &hand, const saki::T37 &pick);
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

template<typename T>
QJsonArray std2json(const T &arr);



#endif // PPORT_H


