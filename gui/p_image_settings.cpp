#include "gui/p_image_settings.h"

#include <QFile>
#include <QDir>
#include <QJsonArray>

#include <iostream>
#include <QDebug>

#ifdef Q_OS_ANDROID // ImagePickerReceiver

#include <QtAndroid>

void ImagePickReceiver::handleActivityResult(int requestCode, int resultCode,
                                             const QAndroidJniObject & data) {
    (void) requestCode;
    if (resultCode == -1) { // OK
        QAndroidJniObject imageUri = data.callObjectMethod(
                    "getData",
                    "()Landroid/net/Uri;");
        QAndroidJniObject imagePath = QAndroidJniObject::callStaticObjectMethod(
                    "rolevax/sakilogy/ImagePickerActivity",
                    "getPath",
                    "(Landroid/net/Uri;)Ljava/lang/String;",
                    imageUri.object<jobject>());

        switch (requestCode) {
        case REQ_BACKGROUND:
            mPImageSettings.setBackground(imagePath.toString());
            break;
        case REQ_GIRL_PHOTO:
            mPImageSettings.setPhoto(mGirlId, imagePath.toString());
            break;
        default:
            break;
        }
    }
}

void ImagePickReceiver::setGirlId(const QString &girlId)
{
    mGirlId = girlId;
}

#endif // ImagePickerReceiver


PImageSettings::PImageSettings(QObject *parent)
    : QObject(parent)
#ifdef Q_OS_ANDROID
    , mImagePickReceiver(*this)
#endif
{
}

void PImageSettings::setBackground(QString path)
{
    QDir().mkpath(QString("user"));
    static const char *bgPath = "user/background";
    if (QFile::exists(bgPath))
        QFile::remove(bgPath);

    QFile::copy(path, bgPath);

    emit backgroundCopied();
}

void PImageSettings::setBackgroundByAndroidGallery()
{
#ifdef Q_OS_ANDROID
    QAndroidJniObject intent = QAndroidJniObject::callStaticObjectMethod(
                "rolevax/sakilogy/ImagePickerActivity",
                "createChoosePhotoIntent",
                "()Landroid/content/Intent;" );
    QtAndroid::startActivity(intent, ImagePickReceiver::REQ_BACKGROUND, &mImagePickReceiver);
#endif
}

void PImageSettings::setPhoto(QString girlId, QString path)
{
    QDir().mkpath(QString("user/photos"));

    QString photoPath("user/photos/" + girlId);
    if (QFile::exists(photoPath))
        QFile::remove(photoPath);

    QFile::copy(path, photoPath);

    emit photoCopied();
}

void PImageSettings::setPhotoByAndroidGallery(QString girlId)
{
#ifdef Q_OS_ANDROID
    QAndroidJniObject intent = QAndroidJniObject::callStaticObjectMethod(
                "rolevax/sakilogy/ImagePickerActivity",
                "createChoosePhotoIntent",
                "()Landroid/content/Intent;" );
    mImagePickReceiver.setGirlId(girlId);
    QtAndroid::startActivity(intent, ImagePickReceiver::REQ_GIRL_PHOTO, &mImagePickReceiver);
#endif
}




