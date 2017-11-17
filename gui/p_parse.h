#ifndef P_PARSE_H
#define P_PARSE_H

#include <QObject>
#include <QVariantList>



class PParse : public QObject
{
    Q_OBJECT
public:
    explicit PParse(QObject *parent = nullptr);

    Q_INVOKABLE void parse(const QStringList &tiles);

signals:
    void parsed(const QStringList &results);
};



#endif // P_PARSE_H


