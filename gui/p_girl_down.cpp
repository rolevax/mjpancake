#include "p_girl_down.h"
#include "p_global.h"

#include <QDir>
#include <QJsonDocument>
#include <QJsonArray>
#include <QNetworkReply>
#include <QRegularExpression>



using StrConst = const char * const;
static StrConst URL_ISSUE_51 = "https://api.github.com/repos/rolevax/libsaki/issues/51/comments";
static StrConst URL_REPO_DIR_FMT = "https://api.github.com/repos/%1/contents/";
static StrConst URL_REPO_FMT = "https://api.github.com/repos/%1";

QJsonDocument replyToJson(QNetworkReply *reply)
{
    QString str = reply->readAll();
    return QJsonDocument::fromJson(str.toUtf8());
}

QJsonObject openCachedMeta(const QString &dirSuffix)
{
    QJsonObject meta;

    QFile jsonFile(PGlobal::editPath("meta.json", dirSuffix));
    bool ok = jsonFile.open(QIODevice::ReadOnly | QIODevice::Text);
    if (ok) {
        auto doc = QJsonDocument::fromJson(jsonFile.readAll());
        if (doc.isObject())
            meta = doc.object();
    }

    return meta;
}

void writeCachedMeta(const QJsonObject &meta, const QString &dirSuffix)
{
    QFile jsonFile(PGlobal::editPath("meta.json", dirSuffix));
    jsonFile.open(QIODevice::WriteOnly | QIODevice::Text);
    jsonFile.write(QJsonDocument(meta).toJson());
}

int makeNeg(int n)
{
    return n > 0 ? -n : (n == 0 ? -1 : n);
}



PGirlDown::PGirlDown(QObject *parent)
    : QObject(parent)
{
    connect(&mNet, &QNetworkAccessManager::finished,
            this, &PGirlDown::onNetReply,
            Qt::QueuedConnection);
}

PGirlDown::~PGirlDown()
{
    httpAbortAll();
}

void PGirlDown::fetchSignedRepos()
{
    mTask = std::make_unique<TaskFetchRepoList>(*this);
}

///
/// \brief Starat to download a girl repo, discard all current downloads
/// \param shortAddr GitHub repo address in form "username/repo-name"
///
void PGirlDown::downloadRepo(QString shortAddr, QString name)
{
    mTask = std::make_unique<TaskDownloadGirls>(*this, shortAddr, name);
}

void PGirlDown::cancelDownload()
{
    mTask = nullptr;
    httpAbortAll();
}

void PGirlDown::onNetReply(QNetworkReply *reply)
{
    mReplies.remove(reply);
    reply->deleteLater();

    if (mTask != nullptr) {
        bool working = mTask->recv(reply);
        if (!working) {
            mTask = nullptr;
            httpAbortAll();
        }
    }
}

void PGirlDown::httpGet(const QUrl &url)
{
    QNetworkRequest request;
    request.setUrl(url);
    request.setHeader(QNetworkRequest::UserAgentHeader, "rolevax");
    mReplies.insert(mNet.get(request));
}

void PGirlDown::httpAbortAll()
{
    for (QNetworkReply *reply : mReplies)
        reply->abort();

    mReplies.clear();
}

PGirlDown::Task::Task(PGirlDown &girlDown)
    : mGirlDown(girlDown)
{
}

PGirlDown::TaskFetchRepoList::TaskFetchRepoList(PGirlDown &girlDown)
    : Task(girlDown)
{
    mGirlDown.httpGet(QUrl(URL_ISSUE_51));
}

bool PGirlDown::TaskFetchRepoList::recv(QNetworkReply *reply)
{
    QString reqUrl = reply->request().url().toString();
    return reqUrl == URL_ISSUE_51 ? recvRepoList(reply)
                                  : recvRepoMetaInfo(reply);
}

bool PGirlDown::TaskFetchRepoList::recvRepoList(QNetworkReply *reply)
{
    if (reply->error() != QNetworkReply::NoError) {
        notifyGui();
        return false;
    }

    QJsonDocument replyDoc = replyToJson(reply);
    QVariantList issues = replyDoc.array().toVariantList();

    for (const QVariant &issueVar : issues) {
        QVariantMap issue = issueVar.toMap();
        QString bodyStr = issue["body"].toString();
        QJsonDocument bodyDoc = QJsonDocument::fromJson(bodyStr.toUtf8());
        if (bodyDoc.isObject()) {
            QJsonObject bodyObj = bodyDoc.object();
            initRepo(bodyObj);
            mRepos << bodyObj.toVariantMap();
        }
    }

    notifyGui();
    return true;
}

bool PGirlDown::TaskFetchRepoList::recvRepoMetaInfo(QNetworkReply *reply)
{
    QStringList split = reply->request().url().toString().split("/");
    QString shortAddr = split[split.size() - 2] + "/" + split.back();
    QVariantMap &repo = mRepos[mRepoIndices[shortAddr]];
    mRepoIndices.remove(shortAddr);

    if (reply->error() != QNetworkReply::NoError) {
        repo["status"] = "REMOTE_TAN90";
    } else {
        QJsonDocument replyDoc = replyToJson(reply);
        QJsonObject repoInfo = replyDoc.object();

        QDateTime remoteDate = QDateTime::fromString(repoInfo["updated_at"].toString(), Qt::ISODate);
        if (remoteDate.isNull())
            repo["status"] = "REMOTE_DATE_ERROR";

        QDateTime localDate = QDateTime::fromString(repo["updated_at"].toString(), Qt::ISODate);
        if (localDate.isNull() || remoteDate > localDate) {
            repo["status"] = "CAN_UPDATE";
            repo["updatable"] = true;
        } else {
            repo["status"] = "LATEST";
        }
    }

    notifyGui();
    return !mRepoIndices.empty();
}

void PGirlDown::TaskFetchRepoList::notifyGui()
{
    QVariantList varList;
    for (const auto &map : mRepos)
        varList << map;

    emit mGirlDown.signedReposReplied(varList);
}

void PGirlDown::TaskFetchRepoList::initRepo(QJsonObject &repo)
{
    QString shortAddr = repo["repo"].toString();
    QRegularExpression regex("^[A-Za-z0-9_\\-]+/[A-Za-z0-9_\\-]+$");
    if (!regex.match(shortAddr).hasMatch()) {
        repo["status"] = "INVALID_NAME";
        repo["updatable"] = false;
        repo["deletable"] = false;
        return;
    }

    QJsonObject meta = openCachedMeta("github.com/" + shortAddr);
    QString dateStr = meta["updated_at"].toString();
    QDateTime date = QDateTime::fromString(dateStr, Qt::ISODate);
    if (date.isNull()) {
        repo["status"] = "CAN_INIT";
        repo["updatable"] = true;
        repo["deletable"] = false;
    } else {
        repo["status"] = "CALCULATING";
        repo["updatable"] = false;
        repo["deletable"] = true;
        repo["updated_at"] = dateStr;
        mRepoIndices.insert(shortAddr, mRepos.size());
        QString url = QString(URL_REPO_FMT).arg(shortAddr);
        mGirlDown.httpGet(url);
    }
}

PGirlDown::TaskDownloadGirls::TaskDownloadGirls(PGirlDown &girlDown, QString shortAddr, QString name)
    : Task(girlDown)
    , mShortAddr(std::move(shortAddr))
    , mPackageName(std::move(name))
    , mTotalFiles(0)
{
    QString repoAddr = QString(URL_REPO_DIR_FMT).arg(mShortAddr);
    mGirlDown.httpGet(repoAddr);
    emit mGirlDown.repoDownloadProgressed(0);
}

bool PGirlDown::TaskDownloadGirls::recv(QNetworkReply *reply)
{
    if (int error = reply->error(); error != QNetworkReply::NoError) {
        emit mGirlDown.repoDownloadProgressed(makeNeg(error));
        return false;
    }

    if (!mGotDir) {
        mGotDir = true;
        return recvRepoDir(reply);
    }

    return recvFile(reply);
}

bool PGirlDown::TaskDownloadGirls::recvRepoDir(QNetworkReply *reply)
{
    emit mGirlDown.repoDownloadProgressed(1);
    QJsonDocument replyDoc = replyToJson(reply);
    if (!replyDoc.isArray()) {
        emit mGirlDown.repoDownloadProgressed(-20001);
        return false;
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

    mTotalFiles = targets.size();
    if (mTotalFiles == 0) {
        lastStamp();
        emit mGirlDown.repoDownloadProgressed(100);
        return false;
    }

    for (const auto &addr : targets)
        mGirlDown.httpGet(addr);

    return true;
}

bool PGirlDown::TaskDownloadGirls::recvFile(QNetworkReply *reply)
{
    // uri should be in format ".../user/repo/branch/filename"
    QStringList split = reply->request().url().toString().split("/");
    const QString &filename = split.at(split.size() - 1);
    const QString &repo = split.at(split.size() - 3);
    const QString &user = split.at(split.size() - 4);
    if (mShortAddr != user + "/" + repo) {
        emit mGirlDown.repoDownloadProgressed(-20002);
        return false;
    }

    QString dirSuffix = "github.com/" + mShortAddr;
    QString content = reply->readAll();
    QFile file(PGlobal::editPath(filename, dirSuffix));
    file.open(QIODevice::WriteOnly | QIODevice::Text);
    file.write(content.toUtf8());
    mCompletedFiles++;

    if (mCompletedFiles == mTotalFiles) {
        lastStamp();
        emit mGirlDown.repoDownloadProgressed(100);
        return false;
    }

    double rate = static_cast<double>(mCompletedFiles) / mTotalFiles;
    int percent = std::min(static_cast<int>(rate * 100), 99);
    emit mGirlDown.repoDownloadProgressed(percent);
    return true;
}

void PGirlDown::TaskDownloadGirls::lastStamp()
{
    QString dirSuffix = "github.com/" + mShortAddr;
    QJsonObject meta = openCachedMeta(dirSuffix);
    meta["updated_at"] = QDateTime::currentDateTimeUtc().toString(Qt::ISODate);
    meta["name"] = mPackageName;
    writeCachedMeta(meta, dirSuffix);
}
