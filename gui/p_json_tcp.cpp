#include "p_json_tcp.h"

#include "libsaki/util.h"

#include <QJsonDocument>

PJsonTcpSocket::PJsonTcpSocket(QObject *parent)
    : QObject(parent)
{
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
    mSocket.abort();
    mSocket.connectToHost("127.0.0.1", 6171);
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
        break;
    case QAbstractSocket::ConnectionRefusedError:
        saki::util::p("E PJsonTcp: connection refused");
        break;
    default:
        saki::util::p("E PJsonTcp: unknown conncetion error");
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
