#include "p_table.h"
#include "p_table_local.h"
#include "p_client.h"
#include "p_port.h"

#include "libsaki/util/string_enum.h"
#include "libsaki/util/misc.h"

#include <QEventLoop>
#include <QFile>



using namespace saki;



PTable::PTable(QObject *parent)
    : QObject(parent)
{
}

PTable::~PTable()
{
    clearEventFeeds();
}

void PTable::startPrac(const int &girlId)
{
    clearEventFeeds();
    mOnline = false;

    PTableLocal *table = new PTableLocal;
    table->moveToThread(&mWorkThread);
    mWorkThread.start();

    connect(&mWorkThread, &QThread::finished, table, &PTableLocal::deleteLater);

    connect(this, &PTable::action, table, &PTableLocal::action);
    connect(table, &PTableLocal::tableEvent, this, &PTable::tableEvent);

    table->startPrac(girlId);
}

void PTable::startLocal(const QVariant &girlIdsVar, const QVariant &gameRule,
                        int tempDealer)
{
    clearEventFeeds();
    mOnline = false;

    PTableLocal *table = new PTableLocal;
    table->moveToThread(&mWorkThread);
    mWorkThread.start();

    connect(&mWorkThread, &QThread::finished, table, &PTableLocal::deleteLater);

    connect(this, &PTable::action, table, &PTableLocal::action);
    connect(this, &PTable::saveRecord, table, &PTableLocal::saveRecord);
    connect(table, &PTableLocal::tableEvent, this, &PTable::tableEvent);

    table->start(girlIdsVar, gameRule, tempDealer);
}

void PTable::startOnline()
{
    clearEventFeeds();
    mOnline = true;

    connect(this, &PTable::action, &PClient::instance(), &PClient::action);
    connect(&PClient::instance(), &PClient::tableEvent, this, &PTable::tableEvent);
}

void PTable::startSample()
{
    QFile file(":/json/sample1.json");
    file.open(QIODevice::ReadOnly | QIODevice::Text);
    QString val = file.readAll();
    file.close();

    QJsonParseError error;
    QJsonDocument d = QJsonDocument::fromJson(val.toUtf8(), &error);
    if (d.isNull()) {
        qDebug() << "json parse error: "
                 << error.offset << ' ' << error.errorString();
        return;
    }

    QJsonArray msgs = d.array();

    clearEventFeeds();
    mOnline = false;

    for (const auto &msg : msgs) {
        QJsonObject obj = msg.toObject();
        if (obj.contains("Pack")) {
            QString pack = obj["Pack"].toString();
            if (pack == "my-in-out") {
                QString in = obj["In"].toString();
                QString out = obj["Out"].toString();
                int outPos = obj["OutPos"].toInt();

                emit tableEvent("drawn", QVariantMap { { "who", 0 }, { "tile", in } });
                emit tableEvent("just-pause", QVariantMap { { "ms", 300 } });
                emit tableEvent("just-set-out-pos", QVariantMap { { "outPos", outPos } });
                emit tableEvent("discarded", QVariantMap { { "who", 0 }, { "tile", out } });
            } else if (pack == "oppo-out") {
                int who = obj["Who"].toInt();
                QString out = obj["Out"].toString();
                bool spin = obj["Spin"].toBool();

                emit tableEvent("drawn", QVariantMap { { "who", who } });
                emit tableEvent("just-pause", QVariantMap { { "ms", 300 } });
                QVariantMap args { { "who", who }, { "tile", out }, { "spin", spin } };
                emit tableEvent("discarded", args);
            } else {
                qDebug() << "unknown pack " << pack;
            }
        } else {
            QString event = obj["Event"].toString();
            QVariantMap args = obj["Args"].toObject().toVariantMap();
            emit tableEvent(event, args);
        }
    }
}

bool PTable::online() const
{
    return mOnline;
}

void PTable::clearEventFeeds()
{
    // clear table-local
    if (mWorkThread.isRunning()) {
        mWorkThread.quit();
        mWorkThread.wait();
    }
}
