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
    Q_INVOKABLE QString getName(const QString &path);
    Q_INVOKABLE QString getLuaCode(const QString &path);
    Q_INVOKABLE QImage getPhoto(const QString &path);
    Q_INVOKABLE void saveJson(const QString &path, const QString &name, const QUrl &photoUrl);
    Q_INVOKABLE void saveLuaCode(const QString &path, const QString &luaCode);
    Q_INVOKABLE void remove(const QString &path);
    Q_INVOKABLE void editLuaExternally(const QString &path);

private:
    QJsonObject getGirlJson(const QString &path);

private:
    static PEditor *sInstance;
    PLuaHighlighter mLuaHighlighter;
};



QObject *pEditorSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine);



#endif // P_EDITOR_H
