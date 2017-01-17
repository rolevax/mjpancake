#include "gui/p_global.h"

#include <QDir>
#include <QFile>
#include <QJsonArray>
#include <QColor>

#include <cassert>

#include <QDebug>
#include <iostream>

PGlobal::PGlobal(QObject *parent) : QObject(parent)
{
    QDir().mkdir("user");
    QFile file("user/settings.json");

    if (file.exists()) {
        file.open(QIODevice::ReadOnly | QIODevice::Text);
        QString val = file.readAll();
        file.close();
        QJsonDocument d = QJsonDocument::fromJson(val.toUtf8());
        root = d.object();
    } else {
        root = QJsonObject();
    }

    regulateRoot();
}

PGlobal::~PGlobal()
{
    save();
}

void PGlobal::save()
{
    QDir().mkdir("user");
    QFile file("user/settings.json");

    file.open(QIODevice::WriteOnly | QIODevice::Text);
    file.write(QJsonDocument(root).toJson());
}

QVariant PGlobal::backColors() const
{
    return root["backColors"].toVariant();
}

void PGlobal::setBackColors(const QVariant &v)
{
    root["backColors"] = QJsonArray::fromVariantList(v.toList());
    emit backColorsChanged();
}

bool PGlobal::nightMode() const
{
    return root["nightMode"].toBool();
}

void PGlobal::setNightMode(bool v)
{
    root["nightMode"] = v;
    emit nightModeChanged();
    emit themeBackChanged();
    emit themeTextChanged();
}

QColor PGlobal::themeBack() const
{
    return root["nightMode"].toBool() ? QColor("#202030") : QColor("#FFFFFF");
}

QColor PGlobal::themeText() const
{
    return root["nightMode"].toBool() ? QColor("#AAAAAA") : QColor("#111111");
}

void PGlobal::regulateRoot()
{
    if (!root["backColors"].isArray()) // TODO check inside array, see if all QColor str
        root["backColors"] = QJsonArray{ "#DD9900", "#111166" };

    if (!root["nightMode"].isBool())
        root["nightMode"] = false;
}

QObject *pGlobalSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    PGlobal *pGlobal = new PGlobal();
    return pGlobal;
}
