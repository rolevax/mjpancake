#ifndef P_IMAGE_SETTINGS_H
#define P_IMAGE_SETTINGS_H

#include <QObject>
#include <QUrl>



#ifdef Q_OS_ANDROID
#include <QAndroidActivityResultReceiver>

class PImageSettings;

class ImagePickReceiver : public QAndroidActivityResultReceiver
{
public:
    static const int REQ_GET_IMAGE_PATH = 103;

    ImagePickReceiver(PImageSettings &pSettings) : mPImageSettings(pSettings) {}
    void handleActivityResult(int requestCode, int resultCode,
                              const QAndroidJniObject &data);
    void setGirlId(const QString &girlId);

private:
    PImageSettings &mPImageSettings;
    QString mGirlId;
};

#endif



class PImageSettings : public QObject
{
    Q_OBJECT

public:
    explicit PImageSettings(QObject *parent = 0);

    Q_INVOKABLE void getImagePathByAndroidGallery();

    void receiveImagePath(QString path);

signals:
    void imageUrlReceived(QUrl fileUrl);

public slots:

private:

private:
#ifdef Q_OS_ANDROID
    ImagePickReceiver mImagePickReceiver;
#endif
};

#endif // P_IMAGE_SETTINGS_H
