#include "p_editor.h"
#include "p_global.h"

#include <QDir>
#include <QJsonDocument>


PEditor::PEditor(QObject *parent)
    : QObject(parent)
{
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

QObject *pEditorSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return new PEditor();
}
