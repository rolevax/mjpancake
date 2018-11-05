#include "p_girl_down.h"
#include "p_global.h"

#include <QDir>
#include <QJsonDocument>
#include <QJsonArray>
#include <QNetworkReply>
#include <QDebug>



PGirlDown::PGirlDown(QObject *parent)
    : QObject(parent)
{
    connect(&mNet, &QNetworkAccessManager::finished, this, &PGirlDown::onNetReply);
}

PGirlDown::~PGirlDown()
{
    cancelDownload();
    // FUCK delete repliers?
}

void PGirlDown::fetchSignedRepos()
{
    const QUrl url("https://api.github.com/repos/rolevax/libsaki/issues/51/comments");
    httpGet(url, &PGirlDown::recvRepoList);
}

///
/// \brief Starat to download a girl repo, discard all current downloads
/// \param shortAddr GitHub repo address in form "username/repo-name"
///
void PGirlDown::downloadRepo(QString shortAddr)
{
    const QString repoFmt("https://api.github.com/repos/%1/contents/");
    QString repoAddr = repoFmt.arg(shortAddr);
    httpGet(repoAddr, &PGirlDown::recvRepoDir);
    emit repoDownloadProgressed(0);
}

void PGirlDown::cancelDownload()
{
    httpAbortAll();
}

void PGirlDown::onNetReply(QNetworkReply *reply)
{
    ReplyEraseGuard guard(*this, reply);
    (this->*mReplies[reply])(reply);
}

void PGirlDown::httpGet(QUrl url, void (PGirlDown::*recv)(QNetworkReply *))
{
    QNetworkRequest request;
    request.setUrl(url);
    request.setHeader(QNetworkRequest::UserAgentHeader, "rolevax");
    mReplies.insert(mNet.get(request), recv);
}

void PGirlDown::httpAbortAll()
{
    for (QNetworkReply *reply : mReplies.keys())
        reply->abort();

    mReplies.clear();
}

QJsonDocument PGirlDown::replyToJson(QNetworkReply *reply)
{
    QString str = reply->readAll();
    return QJsonDocument::fromJson(str.toUtf8());
}

void PGirlDown::recvRepoList(QNetworkReply *reply)
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

void PGirlDown::recvRepoDir(QNetworkReply *reply)
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
        httpGet(addr, &PGirlDown::recvFile);
}

void PGirlDown::recvFile(QNetworkReply *reply)
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

    if (mReplies.size() == 1) { // finished the last file
        QFile jsonFile(PGlobal::editPath("meta.json", dirSuffix));
        jsonFile.open(QIODevice::ReadWrite | QIODevice::Text);

        auto doc = QJsonDocument::fromJson(jsonFile.readAll());
        QJsonObject meta;
        if (doc.isObject())
            meta = doc.object();

        meta["updated_at"] = QDateTime::currentDateTimeUtc().toString(Qt::ISODate);

        jsonFile.write(QJsonDocument(meta).toJson());
    }

    emit repoDownloadProgressed(percent);
}

PGirlDown::ReplyEraseGuard::ReplyEraseGuard(PGirlDown &editor, QNetworkReply *reply)
    : mGirlDown(editor)
    , mReply(reply)
{
}

PGirlDown::ReplyEraseGuard::~ReplyEraseGuard()
{
    mGirlDown.mReplies.remove(mReply);
    mReply->deleteLater();
}
