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
    Q_PROPERTY(bool nightMode READ nightMode WRITE setNightMode NOTIFY nightModeChanged)
    Q_PROPERTY(QColor themeBack READ themeBack NOTIFY themeBackChanged)
    Q_PROPERTY(QColor themeText READ themeText NOTIFY themeTextChanged)
    Q_PROPERTY(QString savedUsername READ savedUsername WRITE setSavedUsername\
               NOTIFY savedUsernameChanged)
    Q_PROPERTY(bool savePassword READ savePassword WRITE setSavePassword NOTIFY savePasswordChanged)
    Q_PROPERTY(QString savedPassword READ savedPassword WRITE setSavedPassword\
               NOTIFY savedPasswordChanged)

    Q_INVOKABLE void save();
    Q_INVOKABLE static void forceImmersive();

    static QString version();

    QVariant backColors() const;
    void setBackColors(const QVariant &v);

    bool nightMode() const;
    void setNightMode(bool v);

    QColor themeBack() const;
    QColor themeText() const;

    QString savedUsername() const;
    void setSavedUsername(const QString &username);

    bool savePassword() const;
    void setSavePassword(bool v);
    QString savedPassword() const;
    void setSavedPassword(const QString &password);

signals:
    void versionChanged(); // placeholder
    void backColorsChanged();
    void nightModeChanged();
    void themeBackChanged();
    void themeTextChanged();
    void savedUsernameChanged();
    void savePasswordChanged();
    void savedPasswordChanged();

public slots:

private:
    void regulateRoot();

private:
    QJsonObject root;
};

QObject *pGlobalSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine);

#endif // P_GLOBAL_H


