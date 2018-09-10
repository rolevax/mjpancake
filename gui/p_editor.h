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
    Q_INVOKABLE QString getName(QString path);
    Q_INVOKABLE QString getLuaCode(QString path);
    Q_INVOKABLE QImage getPhoto(QString path);
    Q_INVOKABLE void saveJson(QString path, QString name, QUrl photoUrl);
    Q_INVOKABLE void saveLuaCode(QString path, QString luaCode);
    Q_INVOKABLE void remove(QString path);
    Q_INVOKABLE void editLuaExternally(QString path);

signals:

private slots:

private:
    QJsonObject getGirlJson(QString path);

private:
    static PEditor *sInstance;
    PLuaHighlighter mLuaHighlighter;
};



QObject *pEditorSingletonProvider(QQmlEngine *engine, QJSEngine *scriptEngine);



#endif // P_EDITOR_H
