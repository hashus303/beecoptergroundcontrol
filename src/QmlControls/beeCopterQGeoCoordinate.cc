#include "beeCopterQGeoCoordinate.h"

#include <QtQml/QQmlEngine>

beeCopterQGeoCoordinate::beeCopterQGeoCoordinate(const QGeoCoordinate& coord, QObject* parent)
    : QObject       (parent)
    , _coordinate   (coord)
    , _dirty        (false)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
}

void beeCopterQGeoCoordinate::setCoordinate(const QGeoCoordinate& coordinate)
{
    if (_coordinate != coordinate) {
        _coordinate = coordinate;
        emit coordinateChanged(coordinate);
        setDirty(true);
    }
}

void beeCopterQGeoCoordinate::setDirty(bool dirty)
{
    if (_dirty != dirty) {
        _dirty = dirty;
        emit dirtyChanged(dirty);
    }
}
