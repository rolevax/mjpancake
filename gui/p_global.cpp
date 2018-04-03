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



PGlobal *PGlobal::sInstance = nullptr;

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

    sInstance = this;
}

PGlobal::~PGlobal()
{
    save();
}

void PGlobal::setBackground(QUrl url)
{
    QString bgPath = PGlobal::configPath() + "/background";
    if (QFile::exists(bgPath))
        QFile::remove(bgPath);

    QFile::copy(url.path(), bgPath);

    emit backgroundCopied();
}

void PGlobal::setPhoto(QString girlId, QUrl url)
{
    QString photoPath(PGlobal::photoPath() + "/" + girlId);
    if (QFile::exists(photoPath))
        QFile::remove(photoPath);

    QFile::copy(url.path(), photoPath);

    emit photoCopied();
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

PGlobal &PGlobal::instance()
{
    return *sInstance;
}

bool PGlobal::official()
{
#ifdef PANCAKE_OFFICIAL
    return true;
#else
    return false;
#endif
}

QString PGlobal::version()
{
#ifdef PANCAKE_OFFICIAL
    return QString("0.9.3");
#else
    return QString("custom-fork");
#endif
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

QString PGlobal::editPath(QString filename)
{
    QString path = configPath() + "/edit";
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

bool PGlobal::mute() const
{
    return mRoot["mute"].toBool();
}

void PGlobal::setMute(bool v)
{
    mRoot["mute"] = v;
    emit muteChanged();
}

QVariantMap PGlobal::hints() const
{
    return mRoot["hints"].toObject().toVariantMap();
}

void PGlobal::setHints(const QVariantMap &v)
{
    mRoot["hints"] = QJsonObject::fromVariantMap(v);
    emit hintsChanged();
}

void PGlobal::regulateRoot()
{
    if (!mRoot["backColors"].isArray())
        mRoot["backColors"] = QJsonArray { "#DD9900", "#111166" };

    if (!mRoot["savedUsername"].isString())
        mRoot["savedUsername"] = QString();

    if (!mRoot["savePassword"].isBool())
        mRoot["savePassword"] = true;

    if (!mRoot["savedPassword"].isString())
        mRoot["savedPassword"] = QString();

    if (!mRoot["mute"].isBool())
        mRoot["mute"] = false;

    QJsonObject hints {
        { "op", true },
        { "replay", true }
    };

    if (!(mRoot["hints"].isObject()
          && mRoot["hints"].toObject().size() == hints.size())) {
        mRoot["hints"] = hints;
    }
}

QObject *pGlobalSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return new PGlobal();
}
