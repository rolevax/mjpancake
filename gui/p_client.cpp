#include "p_client.h"
#include "p_global.h"

#include "libsaki/util.h"

#include <QStringList>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QCryptographicHash>
#include <QDebug>

#include <array>
#include <cassert>



PClient *PClient::sInstance = nullptr;

PClient::PClient(QObject *parent) : QObject(parent)
{
    QVariantMap bookEntry;
    bookEntry["Bookable"] = false;
    bookEntry["Play"] = 0;
    bookEntry["Book"] = 0;
    for (int i = 0; i < 4; i++) {
        mBooks.append(bookEntry);
        mBookings.append(false);
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

void PClient::login(const QString &username, const QString &password)
{
    PGlobal::forceImmersive();
    mSocket.conn([=]() {
        QJsonObject req;
        req["Type"] = "login";
        req["Version"] = PGlobal::version();
        req["Username"] = username;
        req["Password"] = hash(password);
        mSocket.send(req);
    });
}

void PClient::signUp(const QString &username, const QString &password)
{
    PGlobal::forceImmersive();
    mSocket.conn([=]() {
        QJsonObject req;
        req["Type"] = "sign-up";
        req["Version"] = PGlobal::version();
        req["Username"] = username;
        req["Password"] = hash(password);
        mSocket.send(req);
    });
}

void PClient::lookAround()
{
    QJsonObject req;
    req["Type"] = "look-around";
    mSocket.send(req);
}

void PClient::book(int bookType)
{
    mBookings[bookType] = true;
    emit bookingsChanged();

    QJsonObject req;
    req["Type"] = "book";
    req["BookType"] = bookType;
    mSocket.send(req);
}

void PClient::unbook()
{
    for (auto &v : mBookings)
        v = false;
    emit bookingsChanged();

    QJsonObject req;
    req["Type"] = "unbook";
    mSocket.send(req);
}

void PClient::sendReady()
{
    QJsonObject req;
    req["Type"] = "ready";
    mSocket.send(req);
}

void PClient::sendChoose(int girlIndex)
{
    QJsonObject req;
    req["Type"] = "choose";
    req["GirlIndex"] = girlIndex;
    mSocket.send(req);
}

void PClient::sendResume()
{
    QJsonObject req;
    req["Type"] = "t-action";
    req["ActStr"] = "RESUME";
    req["ActArg"] = "-1";
    req["Nonce"] = 0;
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

QVariantList PClient::books() const
{
    return mBooks;
}

QVariantList PClient::bookings() const
{
    return mBookings;
}

bool PClient::hasBooking() const
{
    for (auto v : mBookings)
        if (v.toBool())
            return true;
    return false;
}

int PClient::lastNonce() const
{
    return mLastNonce;
}

void PClient::action(QString actStr, const QVariant &actArg)
{
    QJsonObject req;
    req["Type"] = "t-action";
    req["Nonce"] = mLastNonce;
    req["ActStr"] = actStr;
    req["ActArg"] = actArg.toString();
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
        assert(false && "PClient: unknown table event type");

    return type;
}

void PClient::onRemoteClosed()
{
    mUser.clear();
    emit userChanged();
}

void PClient::onJsonReceived(const QJsonObject &msg)
{
    QString type = msg["Type"].toString();
    if (type == "auth") {
        bool ok = msg["Ok"].toBool(false);
        if (ok) {
            mUser = msg["User"].toObject().toVariantMap();
            emit userChanged();
        } else {
            mUser.clear();
            emit userChanged();
            emit authFailIn(msg["Reason"].toString());
        }
    } else if (type == "look-around") {
        mConnCt = msg["Conn"].toInt();
        mBooks = msg["Books"].toArray().toVariantList();
        emit lookedAround();
    } else if (type == "start") {
        // wait for Qt 5.9 release,
        // and notify from background by Android service + Qt Remote Object
        //PGlobal::systemNotify();
        mLastNonce = 0;
        emit lastNonceChanged();
        QJsonArray users = msg["Users"].toArray();
        QJsonArray choices = msg["Choices"].toArray();
        int tempDealer = msg["TempDealer"].toInt();
        emit startIn(users.toVariantList(), choices.toVariantList(), tempDealer);
    } else if (type == "chosen") {
        QJsonArray girlIds = msg["GirlIds"].toArray();
        emit chosenIn(girlIds.toVariantList());
    } else if (type == "resume") {
        mLastNonce = 0;
        emit lastNonceChanged();
        emit resumeIn();
    } else if (type == "table") {
        recvTableEvent(msg);
    } else if (type == "update-user") {
        mUser = msg["User"].toObject().toVariantMap();
        emit userChanged();
        updateStats(msg["Stats"].toArray().toVariantList());
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

QString PClient::hash(const QString &password) const
{
    QCryptographicHash hasher(QCryptographicHash::Sha256);
    hasher.addData(password.toUtf8());
    return QString::fromUtf8(hasher.result().toBase64());
}

void PClient::updateStats(const QVariantList &stats)
{
    const std::array<const char*, 42> yakuKeys {
        "Rci", "Ipt", "Tmo", "Tny", "Pnf",
        "Y1y", "Y2y", "Y3y",
        "Jk1", "Jk2", "Jk3", "Jk4", "Bk1", "Bk2", "Bk3", "Bk4",
        "Ipk", "Rns", "Hai", "Hou", "Ckn", "Ss1", "It1", "Ct1",
        "Wri", "Ss2", "It2", "Ct2",
        "Toi", "Ctt", "Sak", "Skt",
        "Stk", "Hrt", "S3g", "H1t", "Jc2",
        "Mnh", "Jc3", "Rpk", "C1t", "Mnc"
    };
    const std::array<const char*, 42> yakuHans {
        "RciHan", "IptHan", "TmoHan", "TnyHan", "PnfHan",
        "Y1yHan", "Y2yHan", "Y3yHan",
        "Jk1Han", "Jk2Han", "Jk3Han", "Jk4Han", "Bk1Han", "Bk2Han", "Bk3Han", "Bk4Han",
        "IpkHan", "RnsHan", "HaiHan", "HouHan", "CknHan", "Ss1Han", "It1Han", "Ct1Han",
        "WriHan", "Ss2Han", "It2Han", "Ct2Han",
        "ToiHan", "CttHan", "SakHan", "SktHan",
        "StkHan", "HrtHan", "S3gHan", "H1tHan", "Jc2Han",
        "MnhHan", "Jc3Han", "RpkHan", "C1tHan", "MncHan"
    };
    const std::array<const char*, 16> yakumanKeys {
        "X13", "Xd3", "X4a", "Xt1", "Xs4", "Xd4",
        "Xcr", "Xr1", "Xth", "Xch", "X4k", "X9r",
        "W13", "W4a", "W9r", "Kzeykm"
    };

    QVariantMap summary;

    summary["GirlId"] = -2;
    summary["Round"] = 0; // prevent undefined

    QVariantList sumRanks { 0, 0, 0, 0 };
    int sumPlay = 0;
    double avgPoint = 0;
    int sumWin = 0;
    double avgWinPoint = 0;
    double avgWinTurn = 0;

    for (const auto &statRow : stats) {
        const auto &rowMap = statRow.toMap();
        const auto &ranks = rowMap["Ranks"].toList();
        int currPlay = 0;
        for (int i = 0; i < 4; i++) {
            sumRanks[i] = sumRanks[i].toInt() + ranks.at(i).toInt();
            currPlay += ranks.at(i).toInt();
        }

        auto add = [&](const char *key) {
            int curr = rowMap[key].toInt();
            summary[key] = summary[key].toInt(0) + curr;
        };

        auto addAndAvg = [&](const char *sumKey, const char *avgKey) {
            int currCt = rowMap[sumKey].toInt();
            int oldCt = summary[sumKey].toInt(0);
            double oldVal = summary[avgKey].toDouble(0);
            if (currCt > 0) {
                double currVal = rowMap[avgKey].toDouble();
                summary[avgKey] = (oldVal * oldCt + currVal * currCt) / (oldCt + currCt);
                summary[sumKey] = oldCt + currCt;
            } else {
                // make sure not undefined
                summary[avgKey] = oldVal;
                summary[sumKey] = oldCt;
            }
        };

        int currWin = rowMap["Win"].toInt();
        // weighted average among all girls
        avgPoint = (avgPoint * sumPlay + rowMap["AvgPoint"].toDouble() * currPlay)
                / (sumPlay + currPlay);
        if (currWin > 0) {
            avgWinPoint = (avgWinPoint * sumWin + rowMap["WinPoint"].toDouble() * currWin)
                    / (sumWin + currWin);
            avgWinTurn = (avgWinTurn * sumWin + rowMap["WinTurn"].toDouble() * currWin)
                    / (sumWin + currWin);
        }

        add("Round");
        add("ATop");
        add("ALast");
        addAndAvg("Gun", "GunPoint");
        addAndAvg("Bark", "BarkPoint");
        addAndAvg("Riichi", "RiichiPoint");
        addAndAvg("Ready", "ReadyTurn");

        for (size_t i = 0; i < yakuKeys.size(); i++)
            addAndAvg(yakuKeys[i], yakuHans[i]);

        for (const char *key : yakumanKeys)
            add(key);
        for (const char *key : { "Dora", "Uradora", "Akadora", "Kandora", "Kanuradora" })
            add(key);

        sumPlay += currPlay;
        sumWin += currWin;
    }

    summary["Ranks"] = sumRanks;
    summary["AvgPoint"] = avgPoint;
    summary["Win"] = sumWin;
    summary["WinPoint"] = avgWinPoint;
    summary["WinTurn"] = avgWinTurn;

    mStats = stats;
    mStats.insert(0, summary);

    emit statsChanged();
}

QObject *pClientSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    PClient *pClient = new PClient();
    return pClient;
}


