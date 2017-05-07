#include "p_json_tcp.h"

#include "libsaki/util.h"

#include <QJsonDocument>
#include <QNetworkReply>
#include <QHostAddress>

#include <cassert>



#ifdef NDEBUG
const char *SRV_ADDR = "118.89.219.207";
#else
const char *SRV_ADDR = "127.0.0.1";
#endif
const quint16 SRV_PORT = 6171;



PJsonTcpSocket::PJsonTcpSocket(QObject *parent)
    : QObject(parent)
{
    using ErrorSignal = void (QAbstractSocket::*)(QAbstractSocket::SocketError);
    connect(&mSocket, static_cast<ErrorSignal>(&QTcpSocket::error),
            this, &PJsonTcpSocket::onError);
    connect(&mSocket, &QTcpSocket::connected, this, &PJsonTcpSocket::onConnected);
    connect(&mSocket, &QTcpSocket::readyRead, this, &PJsonTcpSocket::onReadReady);
}

void PJsonTcpSocket::conn(std::function<void()> callback)
{
    mOnConn = callback;
    mSocket.connectToHost(SRV_ADDR, SRV_PORT);
}

void PJsonTcpSocket::send(const QJsonObject &msg)
{
    QByteArray data = QJsonDocument(msg).toJson(QJsonDocument::Compact);
    quint32 size = data.size();
    mSocket.putChar((size >> 24) & 0xff);
    mSocket.putChar((size >> 16) & 0xff);
    mSocket.putChar((size >> 8) & 0xff);
    mSocket.putChar(size & 0xff);
    mSocket.write(data);
    saki::util::p("srv <---", data.toStdString());
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
    char c;
    while (mSocket.getChar(&c)) {
        if (mSizeByte < 4) {
            mSize = (mSize << 8) | (0xff & c);
            mSizeByte++;
        } else {
            assert(mSize > 0);

            mSize--;
            mPayload.append(c);

            if (mSize == 0) {
                mSizeByte = 0;
                saki::util::p("srv --->", mPayload.toStdString());
                QJsonObject msg = QJsonDocument::fromJson(mPayload.toUtf8()).object();
                emit recvJson(msg);
                mPayload.clear();
            }
        }
    }
}


