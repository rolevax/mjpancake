#include "p_client.h"
#include "p_global.h"

#include "libsaki/util/misc.h"

#include <QDateTime>
#include <QStringList>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QDebug>

#include <array>
#include <cassert>



PClient *PClient::sInstance = nullptr;

PClient::PClient(QObject *parent) : QObject(parent)
{
    for (int i = 0; i < 8; i++) {
        mMatchWaits.append(0);
        mMatchings.append(false);
    }

    connect(&mSocket, &PJsonTcpSocket::recvJson, this, &PClient::onJsonReceived);
    connect(&mSocket, &PJsonTcpSocket::remoteClosed, this, &PClient::remoteClosed);
    connect(&mSocket, &PJsonTcpSocket::connError, this, &PClient::connError);
    connect(&mSocket, &PJsonTcpSocket::remoteClosed, this, &PClient::onRemoteClosed);

    connect(&mHeartbeatTimer, &QTimer::timeout, this, &PClient::heartbeat);
    mHeartbeatTimer.setInterval(5 * 60 * 1000); // 5 min
    mHeartbeatTimer.start();

    sInstance = this;
}

PClient &PClient::instance()
{
    return *sInstance;
}

bool PClient::duringMatchTime()
{
    QDateTime dt = QDateTime::currentDateTimeUtc();
    int dayOfWeek = dt.date().dayOfWeek();
    QTime time = dt.time();
    QTime begin(11, 30);
    QTime end(13, 30);

    // Monday 19:30 ~ 21:30 CST
    return dayOfWeek == 1 && begin <= time && time < end;
}

void PClient::login(const QString &username, const QString &password)
{
    PGlobal::forceImmersive();
    mSocket.conn([=]() {
        QJsonObject req;
        req["Type"] = "auth";
        req["Version"] = PGlobal::version();
        req["Username"] = username;
        req["Password"] = password;
        mSocket.send(req);
    });
}

void PClient::logout()
{
    // pretend closed, still connecting
    onRemoteClosed();
}

void PClient::lookAround()
{
    QJsonObject req;
    req["Type"] = "look-around";
    mSocket.send(req);
}

void PClient::sendMatchJoin(int ruleId)
{
    mMatchings[ruleId] = true;
    emit matchingsChanged();

    QJsonObject req;
    req["Type"] = "match-join";
    req["RuleId"] = ruleId;
    mSocket.send(req);
}

void PClient::sendMatchCancel()
{
    clearMatchings();

    QJsonObject req;
    req["Type"] = "match-cancel";
    mSocket.send(req);
}

void PClient::sendRoomCreate(int girlId, const QVariantList &aiGids)
{
    QJsonObject req;
    req["Type"] = "room-create";
    req["AiNum"] = 2;
    req["GirlId"] = girlId;
    req["AiGids"] = QJsonArray::fromVariantList(aiGids);
    mSocket.send(req);
}

void PClient::sendCliamFood()
{
    QJsonObject req;
    req["Type"] = "claim-food";
    mSocket.send(req);
}

void PClient::sendTableSeat()
{
    QJsonObject req;
    req["Type"] = "table-seat";
    mSocket.send(req);
}

void PClient::sendTableChoose(int girlIndex)
{
    QJsonObject req;
    req["Type"] = "table-choose";
    req["Gidx"] = girlIndex;
    mSocket.send(req);
}

void PClient::sendResume()
{
    QJsonObject req;
    req["Type"] = "action";
    req["ActStr"] = "RESUME";
    req["ActArg"] = "-1";
    req["Nonce"] = 0;
    mSocket.send(req);
}

void PClient::getReplayList()
{
    QJsonObject req;
    req["Type"] = "get-replay-list";
    mSocket.send(req);
}

void PClient::getReplay(int replayId)
{
    QJsonObject req;
    req["Type"] = "get-replay";
    req["ReplayId"] = replayId;
    mSocket.send(req);
}

QVariantMap PClient::user() const
{
    return mUser;
}

QVariantList PClient::stats() const
{
    return mStats;
}

QVariantList PClient::playedGirlIds() const
{
    QVariantList res;

    for (const auto &statRow : mStats)
        res.append(statRow.toMap()["GirlId"]);

    return res;
}

bool PClient::loggedIn() const
{
    return mUser.contains("Username") && mUser["Username"].toString() != "";
}

int PClient::playCt() const
{
    int sum = 0;

    const auto &ranks = mStats[0].toMap()["Ranks"].toList();
    for (int i = 0; i < 4; i++)
        sum += ranks.at(i).toInt();

    return sum;
}

QVariantList PClient::ranks() const
{
    return mStats[0].toMap()["Ranks"].toList();
}

int PClient::connCt() const
{
    return mConnCt;
}

QVariantList PClient::matchWaits() const
{
    return mMatchWaits;
}

QVariantList PClient::matchings() const
{
    return mMatchings;
}

bool PClient::hasMatching() const
{
    for (auto v : mMatchings)
        if (v.toBool())
            return true;

    return false;
}

int PClient::lastNonce() const
{
    return mLastNonce;
}

QVariantList PClient::water() const
{
    return mWater;
}

void PClient::action(const QString &actStr, int actArg, const QString &actTile)
{
    QJsonObject req;
    req["Type"] = "table-action";
    req["Nonce"] = mLastNonce;
    req["ActStr"] = actStr;
    if (actArg != -1)
        req["ActArg"] = actArg;

    if (actTile.size() > 0)
        req["ActTile"] = actTile;

    mSocket.send(req);
}

PTable::Event PClient::eventOf(const QString &event)
{
    PTable::Event type;

    if (event == "first-dealer-choosen")
        type = PTable::FirstDealerChoosen;
    else if (event == "round-started")
        type = PTable::RoundStarted;
    else if (event == "cleaned")
        type = PTable::Cleaned;
    else if (event == "diced")
        type = PTable::Diced;
    else if (event == "dealt")
        type = PTable::Dealt;
    else if (event == "flipped")
        type = PTable::Flipped;
    else if (event == "drawn")
        type = PTable::Drawn;
    else if (event == "discarded")
        type = PTable::Discarded;
    else if (event == "riichi-called")
        type = PTable::RiichiCalled;
    else if (event == "riichi-established")
        type = PTable::RiichiEstablished;
    else if (event == "barked")
        type = PTable::Barked;
    else if (event == "round-ended")
        type = PTable::RoundEnded;
    else if (event == "points-changed")
        type = PTable::PointsChanged;
    else if (event == "table-ended")
        type = PTable::TableEnded;
    else if (event == "popped-up")
        type = PTable::PoppedUp;
    else if (event == "activated")
        type = PTable::Activated;
    else if (event == "deactivated")
        type = PTable::Deactivated;
    else if (event == "resume")
        type = PTable::Resume;
    else
        Q_UNREACHABLE();

    return type;
}

void PClient::onRemoteClosed()
{
    for (auto &v : mMatchings)
        v = false;

    emit matchingsChanged();

    mUser.clear();
    emit userChanged();
}

void PClient::onJsonReceived(const QJsonObject &msg)
{
    QString type = msg["Type"].toString();
    if (type == "auth") {
        QString error = msg["Error"].toString();
        if (error.isEmpty()) {
            mUser = msg["User"].toObject().toVariantMap();
            emit userChanged();
            updateStats(msg["Stats"].toArray().toVariantList());
        } else {
            mUser.clear();
            emit userChanged();
            emit authFailIn(error);
        }
    } else if (type == "look-around") {
        mConnCt = msg["Conn"].toInt();
        mMatchWaits = msg["MatchWaits"].toArray().toVariantList();
        mWater = msg["Water"].toArray().toVariantList();
        emit lookedAround();
    } else if (type == "table-init") {
        // TODO notify from background by Android service + Qt Remote Object
        // PGlobal::systemNotify();

        mLastNonce = 0;
        emit lastNonceChanged();

        QJsonObject match = msg["MatchResult"].toObject();
        QJsonArray choices = msg["Choices"].toArray();
        QJsonArray foodCosts = msg["FoodCosts"].toArray();
        emit tableInitRecved(match.toVariantMap(), choices.toVariantList(), foodCosts.toVariantList());
        clearMatchings();
    } else if (type == "table-seat") {
        QJsonArray girlIds = msg["Gids"].toArray();
        int tempDealer = msg["TempDealer"].toInt();
        emit tableSeatRecved(girlIds.toVariantList(), tempDealer);
    } else if (type == "resume") {
        mLastNonce = 0;
        emit lastNonceChanged();
        emit resumeIn();
    } else if (type == "table-event") {
        recvTableEvent(msg);
    } else if (type == "table-end") {
        bool abortive = msg["Abortive"].toBool();
        QJsonArray foodChanges = msg["FoodChanges"].toArray();
        emit tableEndRecved(abortive, foodChanges.toVariantList());
    } else if (type == "update-user") {
        mUser = msg["User"].toObject().toVariantMap();
        emit userChanged();
        updateStats(msg["Stats"].toArray().toVariantList());
    } else if (type == "get-replay-list") {
        QVariantList ids = msg["ReplayIds"].toArray().toVariantList();
        emit replayListIn(ids);
    } else if (type == "get-replay") {
        QString json = msg["ReplayJson"].toString();
        int id = msg["ReplayId"].toInt();
        emit replayIn(id, json);
    }
}

void PClient::recvTableEvent(const QJsonObject &msg)
{
    int nonce = msg["Nonce"].toInt();
    if (nonce > mLastNonce) {
        mLastNonce = nonce;
        emit lastNonceChanged();
        emit tableEvent(PTable::Deactivated, QVariantMap());
    }

    PTable::Event event = eventOf(msg["Event"].toString());
    QVariantMap args = msg["Args"].toObject().toVariantMap();
    if (event == PTable::Activated)
        args["nonce"] = nonce;

    emit tableEvent(event, args);
}

void PClient::heartbeat()
{
    if (loggedIn()) {
        QJsonObject req;
        req["Type"] = "heartbeat";
        mSocket.send(req);
    }
}

void PClient::clearMatchings()
{
    for (auto &v : mMatchings)
        v = false;

    emit matchingsChanged();
}

void PClient::updateStats(const QVariantList &stats)
{
    mStats = stats;
    emit statsChanged();
}

QObject *pClientSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return new PClient();
}
