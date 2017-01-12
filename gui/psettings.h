#ifndef PSETTINGS_H
#define PSETTINGS_H

#include <QObject>

#ifdef Q_OS_ANDROID
#include <QAndroidActivityResultReceiver>

class PSettings;

class ImagePickReceiver : public QAndroidActivityResultReceiver {
public:
    ImagePickReceiver(PSettings &pSettings) : pSettings(pSettings) { }
    void handleActivityResult(int requestCode, int resultCode,
                              const QAndroidJniObject & data);
private:
    PSettings &pSettings;
};
#endif

class PSettings : public QObject
{
    Q_OBJECT
public:
    explicit PSettings(QObject *parent = 0);

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

#endif // PSETTINGS_H
