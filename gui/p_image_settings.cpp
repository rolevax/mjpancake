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

void PImageSettings::receiveImagePath(QString path)
{
    emit imageUrlReceived(QUrl::fromLocalFile(path));
}
