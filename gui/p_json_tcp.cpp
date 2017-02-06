#include "p_json_tcp.h"

#include "libsaki/util.h"

#include <QJsonDocument>
#include <QNetworkReply>
#include <QHostAddress>



const char *ADDR_HOSTER = "http://git.oschina.net/rolevax/sl-addr"
                          "/raw/master/sl-addr?dir=0&filepath=sl-addr"
                          "&oid=4582122773b1ec4fc3927d14e99f7066ee7b78b2"
                          "&sha=7c4178c0c295b767243c846e4e033a83c0266797";
#ifdef NDEBUG
const char *SRV_ADDR = "118.89.219.121";
#else
const char *SRV_ADDR = "127.0.0.1";
#endif
const quint16 SRV_PORT = 6171;



PJsonTcpSocket::PJsonTcpSocket(QObject *parent)
    : QObject(parent)
{
    connect(&mHttp, &QNetworkAccessManager::finished, this, &PJsonTcpSocket::onAddrReplied);

    using ErrorSignal = void (QAbstractSocket::*)(QAbstractSocket::SocketError);
    connect(&mSocket, static_cast<ErrorSignal>(&QTcpSocket::error),
            this, &PJsonTcpSocket::onError);
    connect(&mSocket, &QTcpSocket::connected, this, &PJsonTcpSocket::onConnected);
    connect(&mSocket, &QTcpSocket::readyRead, this, &PJsonTcpSocket::onReadReady);

    mNetIo.setDevice(&mSocket);
}

void PJsonTcpSocket::conn(std::function<void()> callback)
{
    mOnConn = callback;

    QNetworkRequest request;
    request.setUrl(QUrl(ADDR_HOSTER));
    request.setRawHeader("User-Agent", "Wget/1.18 (linux-gnu)");

    mHttp.get(request);
}

void PJsonTcpSocket::send(const QJsonObject &msg)
{
    QString str = QString(QJsonDocument(msg).toJson(QJsonDocument::Compact));
    mNetIo << str << '\n';
    saki::util::p("srv <---", str.toStdString());
    mNetIo.flush();
}

void PJsonTcpSocket::onError(QAbstractSocket::SocketError socketError)
{
    switch (socketError) {
    case QAbstractSocket::RemoteHostClosedError:
        saki::util::p("srv ----");
        emit remoteClosed();
        break;
    case QAbstractSocket::HostNotFoundError:
        saki::util::p("E PJsonTcp: host not found");
        emit connError();
        break;
    case QAbstractSocket::ConnectionRefusedError:
        saki::util::p("E PJsonTcp: connection refused");
        emit connError();
        break;
    default:
        saki::util::p("E PJsonTcp: unknown conncetion error");
        emit connError();
        break;
    }
}

void PJsonTcpSocket::onConnected()
{
    mOnConn();
}

void PJsonTcpSocket::onReadReady()
{
    // tcp message framing: split concatted msg
    QString all = mHalfMsg + mNetIo.readAll();
    QStringList lines = all.split('\n');

    // tcp message framing: concat splitted msg
    mHalfMsg = lines.back(); // either "" or a real half-msg
    lines.pop_back();

    for (const QString &line : lines) {
        saki::util::p("srv --->", line.toStdString());
        QJsonObject msg = QJsonDocument::fromJson(line.toUtf8()).object();
        emit recvJson(msg);
    }
}

void PJsonTcpSocket::onAddrReplied(QNetworkReply *reply)
{
    mSocket.abort();

#ifdef NDEBUG
    QString strAddr(reply->readAll().trimmed());
    QHostAddress addr;
    if (addr.setAddress(strAddr)) {
        saki::util::p("srv ++++", strAddr.toStdString());
        mSocket.connectToHost(addr, SRV_PORT);
    } else {
        saki::util::p("srv ++++", SRV_ADDR, "(fetch)", strAddr.toStdString());
        mSocket.connectToHost(SRV_ADDR, SRV_PORT);
    }
#else
    mSocket.connectToHost(SRV_ADDR, SRV_PORT);
#endif

    reply->deleteLater();
}


