#ifndef PIMAGEPROVIDER_H
#define PIMAGEPROVIDER_H

#include <QQuickImageProvider>

class PImageProvider : public QQuickImageProvider
{
public:
    PImageProvider();

    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);
};

#endif // PIMAGEPROVIDER_H
