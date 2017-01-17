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

    Q_PROPERTY(QVariant backColors READ backColors WRITE setBackColors NOTIFY backColorsChanged)
    Q_PROPERTY(bool nightMode READ nightMode WRITE setNightMode NOTIFY nightModeChanged)
    Q_PROPERTY(QColor themeBack READ themeBack NOTIFY themeBackChanged)
    Q_PROPERTY(QColor themeText READ themeText NOTIFY themeTextChanged)

    Q_INVOKABLE void save();

    QVariant backColors() const;
    void setBackColors(const QVariant &v);

    bool nightMode() const;
    void setNightMode(bool v);

    QColor themeBack() const;
    QColor themeText() const;

signals:
    void backColorsChanged();
    void nightModeChanged();
    void themeBackChanged();
    void themeTextChanged();

public slots:

private:
    void regulateRoot();

private:
    QJsonObject root;
};

QObject *pGlobalSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine);

#endif // P_GLOBAL_H


