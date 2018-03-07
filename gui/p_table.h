#ifndef P_TABLE_H
#define P_TABLE_H

#include <QObject>
#include <QThread>

class PClient;

class PTable : public QObject
{
    Q_OBJECT

public:
    explicit PTable(QObject *parent = 0);
    ~PTable();

    Q_PROPERTY(bool online READ online NOTIFY onlineChanged)

    Q_INVOKABLE void startPrac(const int &girlId);
    Q_INVOKABLE void startLocal(const QVariant &girlIds, const QVariant &gameRule,
                                int tempDealer);
    Q_INVOKABLE void startOnline();
    Q_INVOKABLE void startSample();

    bool online() const;

signals:
    void onlineChanged();
    void action(const QString &actStr, int actArg, const QString &actTile, int nonce);
    void saveRecord();
    void tableEvent(const QString &type, const QVariantMap &args);

public slots:

private:
    void clearEventFeeds();

private:
    QThread mWorkThread;
    bool mOnline = false;
};

#endif // P_TABLE_H
