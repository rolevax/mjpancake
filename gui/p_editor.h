#ifndef P_EDITOR_H
#define P_EDITOR_H

#include <QObject>
#include <QQmlEngine>
#include <QVariantList>
#include <QVariantMap>
#include <QSyntaxHighlighter>
#include <QTextCharFormat>
#include <QRegularExpression>
#include <QQuickTextDocument>
#include <QNetworkAccessManager>



class QTextDocument;

class PLuaHighlighter : public QSyntaxHighlighter
{
    Q_OBJECT

public:
    PLuaHighlighter(QTextDocument *parent = nullptr);

protected:
    void highlightBlock(const QString &text) override;

private:
    struct HighlightingRule
    {
        QRegularExpression pattern;
        QTextCharFormat format;
    };

    QVector<HighlightingRule> mRules;

    QRegularExpression mCommentStart;
    QRegularExpression mCommentEnd;

    QTextCharFormat mKeywordFormat;
    QTextCharFormat mLineCommentFormat;
    QTextCharFormat mBlockCommentFormat;
    QTextCharFormat mStringFormat;
};



class PEditor : public QObject
{
    Q_OBJECT

public:
    explicit PEditor(QObject *parent = nullptr);

    static PEditor &instance();

    Q_INVOKABLE void setLuaHighlighter(QQuickTextDocument *qtd);
    Q_INVOKABLE QStringList ls();
    Q_INVOKABLE QVariantList listCachedGirls();
    Q_INVOKABLE QString getName(QString path);
    Q_INVOKABLE QString getLuaCode(QString path);
    Q_INVOKABLE QImage getPhoto(QString path);
    Q_INVOKABLE void saveJson(QString path, QString name, QUrl photoUrl);
    Q_INVOKABLE void saveLuaCode(QString path, QString luaCode);
    Q_INVOKABLE void remove(QString path);
    Q_INVOKABLE void editLuaExternally(QString path);

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
        explicit ReplyEraseGuard(PEditor &editor, QNetworkReply *reply);
        ~ReplyEraseGuard();

    private:
        PEditor &mEditor;
        QNetworkReply *mReply;
    };

    QJsonObject getGirlJson(QString path);
    void httpGet(QUrl url, void (PEditor::*recv)(QNetworkReply *));
    void httpAbortAll();
    QJsonDocument replyToJson(QNetworkReply *reply);
    void recvRepoList(QNetworkReply *reply);
    void recvRepoDir(QNetworkReply *reply);
    void recvFile(QNetworkReply *reply);

private:
    static PEditor *sInstance;
    PLuaHighlighter mLuaHighlighter;
    QNetworkAccessManager mNet;
    QHash<QNetworkReply *, void (PEditor::*)(QNetworkReply *)> mReplies;
    int mTotalFilesToDownload;
};



QObject *pEditorSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine);



#endif // P_EDITOR_H
