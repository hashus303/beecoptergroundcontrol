#pragma once

#include <QtCore/QList>
#include <QtCore/QMetaType>
#include <QtCore/QString>

struct beeCopterTile
{
    enum TileState {
        StatePending = 0,
        StateDownloading,
        StateError,
        StateComplete
    };

    int x = 0;
    int y = 0;
    int z = 0;
    quint64 tileSet = UINT64_MAX;
    QString hash;
    int type = -1;
};
Q_DECLARE_METATYPE(beeCopterTile)
Q_DECLARE_METATYPE(beeCopterTile*)
Q_DECLARE_METATYPE(QList<beeCopterTile*>)
