#ifndef P_EFF_H
#define P_EFF_H

#include <QObject>
#include <QVariantList>



class PEff : public QObject
{
    Q_OBJECT
public:
    explicit PEff(QObject *parent = nullptr);

    Q_INVOKABLE void deal();

signals:
    void dealt(const QVariantList &init);

public slots:
};



#endif // P_EFF_H


