#ifndef P_GLOBAL_H
#define P_GLOBAL_H

#include <QObject>
#include <QJsonDocument>
#include <QJsonObject>
#include <QVariant>
#include <QQmlEngine>
#include <QColor>

class PGlobal : public QObject
{
    Q_OBJECT
public:
    explicit PGlobal(QObject *parent = 0);
    ~PGlobal();

    Q_PROPERTY(QString version READ version NOTIFY versionChanged)
    Q_PROPERTY(QVariant backColors READ backColors WRITE setBackColors NOTIFY backColorsChanged)
    Q_PROPERTY(QColor themeBack READ themeBack NOTIFY themeBackChanged)
    Q_PROPERTY(QColor themeText READ themeText NOTIFY themeTextChanged)
    Q_PROPERTY(QString savedUsername READ savedUsername WRITE setSavedUsername\
               NOTIFY savedUsernameChanged)
    Q_PROPERTY(bool savePassword READ savePassword WRITE setSavePassword NOTIFY savePasswordChanged)
    Q_PROPERTY(QString savedPassword READ savedPassword WRITE setSavedPassword\
               NOTIFY savedPasswordChanged)
    Q_PROPERTY(QVariantList redDots READ redDots WRITE setRedDots NOTIFY redDotsChanged)
    Q_PROPERTY(bool mute READ mute WRITE setMute NOTIFY muteChanged)

    Q_INVOKABLE void save();
    Q_INVOKABLE static void forceImmersive();
    Q_INVOKABLE static void systemNotify();

    static QString version();
    static QString configPath();
    static QString photoPath();
    static QString replayPath(QString filename = "");

    QVariant backColors() const;
    void setBackColors(const QVariant &v);

    QColor themeBack() const;
    QColor themeText() const;

    QString savedUsername() const;
    void setSavedUsername(const QString &username);

    bool savePassword() const;
    void setSavePassword(bool v);
    QString savedPassword() const;
    void setSavedPassword(const QString &password);

    QVariantList redDots() const;
    void setRedDots(const QVariantList &v);

    bool mute() const;
    void setMute(bool v);

signals:
    void versionChanged(); // placeholder
    void backColorsChanged();
    void themeBackChanged();
    void themeTextChanged();
    void savedUsernameChanged();
    void savePasswordChanged();
    void savedPasswordChanged();
    void redDotsChanged();
    void muteChanged();

public slots:

private:
    void regulateRoot();

private:
    QJsonObject mRoot;
};

QObject *pGlobalSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine);

#endif // P_GLOBAL_H


