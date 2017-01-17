#include "gui/p_image_provider.h"

#include <iostream> // debug

PImageProvider::PImageProvider()
    : QQuickImageProvider(QQuickImageProvider::Image)
{
}

QImage PImageProvider::requestImage(const QString &id, QSize *size,
                                    const QSize &requestedSize)
{
    (void) size; (void) requestedSize;

    QImage image(id);
    if (image.isNull())
        image = QImage(":/pic/default_bg.png");
    return image;
}
