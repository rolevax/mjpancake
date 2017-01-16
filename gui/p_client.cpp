#include "p_client.h"

#include "libsaki/util.h"

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
    QString line = mNetIo.readAll();

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
    } else if (type == "t-activated") {
        QJsonObject action = reply["Action"].toObject();
        int lastDiscarder = reply["LastDiscarder"].toInt();
        emit activated(action.toVariantMap(), lastDiscarder);
    }
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


