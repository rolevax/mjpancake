#include "gui/p_parse.h"

#include "libsaki/form/tile_count.h"

#include <sstream>



PParse::PParse(QObject *parent)
    : QObject(parent)
{
}

void PParse::parse(const QStringList &tiles)
{
    using namespace saki;

    TileCount closed;

    for (const QString &qstr : tiles) {
        T37 t(qstr.toStdString().c_str());
        closed.inc(t, 1);
    }

    int barkCt = 4 - tiles.size() / 3;
    auto parseds = closed.parse4(barkCt);
    QStringList res;

    for (Parsed &p : parseds) {
        std::ostringstream oss;
        oss << p;
        res.append(QString::fromStdString(oss.str()));
    }

    emit parsed(res);
}
