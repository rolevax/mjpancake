#include "cli/p_cli.h"

#include <QCoreApplication>
#include <QFile>
#include <QJsonDocument>
#include <QTextStream>



int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    app.setApplicationName("mjpancake");

    QTextStream in(stdin);
    QTextStream out(stdout);

    if (argc != 2) {
        out << "Usage: " << argv[0] << " <libsaki-cli.json>" << endl;
        return 1;
    }

    QJsonObject config;
    {
        QFile file(argv[1]);
        bool ok = file.open(QIODevice::ReadOnly | QIODevice::Text);
        if (!ok) {
            out << "Failed to poen " << file.fileName() << endl;
            return 2;
        }

        QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
        config = doc.object();
    }

    PCli pCli(config);

    auto readLine = [&in, &out]() {
        out << "> ";
        out.flush();
        return in.readLine();
    };

    for (QString line = readLine(); !line.isNull(); line = readLine())
        pCli.command(line);

    return 0;
}
