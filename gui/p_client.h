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
    Q_PROPERTY(QVariantList matchWaits READ matchWaits NOTIFY lookedAround)
    Q_PROPERTY(QVariantList matchings READ matchings NOTIFY matchingsChanged)
    Q_PROPERTY(bool hasMatching READ hasMatching NOTIFY matchingsChanged)
    Q_PROPERTY(QVariantList water READ water NOTIFY lookedAround)

    static PClient &instance();

    Q_INVOKABLE bool duringMatchTime();

    Q_INVOKABLE void login(const QString &username, const QString &password);
    Q_INVOKABLE void logout();
    Q_INVOKABLE void lookAround();
    Q_INVOKABLE void sendMatchJoin(int ruleId);
    Q_INVOKABLE void sendMatchCancel();
    Q_INVOKABLE void sendRoomCreate(int girlId, const QVariantList &aiGids);
    Q_INVOKABLE void sendCliamFood();
    Q_INVOKABLE void sendTableSeat();
    Q_INVOKABLE void sendTableChoose(int girlIndex);
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
    QVariantList matchWaits() const;
    QVariantList matchings() const;
    bool hasMatching() const;
    QVariantList water() const;

signals:
    void remoteClosed();
    void connError();
    void authFailIn(const QString &reason);
    void tableInitRecved(const QVariantMap &matchResult,
                         const QVariantList &choices, const QVariantList &foodCosts);
    void tableSeatRecved(const QVariantList &girlIds, int tempDealer);
    void tableEndRecved(bool abortive, const QVariantList &foodChanges);
    void replayListIn(const QVariantList &replayIds);
    void replayIn(int replayId, const QString &replayJson);

    void userChanged(bool resume = false);
    void statsChanged();
    void lookedAround();
    void matchingsChanged();

    void tableEvent(const QString &type, const QVariantMap &args);

public slots:
    void action(const QString &actStr, int actArg, const QString &actTile, int nonce);

private slots:
    void onRemoteClosed();
    void onJsonReceived(const QJsonObject &msg);
    void recvTableEvent(const QJsonObject &msg);
    void heartbeat();

private:
    void clearMatchings();
    void updateStats(const QVariantList &stats);

private:
    static PClient *sInstance;

    PJsonTcpSocket mSocket;
    QTimer mHeartbeatTimer;
    QVariantMap mUser;
    QVariantList mStats;
    QVariantList mMatchings;
    int mConnCt = 0;
    QVariantList mMatchWaits;
    QVariantList mWater;
    int mLastNonce = 0;
};

QObject *pClientSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine);



#endif // P_CLIENT_H
