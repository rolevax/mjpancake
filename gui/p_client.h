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
    void firstDealerChoosen(int dealer);
    void roundStarted(int round, int extra, int dealer, bool allLast, int deposit);
    void cleaned();
    void diced(int die1, int die2);
    void dealt(const QVariant &init);
    void flipped(const QVariant &newIndic);
    void drawn(int who, const QVariant &tile, bool rinshan);
    void discarded(int who, const QVariant &tile, bool spin);
    void riichied(int who);
    void riichiPassed(int who);
    void barked(int who, int fromWhom, QString actStr, const QVariant &bark, bool spin);
    void roundEnded(QString result, const QVariant &openers, int gunner,
                    const QVariant &forms, const QVariant &uraIndics, const QVariant &hands);
    void pointsChanged(const QVariant &points);
    void tableEnded(const QVariant &rank, const QVariant &scores);
    void poppedUp(int who, QString str);

public slots:
    void action(QString actStr, const QVariant &actArg);

private slots:
    void onConnected();
    void showError(QAbstractSocket::SocketError socketError);
    void readMsg();

private:
    void conn();
    void send(const QJsonObject &obj);
    void recvLine(const QString &line);
    void recvTableEvent(const QString &type, const QJsonObject &msg);

private:
    QTcpSocket mSocket;
    QTextStream mNetIo;
    std::function<void()> mOnConn;

    bool mLoggedIn = false;
    QString mNickname;
};

#endif // P_CLIENT_H
