#ifndef P_CLIENT_H
#define P_CLIENT_H

#include "p_json_tcp.h"
#include "p_table.h"

#include <QObject>
#include <QQmlEngine>
#include <QJSEngine>
#include <QVariantMap>



class PClient : public QObject
{
    Q_OBJECT
public:
    explicit PClient(QObject *parent = nullptr);

    Q_PROPERTY(bool loggedIn READ loggedIn NOTIFY userChanged)
    Q_PROPERTY(QVariantMap user READ user NOTIFY userChanged)
    Q_PROPERTY(int playCt READ playCt NOTIFY userChanged)
    Q_PROPERTY(int connCt READ connCt NOTIFY lookedAround)
    Q_PROPERTY(QVariantMap books READ books NOTIFY lookedAround)
    Q_PROPERTY(int lastNonce READ lastNonce NOTIFY lastNonceChanged)

    Q_INVOKABLE void login(const QString &username, const QString &password);
    Q_INVOKABLE void signUp(const QString &username, const QString &password);
    Q_INVOKABLE void lookAround();
    Q_INVOKABLE void book(const QString &bookType);
    Q_INVOKABLE void unbook();
    Q_INVOKABLE void sendReady();
    Q_INVOKABLE void sendResume();

    QVariantMap user() const;
    bool loggedIn() const;
    int playCt() const;
    int connCt() const;
    QVariantMap books() const;
    int lastNonce() const;

signals:
    void remoteClosed();
    void connError();
    void authFailIn(const QString &reason);
    void startIn(const QVariantList &users, const QVariantList &girlIds, int tempDealer);
    void resumeIn();

    void userChanged();
    void lookedAround();
    void lastNonceChanged();

    void tableEvent(PTable::Event type, const QVariantMap &args);

public slots:
    void action(QString actStr, const QVariant &actArg);

private:
    static PTable::Event eventOf(const QString &event);
    void onRemoteClosed();
    void send(const QJsonObject &obj);
    void onJsonReceived(const QJsonObject &msg);
    void recvTableEvent(const QJsonObject &msg);

    QString hash(const QString &password) const;

private:
    PJsonTcpSocket mSocket;
    QVariantMap mUser;
    int mConnCt = 0;
    QVariantMap mBooks;
    int mLastNonce = 0;
};

QObject *pClientSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine);



#endif // P_CLIENT_H


