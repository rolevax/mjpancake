#include "p_editor.h"
#include "p_global.h"

#include <QDir>
#include <QJsonDocument>
#include <QBuffer>



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
    return getGirlJson(path)["name"].toString();
}

QString PEditor::getLuaCode(QString path)
{
    QString res("");

    QFile file(PGlobal::editPath(path + ".girl.lua"));
    if (file.exists()) {
        file.open(QIODevice::ReadOnly | QIODevice::Text);
        QString val = file.readAll();
        res = val;
        // TODO cache file conotent with a LRU container
    }

    return res;
}

QUrl PEditor::getLuaCodeUrl(QString path)
{
    return QUrl::fromLocalFile(PGlobal::editPath(path + ".girl.lua"));
}

QImage PEditor::getPhoto(QString path)
{
    QString base64 = getGirlJson(path)["photoBase64"].toString();
    return QImage::fromData(QByteArray::fromBase64(base64.toLatin1()), "PNG");
}

void PEditor::saveJson(QString path, QString name, QUrl photoUrl)
{
    if (path.isEmpty())
        return;

    QFile jsonFile(PGlobal::editPath(path + ".girl.json"));

    QJsonObject obj;
    obj["name"] = name;

    QImage image(photoUrl.toLocalFile());
    if (!image.isNull()) {
        QByteArray byteArray;
        QBuffer buffer(&byteArray);
        image.save(&buffer, "PNG");
        obj["photoBase64"] = QString::fromLatin1(byteArray.toBase64().data());
    } else {
        obj["photoBase64"] = "";
    }

    jsonFile.open(QIODevice::WriteOnly | QIODevice::Text);
    jsonFile.write(QJsonDocument(obj).toJson());
}

void PEditor::saveLuaCode(QString path, QString luaCode)
{
    if (path.isEmpty())
        return;

    QFile luaFile(PGlobal::editPath(path + ".girl.lua"));
    luaFile.open(QIODevice::WriteOnly | QIODevice::Text);
    luaFile.write(luaCode.toUtf8());
}

void PEditor::remove(QString path)
{
    QFile::remove(PGlobal::editPath(path + ".girl.json"));
    QFile::remove(PGlobal::editPath(path + ".girl.lua"));
}

QJsonObject PEditor::getGirlJson(QString path)
{
    // TODO cache file conotent with a LRU container

    QJsonObject res;

    QFile jsonFile(PGlobal::editPath(path + ".girl.json"));
    if (jsonFile.exists()) {
        jsonFile.open(QIODevice::ReadOnly | QIODevice::Text);
        QString val = jsonFile.readAll();
        jsonFile.close();
        QJsonDocument d = QJsonDocument::fromJson(val.toUtf8());
        res = d.object();
    }

    return res;
}

QObject *pEditorSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return new PEditor();
}
