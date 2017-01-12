#ifndef PREPLAY_H
#define PREPLAY_H

#include "libsaki/replay.h"

#include <QObject>
#include <QVariantList>
#include <QVariantMap>



class PReplay : public QObject
{
    Q_OBJECT
public:
    explicit PReplay(QObject *parent = nullptr);

    Q_INVOKABLE QStringList ls();
    Q_INVOKABLE void rm(QString filename);
    Q_INVOKABLE void load(QString filename);
    Q_INVOKABLE QVariantMap meta();
    Q_INVOKABLE QVariantMap look(int roundId, int turn);

signals:

public slots:

private:
    bool loaded = false;
    saki::Replay replay;
};



#endif // PREPLAY_H


