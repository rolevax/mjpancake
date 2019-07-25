#ifndef P_GIRL_DOWN_H
#define P_GIRL_DOWN_H

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QNetworkAccessManager>
#include <QSet>

#include <memory>



class PGirlDown : public QObject
{
    Q_OBJECT

public:
    explicit PGirlDown(QObject *parent = nullptr);
    PGirlDown(const PGirlDown &copy) = delete;
    PGirlDown(PGirlDown &&move) = delete;
    PGirlDown &operator=(const PGirlDown &copy) = delete;
    PGirlDown &operator=(PGirlDown &&move) = delete;
    ~PGirlDown() override;

    Q_INVOKABLE void fetchSignedRepos();
    Q_INVOKABLE void downloadRepo(QString shortAddr, QString name);
    Q_INVOKABLE void cancelDownload();

signals:
    void signedReposReplied(const QVariantList &repos);
    void repoDownloadProgressed(int percent);

private slots:
    void onNetReply(QNetworkReply *reply);

private:
    class Task
    {
    public:
        explicit Task(PGirlDown &girlDown);
        Task(const Task &copy) = delete;
        Task(Task &&move) = delete;
        Task &operator=(const Task &copy) = delete;
        Task &operator=(Task &&move) = delete;
        virtual ~Task() = default;

        virtual bool recv(QNetworkReply *reply) = 0;

    protected:
        PGirlDown &mGirlDown;
    };

    class TaskFetchRepoList : public Task
    {
    public:
        explicit TaskFetchRepoList(PGirlDown &girlDown);
        bool recv(QNetworkReply *reply) override;

    private:
        bool recvRepoList(QVariantMap replyRoot);
        bool recvRepoMetaInfo(const QString &shortAddr, QVariantMap replyRoot);
        void notifyGui();
        void initRepo(QJsonObject &repo);

    private:
        QList<QVariantMap> mRepos;
        QMap<QString, int> mRepoIndices;
    };

    class TaskDownloadGirls : public Task
    {
    public:
        explicit TaskDownloadGirls(PGirlDown &girlDown, QString shortAddr, QString name);
        bool recv(QNetworkReply *reply) override;

    private:
        bool recvRepoDir(QNetworkReply *reply);
        bool recvFile(QNetworkReply *reply);
        void lastStamp();

    private:
        QString mShortAddr;
        QString mPackageName;
        int mTotalFiles;
        int mCompletedFiles = 0;
        bool mGotDir = false;
    };

    void httpGet(const QUrl &url);
    void graphQlQuery(const QString &query, const QString &comment);
    void httpAbortAll();

private:
    QNetworkAccessManager mNet;
    std::unique_ptr<Task> mTask;
    QSet<QNetworkReply *> mReplies;
};



#endif // P_GIRL_DOWN_H
