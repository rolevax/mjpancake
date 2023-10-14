#include "p_image_provider.h"
#include "p_global.h"
#include "p_editor.h"

#include <QtGlobal>
#include <QDateTime>


PImageProvider::PImageProvider()
    : QQuickImageProvider(QQuickImageProvider::Image)
{
    mRand.seed(QDateTime::currentDateTime().toMSecsSinceEpoch());
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
        // id format photo/{girl-id}/{girl-path}
        // e.g. photo/710111/
        // e.g. photo/1/my_custom_char
        QStringList parts = id.split('/');
        QString girlId = parts[1];
        QString girlPath = parts[2];
        for (int i = 3; i < parts.size(); i++)
            girlPath += "/" + parts[i];

        if (girlId == "1") // Lua custom
            image = PEditor::instance().getPhoto(girlPath);
        else // official built-in
            image = QImage(PGlobal::photoPath() + "/" + girlId);

        if (image.isNull()) { // fallback to placeholder photo
            int r = 16 + mRand.generate() % 127;
            int g = 16 + mRand.generate() % 127;
            int b = 16 + mRand.generate() % 127;
            QColor color(r, g, b, 64);
            QPixmap pixmap(1, 1);
            pixmap.fill(color);
            image = pixmap.toImage();
        }
    }

    return image;
}
