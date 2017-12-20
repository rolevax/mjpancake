#ifndef P_TABLE_H
#define P_TABLE_H

#include <QObject>
#include <QThread>

class PClient;

class PTable : public QObject
{
    Q_OBJECT

public:
    enum Event
    {
        FirstDealerChoosen, RoundStarted, Cleaned, Diced, Dealt,
        Flipped, Drawn, Discarded, RiichiCalled, RiichiEstablished,
        Barked, RoundEnded, PointsChanged, TableEnded, PoppedUp,
        Activated, Deactivated, JustPause, JustSetOutPos, Resume
    };

    Q_ENUM(Event)

    explicit PTable(QObject *parent = 0);
    ~PTable();

    Q_PROPERTY(bool online READ online NOTIFY onlineChanged)

    Q_INVOKABLE void startPrac(const int &girlId);
    Q_INVOKABLE void startLocal(const QVariant &girlIds, const QVariant &gameRule,
                                int tempDealer);
    Q_INVOKABLE void startOnline(PClient *client);
    Q_INVOKABLE void startSample();

    bool online() const;

signals:
    void onlineChanged();
    void action(const QString &actStr, int actArg, const QString &actTile);
    void saveRecord();
    void tableEvent(Event type, const QVariantMap &args);

public slots:

private:
    void clearLogicFeeds();

private:
    QThread mWorkThread;
    bool mOnline = false;
};

#endif // P_TABLE_H
