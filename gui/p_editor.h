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

    Q_INVOKABLE QStringList ls();
    Q_INVOKABLE void save(QString path, QString name, QString luaCode);

signals:

private slots:

private:
};



QObject *pEditorSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine);



#endif // P_EDITOR_H
