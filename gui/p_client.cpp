#include "p_client.h"

#include "libsaki/util.h"

#include <QStringList>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QAbstractSocket>
#include <QDebug>

PClient::PClient(QObject *parent) : QObject(parent)
{
    using ErrorSignal = void (QAbstractSocket::*)(QAbstractSocket::SocketError);
    connect(&mSocket, static_cast<ErrorSignal>(&QTcpSocket::error),
            this, &PClient::showError);
    connect(&mSocket, &QTcpSocket::connected, this, &PClient::onConnected);
    connect(&mSocket, &QTcpSocket::readyRead, this, &PClient::readMsg);

    mNetIo.setDevice(&mSocket);
}

void PClient::fetchAnn()
{
    mOnConn = [this]() {
        QJsonObject req;
        req["Type"] = "fetch-ann";
        send(req);
    };

    conn();
}

void PClient::login(const QString &username, const QString &password)
{
    mOnConn = [&]() {
        QJsonObject req;
        req["Type"] = "login";
        req["Username"] = username;
        req["Password"] = password;
        send(req);
    };

    conn();
}

void PClient::book()
{
    QJsonObject req;
    req["Type"] = "book";
    send(req);
}

QString PClient::nickname() const
{
    return mNickname;
}

void PClient::sendReady()
{
    QJsonObject req;
    req["Type"] = "ready";
    send(req);
}

void PClient::action(QString actStr, const QVariant &actArg)
{
    QJsonObject req;
    req["Type"] = "t-action";
    req["ActStr"] = actStr;
    req["ActArg"] = actArg.toString();
    send(req);
}

void PClient::onConnected()
{
    mOnConn();
}

void PClient::showError(QAbstractSocket::SocketError socketError)
{
    switch (socketError) {
    case QAbstractSocket::RemoteHostClosedError:
        if (mLoggedIn) {
            emit entryIn("", false);
            fetchAnn();
        }
        break;
    case QAbstractSocket::HostNotFoundError:
        saki::util::p("E host not found");
        break;
    case QAbstractSocket::ConnectionRefusedError:
        saki::util::p("E connection refused");
        break;
    default:
        saki::util::p("E unknown conncetion error");
        break;
    }
}

void PClient::readMsg()
{
    QStringList lines = mNetIo.readAll().split("\n", QString::SplitBehavior::SkipEmptyParts);

    for (const QString &line : lines)
        recvLine(line);
}

void PClient::conn()
{
    mSocket.abort();
    mSocket.connectToHost("127.0.0.1", 6171);
}

void PClient::send(const QJsonObject &obj)
{
    QString str = QString(QJsonDocument(obj).toJson(QJsonDocument::Compact));
    mNetIo << str << '\n';
    saki::util::p("<---", str.toStdString());
    mNetIo.flush();
}

void PClient::recvLine(const QString &line)
{
    saki::util::p("--->", line.toStdString());
    QJsonObject reply = QJsonDocument::fromJson(line.toUtf8()).object();
    QString type = reply["Type"].toString();
    if (type == "fetch-ann") {
        emit entryIn(reply["Ann"].toString(), reply["Login"].toBool(false));
    } else if (type == "auth") {
        bool ok = reply["Ok"].toBool(false);
        if (ok) {
            mLoggedIn = true;
            mNickname = reply["User"].toObject()["Nickname"].toString();
            emit nicknameChanged();
            emit authOkIn();
        } else {
            emit authFailIn(reply["Reason"].toString());
        }
    } else if (type == "start") {
        QJsonArray users = reply["Users"].toArray();
        QJsonArray girlIds = reply["GirlIds"].toArray();
        int tempDealer = reply["TempDealer"].toInt();
        emit startIn(tempDealer);
    } else if (type.startsWith("t-")) {
        recvTableEvent(type, reply);
    }
}

void PClient::recvTableEvent(const QString &type, const QJsonObject &msg)
{
    if (type == "t-activated") {
        QJsonObject action = msg["Action"].toObject();
        int lastDiscarder = msg["LastDiscarder"].toInt();
        emit activated(action.toVariantMap(), lastDiscarder);
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
    } else if (type == "t-points-changed") {
        QJsonArray points = msg["Points"].toArray();
        emit pointsChanged(points.toVariantList());
    } else {
        saki::util::p("WTF unkown recv type", type.toStdString());
    }
}


