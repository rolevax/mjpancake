#include "p_client.h"
#include "p_global.h"

#include "libsaki/util.h"

#include <QStringList>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QCryptographicHash>
#include <QDebug>

PClient::PClient(QObject *parent) : QObject(parent)
{
    QVariantMap bookEntry;
    bookEntry["Bookable"] = false;
    bookEntry["Play"] = 0;
    bookEntry["Book"] = 0;

    mBooks["DS71"] = bookEntry;
    mBooks["CS71"] = bookEntry;
    mBooks["BS71"] = bookEntry;
    mBooks["AS71"] = bookEntry;

    connect(&mSocket, &PJsonTcpSocket::recvJson, this, &PClient::onJsonReceived);
    connect(&mSocket, &PJsonTcpSocket::remoteClosed, this, &PClient::remoteClosed);
    connect(&mSocket, &PJsonTcpSocket::connError, this, &PClient::connError);
    connect(&mSocket, &PJsonTcpSocket::remoteClosed, this, &PClient::onRemoteClosed);
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

void PClient::book(const QString &bookType)
{
    QJsonObject req;
    req["Type"] = "book";
    req["BookType"] = bookType;
    mSocket.send(req);
}

void PClient::unbook()
{
    QJsonObject req;
    req["Type"] = "unbook";
    mSocket.send(req);
}

QVariantMap PClient::user() const
{
    return mUser;
}

bool PClient::loggedIn() const
{
    return mUser.contains("Username") && mUser["Username"].toString() != "";
}

int PClient::playCt() const
{
    if (mUser.contains("Ranks")) {
        const auto &ranks = mUser["Ranks"].toList();
        int sum = 0;
        for (int i = 0; i < 4; i++)
            sum += ranks.at(i).toInt();
        return sum;
    } else {
        return 0;
    }
}

int PClient::connCt() const
{
    return mConnCt;
}

QVariantMap PClient::books() const
{
    return mBooks;
}

int PClient::lastNonce() const
{
    return mLastNonce;
}

void PClient::sendReady()
{
    QJsonObject req;
    req["Type"] = "ready";
    mSocket.send(req);
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
        mBooks = msg["Books"].toObject().toVariantMap();
        emit lookedAround();
    } else if (type == "start") {
        mLastNonce = 0;
        emit lastNonceChanged();
        QJsonArray users = msg["Users"].toArray();
        QJsonArray girlIds = msg["GirlIds"].toArray();
        int tempDealer = msg["TempDealer"].toInt();
        emit startIn(users.toVariantList(), girlIds.toVariantList(), tempDealer);
    } else if (type.startsWith("t-")) {
        recvTableEvent(type, msg);
    } else if (type == "update-user") {
        mUser = msg["User"].toObject().toVariantMap();
        emit userChanged();
    }
}

void PClient::recvTableEvent(const QString &type, const QJsonObject &msg)
{
    int nonce = msg["Nonce"].toInt();
    if (nonce > mLastNonce) {
        mLastNonce = nonce;
        emit lastNonceChanged();
        emit deactivated();
    }

    if (type == "t-activated") {
        QJsonObject action = msg["Action"].toObject();
        int lastDiscarder = msg["LastDiscarder"].toInt();
        bool green = msg["Green"].toBool(false);
        emit activated(action.toVariantMap(), lastDiscarder, green, nonce);
    } else if (type == "t-first-dealer-choosen") {
        int initDealer = msg["InitDealer"].toInt();
        emit firstDealerChoosen(initDealer);
    } else if (type == "t-round-started") {
        int round = msg["Round"].toInt();
        int extra = msg["ExtraRound"].toInt();
        int dealer = msg["Dealer"].toInt();
        bool allLast = msg["AllLast"].toBool();
        int deposit = msg["Deposit"].toInt();
        emit roundStarted(round, extra, dealer, allLast, deposit);
    } else if (type == "t-cleaned") {
        emit cleaned();
    } else if (type == "t-diced") {
        int die1 = msg["Die1"].toInt();
        int die2 = msg["Die2"].toInt();
        emit diced(die1, die2);
    } else if (type == "t-dealt") {
        QJsonArray init = msg["Init"].toArray();
        emit dealt(init.toVariantList());
    } else if (type == "t-flipped") {
        QJsonObject tile = msg["NewIndic"].toObject();
        emit flipped(tile.toVariantMap());
    } else if (type == "t-drawn") {
        int w = msg["Who"].toInt();
        bool rinshan = msg["Rinshan"].toBool();
        QJsonObject tile;
        if (w == 0)
            tile = msg["Tile"].toObject();
        emit drawn(w, tile.toVariantMap(), rinshan);
    } else if (type == "t-discarded") {
        int w = msg["Who"].toInt();
        QJsonObject tile = msg["Tile"].toObject();
        bool spin = msg["Spin"].toBool();
        emit discarded(w, tile.toVariantMap(), spin);
    } else if (type == "t-riichi-called") {
        int w = msg["Who"].toInt();
        emit riichiCalled(w);
    } else if (type == "t-riichi-established") {
        int w = msg["Who"].toInt();
        emit riichiEstablished(w);
    } else if (type == "t-barked") {
        int w = msg["Who"].toInt();
        int from = msg["FromWhom"].toInt();
        QString actStr = msg["ActStr"].toString();
        QJsonObject bark = msg["Bark"].toObject();
        bool spin = msg["Spin"].toBool();
        emit barked(w, from, actStr, bark.toVariantMap(), spin);
    } else if (type == "t-round-ended") {
        QString result = msg["Result"].toString();
        QJsonArray openers = msg["Openers"].toArray();
        int gunner = msg["Gunner"].toInt();
        QJsonArray hands = msg["Hands"].toArray();
        QJsonArray forms = msg["Forms"].toArray();
        QJsonArray urids = msg["Urids"].toArray();
        emit roundEnded(result, openers, gunner, hands, forms, urids);
    } else if (type == "t-points-changed") {
        QJsonArray points = msg["Points"].toArray();
        emit pointsChanged(points.toVariantList());
    } else if (type == "t-table-ended") {
        QJsonArray rank = msg["Rank"].toArray();
        QJsonArray scores = msg["Scores"].toArray();
        emit tableEnded(rank, scores);
    } else if (type == "t-popped-up") {
        QString str = msg["Str"].toString();
        emit poppedUp(str);
    } else {
        saki::util::p("WTF unkown recv type", type.toStdString());
    }
}

QString PClient::hash(const QString &password) const
{
    QCryptographicHash hasher(QCryptographicHash::Sha256);
    hasher.addData(password.toUtf8());
    return QString::fromUtf8(hasher.result().toBase64());
}

QObject *pClientSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    PClient *pClient = new PClient();
    return pClient;
}


