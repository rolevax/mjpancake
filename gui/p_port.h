#ifndef P_PORT_H
#define P_PORT_H

#include "libsaki/form/tile_count.h"
#include "libsaki/form/form.h"
#include "libsaki/app/replay.h"

#include <QVariant>
#include <QVariantList>
#include <QVariantMap>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

#include <vector>



QJsonObject jsonOf(const std::string &json);
QVariant varOfJson(const std::string &json);

QString createTileVar(const saki::T37 &t, bool lay = false);
QVariant createTilesVar(const saki::util::Range<saki::T37> &tiles);
QVariant createTileStrsVar(const saki::util::Range<saki::T34> &tiles);
unsigned createSwapMask(const saki::TileCount &count,
                        const saki::util::Stactor<saki::T37, 13> &choices);
QVariant createBarkVar(const saki::M37 &m);
QVariant createBarksVar(const saki::util::Stactor<saki::M37, 4> &ms);
QVariantMap createFormVar(const char *spell, const char *charge);

QVariantMap createTableSnapMap(const saki::TableSnap &snap);

QJsonObject createReplayJson(const saki::Replay &replay);
QJsonObject createRuleJson(const saki::Rule &rule);

saki::Replay readReplayJson(const QJsonObject &obj);
saki::Rule readRuleJson(const QJsonObject &obj);
saki::Replay::Round readRoundJson(const QJsonObject &obj);
saki::Replay::Track readTrackJson(const QJsonObject &obj);

saki::Action readAction(const QString &actStr, int actArg, const QString &actTile);



#endif // P_PORT_H
