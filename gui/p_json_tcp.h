#ifndef P_JSON_TCP_H
#define P_JSON_TCP_H

#include <QObject>
#include <QTcpSocket>
#include <QJsonObject>

#include <functional>

class PJsonTcpSocket : public QObject
{
    Q_OBJECT

public:
    explicit PJsonTcpSocket(QObject *parent = nullptr);

    void conn(std::function<void()> callback);
    void send(const QJsonObject &msg);

signals:
    void remoteClosed();
    void connError();
    void recvJson(const QJsonObject &msg);

private slots:
    void onError(QAbstractSocket::SocketError socketError);
    void onConnected();
    void onReadReady();

private:
    QTcpSocket mSocket;
    int mSizeByte = 0;
    int mSize = 0;
    QByteArray mPayload;
    std::function<void()> mOnConn;
};

#endif // P_JSON_TCP_H
