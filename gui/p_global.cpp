#include "gui/p_global.h"

#include <QDir>
#include <QStandardPaths>
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
    QFile file(configPath() + "/settings.json");

    if (file.exists()) {
        file.open(QIODevice::ReadOnly | QIODevice::Text);
        QString val = file.readAll();
        file.close();
        QJsonDocument d = QJsonDocument::fromJson(val.toUtf8());
        mRoot = d.object();
        if (mRoot["photoMap"].isObject())
            mCachedPhotoMap = mRoot["photoMap"].toObject();
    }

    regulateRoot();
}

PGlobal::~PGlobal()
{
    save();
}

void PGlobal::save()
{
    mRoot["photoMap"] = mCachedPhotoMap;

    QFile file(configPath() + "/settings.json");

    file.open(QIODevice::WriteOnly | QIODevice::Text);
    file.write(QJsonDocument(mRoot).toJson());
}

void PGlobal::forceImmersive()
{
#ifdef Q_OS_ANDROID
    QAndroidJniObject::callStaticMethod<void>(
                "rolevax/sakilogy/ImagePickerActivity",
                "forceImmersive",
                "()V");
#endif
}

void PGlobal::systemNotify()
{
#ifdef Q_OS_ANDROID
    QAndroidJniObject::callStaticMethod<void>(
                "rolevax/sakilogy/ImagePickerActivity",
                "popNotification",
                "()V");
#endif
}

QString PGlobal::version()
{
    return QString("0.8.2");
}

QString PGlobal::configPath()
{
    QString res = QStandardPaths::writableLocation(QStandardPaths::AppConfigLocation);
    QDir().mkpath(res);
    return res;
}

QString PGlobal::photoPath()
{
    QString path = configPath() + "/photos";
    QDir().mkpath(path);
    return path;
}

QString PGlobal::replayPath(QString filename)
{
    QString path = configPath() + "/replay";
    QDir().mkpath(path);
    if (!filename.isEmpty())
        path += "/" + filename;
    return path;
}

QVariant PGlobal::backColors() const
{
    return mRoot["backColors"].toVariant();
}

void PGlobal::setBackColors(const QVariant &v)
{
    mRoot["backColors"] = QJsonArray::fromVariantList(v.toList());
    emit backColorsChanged();
}

bool PGlobal::nightMode() const
{
    return mRoot["nightMode"].toBool();
}

void PGlobal::setNightMode(bool v)
{
    mRoot["nightMode"] = v;
    emit nightModeChanged();
    emit themeBackChanged();
    emit themeTextChanged();
}

QColor PGlobal::themeBack() const
{
    return mRoot["nightMode"].toBool() ? QColor("#202030") : QColor("#FFFFFF");
}

QColor PGlobal::themeText() const
{
    return mRoot["nightMode"].toBool() ? QColor("#AAAAAA") : QColor("#111111");
}

QString PGlobal::savedUsername() const
{
    return mRoot["savedUsername"].toString();
}

void PGlobal::setSavedUsername(const QString &username)
{
    mRoot["savedUsername"] = username;
    emit savedUsernameChanged();
}

bool PGlobal::savePassword() const
{
    return mRoot["savePassword"].toBool();
}

void PGlobal::setSavePassword(bool v)
{
    mRoot["savePassword"] = v;
    emit savePasswordChanged();
    if (!v)
        setSavedPassword("");
}

QString PGlobal::savedPassword() const
{
    return mRoot["savedPassword"].toString();
}

void PGlobal::setSavedPassword(const QString &password)
{
    mRoot["savedPassword"] = password;
    emit savedPasswordChanged();
}

QVariantList PGlobal::redDots() const
{
    return mRoot["redDots"].toArray().toVariantList();
}

void PGlobal::setRedDots(const QVariantList &v)
{
    mRoot["redDots"] = QJsonArray::fromVariantList(v);
    emit redDotsChanged();
}

bool PGlobal::mute() const
{
    return mRoot["mute"].toBool();
}

void PGlobal::setMute(bool v)
{
    mRoot["mute"] = v;
    emit muteChanged();
}

QVariantMap PGlobal::photoMap() const
{
    return mCachedPhotoMap.toVariantMap();
}

void PGlobal::setPhoto(const QString &girlId, int value)
{
    mCachedPhotoMap[girlId] = value;
    emit photoMapChanged();
}

void PGlobal::regulateRoot()
{
    if (!mRoot["backColors"].isArray())
        mRoot["backColors"] = QJsonArray{ "#DD9900", "#111166" };

    if (!mRoot["nightMode"].isBool())
        mRoot["nightMode"] = false;

    if (!mRoot["savedUsername"].isString())
        mRoot["savedUsername"] = QString();

    if (!mRoot["savePassword"].isBool())
        mRoot["savePassword"] = false;

    if (!mRoot["savedPassword"].isString())
        mRoot["savedPassword"] = QString();

    if (!(mRoot["redDots"].isArray() && mRoot["redDots"].toArray().size() == 6))
        mRoot["redDots"] = QJsonArray{ true, false, false, false, false, false };

    if (!mRoot["mute"].isBool())
        mRoot["mute"] = false;

    if (!mRoot["photoMap"].isObject())
        mRoot["photoMap"] = QJsonObject();
}

QObject *pGlobalSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    PGlobal *pGlobal = new PGlobal();
    return pGlobal;
}
