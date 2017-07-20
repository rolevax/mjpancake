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
    }

    regulateRoot();
}

PGlobal::~PGlobal()
{
    save();
}

void PGlobal::save()
{
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
    return QString("0.8.3");
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

QColor PGlobal::themeBack() const
{
    return QColor("#202030");
}

QColor PGlobal::themeText() const
{
    return QColor("#AAAAAA");
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

void PGlobal::regulateRoot()
{
    if (!mRoot["backColors"].isArray())
        mRoot["backColors"] = QJsonArray{ "#DD9900", "#111166" };

    if (!mRoot["savedUsername"].isString())
        mRoot["savedUsername"] = QString();

    if (!mRoot["savePassword"].isBool())
        mRoot["savePassword"] = true;

    if (!mRoot["savedPassword"].isString())
        mRoot["savedPassword"] = QString();

    if (!(mRoot["redDots"].isArray() && mRoot["redDots"].toArray().size() == 6))
        mRoot["redDots"] = QJsonArray{ true, false, false, false, false, false };

    if (!mRoot["mute"].isBool())
        mRoot["mute"] = false;
}

QObject *pGlobalSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    PGlobal *pGlobal = new PGlobal();
    return pGlobal;
}
