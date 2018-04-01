#include "p_image_settings.h"
#include "p_global.h"

#include <QFile>
#include <QJsonArray>

#include <iostream>
#include <QDebug>

#ifdef Q_OS_ANDROID // ImagePickerReceiver

#include <QtAndroid>

void ImagePickReceiver::handleActivityResult(int requestCode, int resultCode,
                                             const QAndroidJniObject &data) {
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
            PGlobal::instance().setBackground(imagePath.toString());
            break;
        case REQ_GIRL_PHOTO:
            PGlobal::instance().setPhoto(mGirlId, imagePath.toString());
            break;
        case REQ_GET_IMAGE_PATH:
            mPImageSettings.receiveImagePath(imagePath.toString());
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

void PImageSettings::getImagePathByAndroidGallery()
{
#ifdef Q_OS_ANDROID
    QAndroidJniObject intent = QAndroidJniObject::callStaticObjectMethod(
            "rolevax/sakilogy/ImagePickerActivity",
            "createChoosePhotoIntent",
            "()Landroid/content/Intent;");
    QtAndroid::startActivity(intent, ImagePickReceiver::REQ_GET_IMAGE_PATH, &mImagePickReceiver);
#endif
}

void PImageSettings::setBackgroundByAndroidGallery()
{
#ifdef Q_OS_ANDROID
    QAndroidJniObject intent = QAndroidJniObject::callStaticObjectMethod(
            "rolevax/sakilogy/ImagePickerActivity",
            "createChoosePhotoIntent",
            "()Landroid/content/Intent;");
    QtAndroid::startActivity(intent, ImagePickReceiver::REQ_BACKGROUND, &mImagePickReceiver);
#endif
}

void PImageSettings::setPhotoByAndroidGallery(QString girlId)
{
#ifdef Q_OS_ANDROID
    QAndroidJniObject intent = QAndroidJniObject::callStaticObjectMethod(
            "rolevax/sakilogy/ImagePickerActivity",
            "createChoosePhotoIntent",
            "()Landroid/content/Intent;");
    mImagePickReceiver.setGirlId(girlId);
    QtAndroid::startActivity(intent, ImagePickReceiver::REQ_GIRL_PHOTO, &mImagePickReceiver);
#else
    (void) girlId;
#endif
}

void PImageSettings::receiveImagePath(QString path)
{
    emit imagePathReceived(path);
}
