#pragma once

#include <QtCore/QMetaType>
#include <QtCore/QtTypes>

struct beeCopterTileSet
{
    beeCopterTileSet &operator+=(const beeCopterTileSet &other)
    {
        tileCount += other.tileCount;
        tileSize += other.tileSize;
        return *this;
    }

    void clear()
    {
        tileX0 = 0;
        tileX1 = 0;
        tileY0 = 0;
        tileY1 = 0;
        tileCount = 0;
        tileSize = 0;
    }

    int tileX0 = 0;
    int tileX1 = 0;
    int tileY0 = 0;
    int tileY1 = 0;
    quint64 tileCount = 0;
    quint64 tileSize = 0;
};
Q_DECLARE_METATYPE(beeCopterTileSet)
Q_DECLARE_METATYPE(beeCopterTileSet*)
