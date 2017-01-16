#ifndef P_CLIENT_H
#define P_CLIENT_H

#include <QObject>
#include <QTcpSocket>
#include <QTextStream>

#include <functional>



class PClient : public QObject
{
    Q_OBJECT
public:
    explicit PClient(QObject *parent = nullptr);

    Q_PROPERTY(QString nickname READ nickname NOTIFY nicknameChanged)

    Q_INVOKABLE void fetchAnn();
    Q_INVOKABLE void login(const QString &username, const QString &password);
    Q_INVOKABLE void book();

    QString nickname() const;

    void sendReady();

signals:
    void entryIn(const QString &ann, bool login);
    void authFailIn(const QString &reason);
    void authOkIn();
    void startIn(int tempDealer);

    void nicknameChanged();

    void activated(const QVariant &action, int lastDiscarder);

private slots:
    void onConnected();
    void showError(QAbstractSocket::SocketError socketError);
    void readMsg();

private:
    void conn();
    void send(const QJsonObject &obj);

private:
    QTcpSocket mSocket;
    QTextStream mNetIo;
    std::function<void()> mOnConn;

    bool mLoggedIn = false;
    QString mNickname;
};

#endif // P_CLIENT_H
