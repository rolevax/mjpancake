#ifndef P_GIRL_DOWN_H
#define P_GIRL_DOWN_H

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QNetworkAccessManager>



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
    class ReplyEraseGuard
    {
    public:
        explicit ReplyEraseGuard(PGirlDown &editor, QNetworkReply *reply);
        ~ReplyEraseGuard();

    private:
        PGirlDown &mGirlDown;
        QNetworkReply *mReply;
    };

    void httpGet(QUrl url, void (PGirlDown::*recv)(QNetworkReply *));
    void httpAbortAll();
    QJsonDocument replyToJson(QNetworkReply *reply);
    void recvRepoList(QNetworkReply *reply);
    void recvRepoDir(QNetworkReply *reply);
    void recvFile(QNetworkReply *reply);

private:
    QNetworkAccessManager mNet;
    QHash<QNetworkReply *, void (PGirlDown::*)(QNetworkReply *)> mReplies;
    int mTotalFilesToDownload;
};



#endif // P_GIRL_DOWN_H
