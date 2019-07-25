#include "p_girl_down.h"
#include "p_global.h"

#include <QDateTime>
#include <QDir>
#include <QJsonDocument>
#include <QJsonArray>
#include <QNetworkReply>
#include <QRegularExpression>



using StrConst = const char * const;
static StrConst URL_REPO_DIR_FMT = "https://api.github.com/repos/%1/contents/";
static StrConst QUERY_ISSUE = "query{repository(owner:rolevax,name:libsaki){issue(number: 51){author{login} comments(first:100){edges{node{bodyText reactions(first:100,content:ROCKET){edges{node{user{login}}}}}}}}}}";
static StrConst QUERY_REPO_FMT = "query{repository(owner:\"%1\",name:\"%2\"){updatedAt stargazers{totalCount}}}";
static StrConst AUTHORIZATION = "bearer 4b55657f9087494b42e04749b1cf9a18c9d4c432"; // from an empty account

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
    mTask = nullptr;
    mTask = std::make_unique<TaskFetchRepoList>(*this);
}

///
/// \brief Starat to download a girl repo, discard all current downloads
/// \param shortAddr GitHub repo address in form "username/repo-name"
///
void PGirlDown::downloadRepo(QString shortAddr, QString name)
{
    mTask = nullptr;
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

void PGirlDown::graphQlQuery(const QString &query, const QString &comment)
{
    QNetworkRequest request;
    request.setUrl(QUrl("https://api.github.com/graphql"));
    request.setHeader(QNetworkRequest::UserAgentHeader, "rolevax");
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setRawHeader("Authorization", AUTHORIZATION);
    request.setRawHeader("X-Pancake-Comment", comment.toUtf8());

    QJsonObject queryJson;
    queryJson["query"] = query;
    mReplies.insert(mNet.post(request, QJsonDocument(queryJson).toJson(QJsonDocument::Compact)));
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
    mGirlDown.graphQlQuery(QUERY_ISSUE, "issue");
}

bool PGirlDown::TaskFetchRepoList::recv(QNetworkReply *reply)
{
    if (reply->error() != QNetworkReply::NoError) {
        qDebug() << reply->error();
        notifyGui();
        return false;
    }

    QJsonDocument replyDoc = replyToJson(reply);
    QVariantMap replyRoot = replyDoc.object().toVariantMap();

    QString comment = reply->request().rawHeader("X-Pancake-Comment");
    if (comment == "issue")
        return recvRepoList(replyRoot);

    return recvRepoMetaInfo(comment, replyRoot);
}

bool PGirlDown::TaskFetchRepoList::recvRepoList(QVariantMap replyRoot)
{
    QVariantMap issue = replyRoot["data"].toMap()["repository"].toMap()["issue"].toMap();
    QString author = issue["author"].toMap()["login"].toString();

    QVariantList comments = issue["comments"].toMap()["edges"].toList();

    for (const QVariant &commentVar : comments) {
        QVariantMap comment = commentVar.toMap()["node"].toMap();

        QString bodyStr = comment["bodyText"].toString();
        QJsonDocument bodyDoc = QJsonDocument::fromJson(bodyStr.toUtf8());

        QVariantList reactions = comment["reactions"].toMap()["edges"].toList();
        auto it = std::find_if(reactions.begin(), reactions.end(), [&author](const QVariant &v) {
            QVariantMap reaction = v.toMap()["node"].toMap();
            QString actor = reaction["user"].toMap()["login"].toString();
            return actor == author;
        });

        bool authorReact = it != reactions.end();
        qDebug() << "author react " << authorReact; // TODO FUCK use this

        if (bodyDoc.isObject()) {
            QJsonObject bodyObj = bodyDoc.object();
            initRepo(bodyObj);
            mRepos << bodyObj.toVariantMap();
        }
    }

    notifyGui();
    return true;
}

bool PGirlDown::TaskFetchRepoList::recvRepoMetaInfo(const QString &shortAddr, QVariantMap replyRoot)
{
    QVariantMap &localRepo = mRepos[mRepoIndices[shortAddr]];
    mRepoIndices.remove(shortAddr);

    if (replyRoot.contains("errors")) {
        localRepo["status"] = "REMOTE_TAN90";
    } else {
        QVariantMap remoteRepo = replyRoot["data"].toMap()["repository"].toMap();
        QDateTime remoteDate = QDateTime::fromString(remoteRepo["updatedAt"].toString(), Qt::ISODate);
        if (remoteDate.isNull())
            localRepo["status"] = "REMOTE_DATE_ERROR";

        QDateTime localDate = QDateTime::fromString(localRepo["updated_at"].toString(), Qt::ISODate);
        if (!localDate.isNull()) { // not first time download
            if (remoteDate > localDate) {
                localRepo["status"] = "CAN_UPDATE";
                localRepo["updatable"] = true;
            } else {
                localRepo["status"] = "LATEST";
            }
        }

        localRepo["stars"] = remoteRepo["stargazers"].toMap()["totalCount"].toInt();
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
    repo["stars"] = -1;
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
    }

    mRepoIndices.insert(shortAddr, mRepos.size());
    QStringList split = shortAddr.split("/");
    QString query = QString(QUERY_REPO_FMT).arg(split[0], split[1]);
    mGirlDown.graphQlQuery(query, shortAddr);
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
