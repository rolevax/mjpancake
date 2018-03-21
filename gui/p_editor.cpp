#include "p_editor.h"
#include "p_global.h"

#include <QDir>
#include <QJsonDocument>



PLuaHighlighter::PLuaHighlighter(QTextDocument *parent)
    : QSyntaxHighlighter(parent)
{
    HighlightingRule rule;

    mKeywordFormat.setForeground(Qt::green);
    mKeywordFormat.setFontWeight(QFont::Bold);
    mKeywordFormat.setFontItalic(true);
    QStringList keywordPatterns {
        "\\band\\b", "\\bbreak\\b", "\\bdo\\b", "\\belse\\b",
        "\\belseif\\b", "\\bend\\b", "\\bfalse\\b", "\\bfor\\b",
        "\\bfunction\\b", "\\bgoto\\b", "\\bif\\b", "\\bin\\b",
        "\\blocal\\b", "\\bnil\\b", "\\bnot\\b", "\\bor\\b",
        "\\brepeat\\b", "\\breturn\\b", "\\bthen\\b", "\\btrue\\b",
        "\\buntil\\b", "\\bwhile\\b"
    };

    for (const QString &pattern : keywordPatterns) {
        rule.pattern = QRegularExpression(pattern);
        rule.format = mKeywordFormat;
        mRules.append(rule);
    }

    mLineCommentFormat.setForeground(Qt::red);
    rule.pattern = QRegularExpression("--[^\n]*");
    rule.format = mLineCommentFormat;
    mRules.append(rule);

    mBlockCommentFormat.setForeground(Qt::red);

    mStringFormat.setForeground(Qt::darkGreen);
    rule.pattern = QRegularExpression("\".*\"");
    rule.format = mStringFormat;
    mRules.append(rule);

    mCommentStart = QRegularExpression("--\\[\\[");
    mCommentEnd = QRegularExpression("--\\]\\]");
}

void PLuaHighlighter::highlightBlock(const QString &text)
{
    for (const HighlightingRule &rule : mRules) {
        QRegularExpressionMatchIterator matchIterator = rule.pattern.globalMatch(text);
        while (matchIterator.hasNext()) {
            QRegularExpressionMatch match = matchIterator.next();
            setFormat(match.capturedStart(), match.capturedLength(), rule.format);
        }
    }

    setCurrentBlockState(0);

    int startIndex = 0;
    if (previousBlockState() != 1)
        startIndex = text.indexOf(mCommentStart);

    while (startIndex >= 0) {
        QRegularExpressionMatch match = mCommentEnd.match(text, startIndex);
        int endIndex = match.capturedStart();
        int commentLength = 0;
        if (endIndex == -1) {
            setCurrentBlockState(1);
            commentLength = text.length() - startIndex;
        } else {
            commentLength = endIndex - startIndex + match.capturedLength();
        }

        setFormat(startIndex, commentLength, mBlockCommentFormat);
        startIndex = text.indexOf(mCommentStart, startIndex + commentLength);
    }
}



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

void PEditor::setLuaHighlighter(QQuickTextDocument *qtd)
{
    mLuaHighlighter.setDocument(qtd->textDocument());
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
