#include "p_editor.h"
#include "p_global.h"

#include <QDir>
#include <QJsonDocument>



PEditor *PEditor::sInstance = nullptr;

PEditor::PEditor(QObject *parent)
    : QObject(parent)
{
    sInstance = this;
}

PEditor &PEditor::instance()
{
    return *sInstance;
}

QStringList PEditor::ls()
{
    QDir dir(PGlobal::editPath());

    dir.setNameFilters(QStringList { QString("*.girl.json") });
    dir.setSorting(QDir::Name);

    QStringList list = dir.entryList();
    for (QString &str : list)
        str.chop(10);

    return list;
}

QString PEditor::getName(QString path)
{
    QString res("");

    QFile jsonFile(PGlobal::editPath(path + ".girl.json"));
    if (jsonFile.exists()) {
        jsonFile.open(QIODevice::ReadOnly | QIODevice::Text);
        QString val = jsonFile.readAll();
        jsonFile.close();
        QJsonDocument d = QJsonDocument::fromJson(val.toUtf8());
        QJsonObject obj = d.object();
        res = obj["name"].toString();
        // TODO cache file conotent with a LRU container
    }

    return res;
}

QString PEditor::getLuaCode(QString path)
{
    QString res("");

    QFile jsonFile(PGlobal::editPath(path + ".girl.lua"));
    if (jsonFile.exists()) {
        jsonFile.open(QIODevice::ReadOnly | QIODevice::Text);
        QString val = jsonFile.readAll();
        res = val;
        // TODO cache file conotent with a LRU container
    }

    return res;
}

void PEditor::save(QString path, QString name, QString luaCode)
{
    if (path.isEmpty())
        return;

    QFile jsonFile(PGlobal::editPath(path + ".girl.json"));
    QFile luaFile(PGlobal::editPath(path + ".girl.lua"));

    QJsonObject obj;
    obj["name"] = name;
    obj["photoBase64"] = ""; // FUCK
    jsonFile.open(QIODevice::WriteOnly | QIODevice::Text);
    jsonFile.write(QJsonDocument(obj).toJson());

    luaFile.open(QIODevice::WriteOnly | QIODevice::Text);
    luaFile.write(luaCode.toUtf8());
}

void PEditor::remove(QString path)
{
    QFile::remove(PGlobal::editPath(path + ".girl.json"));
    QFile::remove(PGlobal::editPath(path + ".girl.lua"));
}

QObject *pEditorSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return new PEditor();
}
