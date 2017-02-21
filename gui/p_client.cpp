#include "p_client.h"
#include "p_global.h"

#include "libsaki/util.h"

#include <QStringList>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QCryptographicHash>
#include <QDebug>

#include <cassert>



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

void PClient::sendReady()
{
    QJsonObject req;
    req["Type"] = "ready";
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
        mBooks = msg["Books"].toObject().toVariantMap();
        emit lookedAround();
    } else if (type == "start") {
        mLastNonce = 0;
        emit lastNonceChanged();
        QJsonArray users = msg["Users"].toArray();
        QJsonArray girlIds = msg["GirlIds"].toArray();
        int tempDealer = msg["TempDealer"].toInt();
        emit startIn(users.toVariantList(), girlIds.toVariantList(), tempDealer);
    } else if (type == "resume") {
        mLastNonce = 0;
        emit lastNonceChanged();
        emit resumeIn();
    } else if (type == "table") {
        recvTableEvent(msg);
    } else if (type == "update-user") {
        mUser = msg["User"].toObject().toVariantMap();
        emit userChanged();
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


