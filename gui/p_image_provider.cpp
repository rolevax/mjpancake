#include "p_image_provider.h"
#include "p_global.h"

#include <iostream> // debug

PImageProvider::PImageProvider()
    : QQuickImageProvider(QQuickImageProvider::Image)
{
}

QImage PImageProvider::requestImage(const QString &id, QSize *size,
                                    const QSize &requestedSize)
{
    (void) size; (void) requestedSize;

    QImage image;

    if (id == "background") {
        image = QImage(PGlobal::configPath() + "/background");
        if (image.isNull())
            image = QImage(":/pic/default_bg.png");
    } else if (id.startsWith("photo/")) {
        QStringList parts = id.split('/');

        if (parts[2] == "0") // photo/710111/0 -> custom, "user/photos/710111"
            image = QImage(PGlobal::photoPath() + "/" + parts[1]);
        else // photo/710111/1 -> built-in, ":/pic/girl/710111/1"
            image = QImage(":/pic/girl/" + parts[1] + "/" + parts[2]);

        if (image.isNull()) // fallback to placeholder photo
            image = QImage(":/pic/girl/default.png");
    }

    return image;
}
