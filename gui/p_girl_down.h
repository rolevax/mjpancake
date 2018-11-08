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
    ~PGirlDown() override;

    Q_INVOKABLE void fetchSignedRepos();
    Q_INVOKABLE void downloadRepo(QString shortAddr);
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
        bool recvRepoList(QNetworkReply *reply);
        bool recvRepoMetaInfo(QNetworkReply *reply);
        void notifyGui();
        void initRepo(QJsonObject &repo);

    private:
        QList<QVariantMap> mRepos;
        QMap<QString, int> mRepoIndices;
    };

    class TaskDownloadGirls : public Task
    {
    public:
        explicit TaskDownloadGirls(PGirlDown &girlDown, const QString &shortAddr);
        bool recv(QNetworkReply *reply) override;

    private:
        bool recvRepoDir(QNetworkReply *reply);
        bool recvFile(QNetworkReply *reply);
        void stampUpdateTime();

    private:
        QString mShortAddr;
        bool mGotDir = false;
        int mTotalFiles;
        int mCompletedFiles = 0;
    };

    void httpGet(QUrl url);
    void httpAbortAll();

private:
    QNetworkAccessManager mNet;
    std::unique_ptr<Task> mTask;
    QSet<QNetworkReply *> mReplies;
};



#endif // P_GIRL_DOWN_H
