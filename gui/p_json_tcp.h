#ifndef P_JSON_TCP_H
#define P_JSON_TCP_H

#include <QObject>
#include <QTcpSocket>
#include <QTextStream>
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
    void recvJson(const QJsonObject &msg);

private slots:
    void onError(QAbstractSocket::SocketError socketError);
    void onConnected();
    void onReadReady();

private:
    QTcpSocket mSocket;
    QTextStream mNetIo;
    QString mHalfMsg;
    std::function<void()> mOnConn;
};

#endif // P_JSON_TCP_H
