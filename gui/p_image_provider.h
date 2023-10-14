#ifndef P_IMAGE_PROVIDER_H
#define P_IMAGE_PROVIDER_H

#include <QRandomGenerator>
#include <QQuickImageProvider>

class PImageProvider : public QQuickImageProvider
{
public:
    PImageProvider();

    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize);

private:
    QRandomGenerator mRand;
};

#endif // P_IMAGE_PROVIDER_H
