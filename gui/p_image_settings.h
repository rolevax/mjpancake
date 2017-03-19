#ifndef P_IMAGE_SETTINGS_H
#define P_IMAGE_SETTINGS_H

#include <QObject>

#ifdef Q_OS_ANDROID
#include <QAndroidActivityResultReceiver>

class PImageSettings;

class ImagePickReceiver : public QAndroidActivityResultReceiver {
public:
    static const int REQ_BACKGROUND = 101;
    static const int REQ_GIRL_PHOTO = 102;

    ImagePickReceiver(PImageSettings &pSettings) : mPImageSettings(pSettings) { }
    void handleActivityResult(int requestCode, int resultCode,
                              const QAndroidJniObject & data);
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

    Q_INVOKABLE void setBackground(QString path);
    Q_INVOKABLE void setBackgroundByAndroidGallery();

    Q_INVOKABLE void setPhoto(QString girlId, QString path);
    Q_INVOKABLE void setPhotoByAndroidGallery(QString girlId);

signals:
    void backgroundCopied();
    void photoCopied();

public slots:


private:

private:
#ifdef Q_OS_ANDROID
    ImagePickReceiver mImagePickReceiver;
#endif
};

#endif // P_IMAGE_SETTINGS_H
