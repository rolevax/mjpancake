#ifndef P_IMAGE_SETTINGS_H
#define P_IMAGE_SETTINGS_H

#include <QObject>

#ifdef Q_OS_ANDROID
#include <QAndroidActivityResultReceiver>

class PImageSettings;

class ImagePickReceiver : public QAndroidActivityResultReceiver {
public:
    ImagePickReceiver(PImageSettings &pSettings) : mPImageSettings(pSettings) { }
    void handleActivityResult(int requestCode, int resultCode,
                              const QAndroidJniObject & data);
private:
    PImageSettings &mPImageSettings;
};
#endif

class PImageSettings : public QObject
{
    Q_OBJECT
public:
    explicit PImageSettings(QObject *parent = 0);

    Q_INVOKABLE void setBackground(QString path);
    Q_INVOKABLE void setBackgroundByAndroidGallery();

signals:
    void backgroundCopied();

public slots:


private:

private:
#ifdef Q_OS_ANDROID
    ImagePickReceiver imagePickReceiver;
#endif
};

#endif // P_IMAGE_SETTINGS_H
