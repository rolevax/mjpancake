#ifndef P_REPLAY_H
#define P_REPLAY_H

#include "libsaki/app/replay.h"

#include <QObject>
#include <QVariantList>
#include <QVariantMap>

#include <map>



class PReplay : public QObject
{
    Q_OBJECT
public:
    explicit PReplay(QObject *parent = nullptr);

    Q_PROPERTY(QString loadedAppVersion READ loadedAppVersion NOTIFY loaded)
    Q_PROPERTY(QString loadedLibVersion READ loadedLibVersion NOTIFY loaded)

    Q_INVOKABLE QStringList ls();
    Q_INVOKABLE void rm(QString filename);
    Q_INVOKABLE void load(QString filename);
    Q_INVOKABLE void fetch(int replayId);
    Q_INVOKABLE QVariantMap meta();
    Q_INVOKABLE QVariantMap look(int roundId, int turn);

    QString loadedAppVersion() const;
    QString loadedLibVersion() const;

signals:
    void loaded();
    void onlineReplayListReady(const QVariantList &ids);
    void onlineReplayReady();

private slots:
    void replayDownloaded(int id, const QString &json);

private:
    void useOnlineReplay(int id);

private:
    static std::map<int, saki::Replay> sCachedReplays;
    static std::map<int, QVariantList> sCachedUsers;
    bool mLoaded = false;
    saki::Replay mReplay;
    QVariantList mUsers;
    QString mLoadedAppVersion;
    QString mLoadedLibVersion;
};



#endif // P_REPLAY_H


