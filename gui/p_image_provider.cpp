#include "p_image_provider.h"
#include "p_global.h"

#include <QtGlobal>
#include <QDateTime>
#include <iostream> // debug

PImageProvider::PImageProvider()
    : QQuickImageProvider(QQuickImageProvider::Image)
{
    qsrand(QDateTime::currentDateTime().toMSecsSinceEpoch());
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
        image = QImage(PGlobal::photoPath() + "/" + parts[1]);
        if (image.isNull()) { // fallback to placeholder photo
            int r = 16 + qrand() % 127;
            int g = 16 + qrand() % 127;
            int b = 16 + qrand() % 127;
            QColor color(r, g, b, 64);
            QPixmap pixmap(1, 1);
            pixmap.fill(color);
            image = pixmap.toImage();
        }
    }

    return image;
}
