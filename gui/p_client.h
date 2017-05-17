#ifndef P_CLIENT_H
#define P_CLIENT_H

#include "p_json_tcp.h"
#include "p_table.h"

#include <QObject>
#include <QQmlEngine>
#include <QJSEngine>
#include <QVariantMap>
#include <QTimer>


class PClient : public QObject
{
    Q_OBJECT
public:
    explicit PClient(QObject *parent = nullptr);

    Q_PROPERTY(bool loggedIn READ loggedIn NOTIFY userChanged)
    Q_PROPERTY(QVariantMap user READ user NOTIFY userChanged)
    Q_PROPERTY(QVariantList stats READ stats NOTIFY statsChanged)
    Q_PROPERTY(QVariantList playedGirlIds READ playedGirlIds NOTIFY statsChanged)
    Q_PROPERTY(int playCt READ playCt NOTIFY statsChanged)
    Q_PROPERTY(QVariantList ranks READ ranks NOTIFY statsChanged)
    Q_PROPERTY(int connCt READ connCt NOTIFY lookedAround)
    Q_PROPERTY(QVariantList books READ books NOTIFY lookedAround)
    Q_PROPERTY(QVariantList bookings READ bookings NOTIFY bookingsChanged)
    Q_PROPERTY(bool hasBooking READ hasBooking NOTIFY bookingsChanged)
    Q_PROPERTY(int lastNonce READ lastNonce NOTIFY lastNonceChanged)
    Q_PROPERTY(QVariantList water READ water NOTIFY lookedAround)

    static PClient &instance();

    Q_INVOKABLE void login(const QString &username, const QString &password);
    Q_INVOKABLE void signUp(const QString &username, const QString &password);
    Q_INVOKABLE void lookAround();
    Q_INVOKABLE void book(int bookType);
    Q_INVOKABLE void unbook();
    Q_INVOKABLE void sendReady();
    Q_INVOKABLE void sendChoose(int girlIndex);
    Q_INVOKABLE void sendResume();

    void getReplayList();
    void getReplay(int replayId);

    QVariantMap user() const;
    QVariantList stats() const;
    QVariantList playedGirlIds() const;
    bool loggedIn() const;
    int playCt() const;
    QVariantList ranks() const;
    int connCt() const;
    QVariantList books() const;
    QVariantList bookings() const;
    bool hasBooking() const;
    int lastNonce() const;
    QVariantList water() const;

signals:
    void remoteClosed();
    void connError();
    void authFailIn(const QString &reason);
    void startIn(const QVariantList &users, const QVariantList &choices, int tempDealer);
    void chosenIn(const QVariantList &girlIds);
    void resumeIn();
    void replayListIn(const QVariantList &replayIds);
    void replayIn(int replayId, const QString &replayJson);

    void userChanged();
    void statsChanged();
    void lookedAround();
    void lastNonceChanged();
    void bookingsChanged();

    void tableEvent(PTable::Event type, const QVariantMap &args);

public slots:
    void action(QString actStr, const QVariant &actArg);

private slots:
    static PTable::Event eventOf(const QString &event);
    void onRemoteClosed();
    void onJsonReceived(const QJsonObject &msg);
    void recvTableEvent(const QJsonObject &msg);
    void heartbeat();

private:
    QString hash(const QString &password) const;
    void updateStats(const QVariantList &stats);

private:
    static PClient *sInstance;

    PJsonTcpSocket mSocket;
    QTimer mHeartbeatTimer;
    QVariantMap mUser;
    QVariantList mStats;
    QVariantList mBookings;
    int mConnCt = 0;
    QVariantList mBooks;
    QVariantList mWater;
    int mLastNonce = 0;
};

QObject *pClientSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine);



#endif // P_CLIENT_H


