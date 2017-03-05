#include "gui/p_global.h"

#include <QDir>
#include <QFile>
#include <QJsonArray>
#include <QColor>
#ifdef Q_OS_ANDROID
#include <QAndroidJniObject>
#endif

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

void PGlobal::forceImmersive()
{
#ifdef Q_OS_ANDROID
    QAndroidJniObject::callStaticObjectMethod(
                "rolevax/sakilogy/ImagePickerActivity",
                "forceImmersive",
                "()Ljava/lang/Object;");
#endif
}

QString PGlobal::version()
{
    return QString("0.7.2");
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

QString PGlobal::savedUsername() const
{
    return root["savedUsername"].toString();
}

void PGlobal::setSavedUsername(const QString &username)
{
    root["savedUsername"] = username;
    emit savedUsernameChanged();
}

bool PGlobal::savePassword() const
{
    return root["savePassword"].toBool();
}

void PGlobal::setSavePassword(bool v)
{
    root["savePassword"] = v;
    emit savePasswordChanged();
    if (!v)
        setSavedPassword("");
}

QString PGlobal::savedPassword() const
{
    return root["savedPassword"].toString();
}

void PGlobal::setSavedPassword(const QString &password)
{
    root["savedPassword"] = password;
    emit savedPasswordChanged();
}

QVariantList PGlobal::redDots() const
{
    return root["redDots"].toArray().toVariantList();
}

void PGlobal::setRedDots(const QVariantList &v)
{
    root["redDots"] = QJsonArray::fromVariantList(v);
    emit redDotsChanged();
}

bool PGlobal::mute() const
{
    return root["mute"].toBool();
}

void PGlobal::setMute(bool v)
{
    root["mute"] = v;
    emit muteChanged();
}

void PGlobal::regulateRoot()
{
    if (!root["backColors"].isArray())
        root["backColors"] = QJsonArray{ "#DD9900", "#111166" };

    if (!root["nightMode"].isBool())
        root["nightMode"] = false;

    if (!root["savedUsername"].isString())
        root["savedUsername"] = QString();

    if (!root["savePassword"].isBool())
        root["savePassword"] = false;

    if (!root["savedPassword"].isString())
        root["savedPassword"] = QString();

    if (!(root["redDots"].isArray() && root["redDots"].toArray().size() == 6))
        root["redDots"] = QJsonArray{ true, true, false, false, true, true };

    if (!root["mute"].isBool())
        root["mute"] = false;
}

QObject *pGlobalSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    PGlobal *pGlobal = new PGlobal();
    return pGlobal;
}
