#include "p_editor.h"
#include "p_global.h"

#include <QDir>
#include <QJsonDocument>
#include <QJsonArray>
#include <QBuffer>
#include <QDesktopServices>
#include <QNetworkReply>
#include <QDebug>



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
    connect(&mNet, &QNetworkAccessManager::finished, this, &PEditor::onNetReply);
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

QVariantList PEditor::listCachedGirls()
{
    QVariantList list;

    QDir dir(PGlobal::editPath("", "github.com"));
    dir.setFilter(QDir::Dirs | QDir::NoDotAndDotDot);
    dir.setSorting(QDir::Name);
    for (QString userDir : dir.entryList()) {
        QDir dir(PGlobal::editPath("", "github.com/" + userDir));
        dir.setFilter(QDir::Dirs | QDir::NoDotAndDotDot);
        dir.setSorting(QDir::Name);

        for (QString repoDir : dir.entryList()) {
            QString shortAddr = userDir + "/" + repoDir;
            QString girlPathPrefix = "github.com/" + shortAddr;
            QVariantMap map;
            map["repo"] = shortAddr;
            map["girlPathPrefix"] = girlPathPrefix;

            QDir dir(PGlobal::editPath("", girlPathPrefix));
            dir.setNameFilters(QStringList { QString("*.girl.json") });
            dir.setSorting(QDir::Name);
            QStringList girls = dir.entryList();
            for (QString &str : girls)
                str.chop(10);

            map["girls"] = girls;
            list << map;
        }
    }

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
    } else {
        qDebug() << "file tan90: " << file.fileName();
    }

    return res;
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

void PEditor::editLuaExternally(QString path)
{
    QString filename(PGlobal::editPath(path + ".girl.lua"));
    QFile(filename).open(QIODevice::ReadWrite); // create if tan90
    QDesktopServices::openUrl(QUrl::fromLocalFile(filename));
}

void PEditor::fetchSignedRepos()
{
    const QUrl url("https://api.github.com/repos/rolevax/libsaki/issues/51/comments");
    httpGet(url, &PEditor::recvRepoList);
}

///
/// \brief Starat to download a girl repo, discard all current downloads
/// \param shortAddr GitHub repo address in form "username/repo-name"
///
void PEditor::downloadRepo(QString shortAddr)
{
    const QString repoFmt("https://api.github.com/repos/%1/contents/");
    QString repoAddr = repoFmt.arg(shortAddr);
    httpGet(repoAddr, &PEditor::recvRepoDir);
    emit repoDownloadProgressed(0);
}

void PEditor::cancelDownload()
{
    httpAbortAll();
}

void PEditor::onNetReply(QNetworkReply *reply)
{
    ReplyEraseGuard guard(*this, reply);
    (this->*mReplies[reply])(reply);
}

QJsonObject PEditor::getGirlJson(QString path)
{
    // TODO cache file conotent with an LRU container

    QJsonObject res;

    QFile jsonFile(PGlobal::editPath(path + ".girl.json"));
    if (jsonFile.exists()) {
        jsonFile.open(QIODevice::ReadOnly | QIODevice::Text);
        QString val = jsonFile.readAll();
        jsonFile.close();
        QJsonDocument d = QJsonDocument::fromJson(val.toUtf8());
        res = d.object();
    } else {
        qDebug() << "file tan90: " << jsonFile.fileName();
    }

    return res;
}

void PEditor::httpGet(QUrl url, void (PEditor::*recv)(QNetworkReply *))
{
    QNetworkRequest request;
    request.setUrl(url);
    request.setHeader(QNetworkRequest::UserAgentHeader, "rolevax");
    mReplies.insert(mNet.get(request), recv);
}

void PEditor::httpAbortAll()
{
    for (QNetworkReply *reply : mReplies.keys())
        reply->abort();

    mReplies.clear();
}

QJsonDocument PEditor::replyToJson(QNetworkReply *reply)
{
    QString str = reply->readAll();
    return QJsonDocument::fromJson(str.toUtf8());
}

void PEditor::recvRepoList(QNetworkReply *reply)
{
    if (reply->error()) {
        qDebug() << reply->errorString();
        return;
    }

    QJsonDocument replyDoc = replyToJson(reply);
    QVariantList issues = replyDoc.array().toVariantList();

    QVariantList repos;
    for (QVariant issueVar : issues) {
        QVariantMap issue = issueVar.toMap();
        QString bodyStr = issue["body"].toString();
        QJsonDocument bodyDoc = QJsonDocument::fromJson(bodyStr.toUtf8());
        if (bodyDoc.isObject()) {
            QJsonObject bodyObj = bodyDoc.object();
            repos << bodyObj.toVariantMap();
        }
    }

    emit signedReposReplied(repos);
}

void PEditor::recvRepoDir(QNetworkReply *reply)
{
    if (reply->error()) {
        qDebug() << reply->errorString();
        emit repoDownloadProgressed(-1);
        return;
    }

    emit repoDownloadProgressed(1);
    QJsonDocument replyDoc = replyToJson(reply);
    if (!replyDoc.isArray()) {
        emit repoDownloadProgressed(-1);
        return;
    }

    QJsonArray files = replyDoc.array();
    QStringList targets;
    for (auto value : files) {
        QJsonObject file = value.toObject();
        if (file["type"].toString() != "file")
            continue;

        QString name = file["name"].toString();
        if (name.endsWith(".girl.json") || name.endsWith(".girl.lua")) {
            QString addr = file["download_url"].toString();
            targets << addr;
        }
    }

    mTotalFilesToDownload = targets.size();
    for (const auto &addr : targets)
        httpGet(addr, &PEditor::recvFile);
}

void PEditor::recvFile(QNetworkReply *reply)
{
    if (reply->error()) {
        qDebug() << reply->errorString();
        httpAbortAll();
        emit repoDownloadProgressed(-1);
        return;
    }

    // assume uri in format ".../user/repo/branch/filename"
    QStringList split = reply->request().url().toString().split("/");
    QString filename = split.at(split.size() - 1);
    QString repo = split.at(split.size() - 3);
    QString user = split.at(split.size() - 4);
    QString dirSuffix = "github.com/" + user + "/" + repo;
    qDebug() << "download file to:" << dirSuffix << ' ' << filename;

    QString content = reply->readAll();
    QFile file(PGlobal::editPath(filename, dirSuffix));
    file.open(QIODevice::WriteOnly | QIODevice::Text);
    file.write(content.toUtf8());

    double sizePerFile = 100.0 / mTotalFilesToDownload;
    int percent = 100 - static_cast<int>((mReplies.size() - 1) * sizePerFile);
    emit repoDownloadProgressed(percent);
}

QObject *pEditorSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return new PEditor();
}

PEditor::ReplyEraseGuard::ReplyEraseGuard(PEditor &editor, QNetworkReply *reply)
    : mEditor(editor)
    , mReply(reply)
{
}

PEditor::ReplyEraseGuard::~ReplyEraseGuard()
{
    mEditor.mReplies.remove(mReply);
    mReply->deleteLater();
}
