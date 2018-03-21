#ifndef P_EDITOR_H
#define P_EDITOR_H

#include <QObject>
#include <QQmlEngine>
#include <QVariantList>
#include <QVariantMap>



class PEditor : public QObject
{
    Q_OBJECT

public:
    explicit PEditor(QObject *parent = nullptr);

    static PEditor &instance();

    Q_INVOKABLE QStringList ls();
    Q_INVOKABLE QString getName(QString path);
    Q_INVOKABLE QString getLuaCode(QString path);
    Q_INVOKABLE void save(QString path, QString name, QString luaCode);
    Q_INVOKABLE void remove(QString path);

signals:

private slots:

private:
    static PEditor *sInstance;
};



QObject *pEditorSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine);



#endif // P_EDITOR_H
