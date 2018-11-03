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

    Q_PROPERTY(QString version READ version NOTIFY nothingChanged)
    Q_PROPERTY(bool official READ official NOTIFY nothingChanged)
    Q_PROPERTY(QVariant backColors READ backColors WRITE setBackColors NOTIFY backColorsChanged)
    Q_PROPERTY(QString savedUsername READ savedUsername WRITE setSavedUsername \
               NOTIFY savedUsernameChanged)
    Q_PROPERTY(bool savePassword READ savePassword WRITE setSavePassword NOTIFY savePasswordChanged)
    Q_PROPERTY(QString savedPassword READ savedPassword WRITE setSavedPassword \
               NOTIFY savedPasswordChanged)
    Q_PROPERTY(bool mute READ mute WRITE setMute NOTIFY muteChanged)
    Q_PROPERTY(QVariantMap hints READ hints WRITE setHints NOTIFY hintsChanged)

    Q_INVOKABLE void setBackground(QUrl url);
    Q_INVOKABLE void setPhoto(QString girlId, QUrl url);
    Q_INVOKABLE void save();
    Q_INVOKABLE static void forceImmersive();
    Q_INVOKABLE static void systemNotify();

    static PGlobal &instance();

    static bool official();
    static QString version();
    static QString configPath();
    static QString photoPath();
    static QString replayPath(QString filename = "");
    static QString editPath(QString filename = "", QString dirSuffix = "");

    QVariant backColors() const;
    void setBackColors(const QVariant &v);

    QString savedUsername() const;
    void setSavedUsername(const QString &username);

    bool savePassword() const;
    void setSavePassword(bool v);
    QString savedPassword() const;
    void setSavedPassword(const QString &password);

    bool mute() const;
    void setMute(bool v);

    QVariantMap hints() const;
    void setHints(const QVariantMap &v);

signals:
    void nothingChanged(); // placeholder
    void backColorsChanged();
    void savedUsernameChanged();
    void savePasswordChanged();
    void savedPasswordChanged();
    void muteChanged();
    void hintsChanged();
    void backgroundCopied();
    void photoCopied();

public slots:

private:
    void regulateRoot();

private:
    static PGlobal *sInstance;
    QJsonObject mRoot;
};

QObject *pGlobalSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine);

#endif // P_GLOBAL_H
