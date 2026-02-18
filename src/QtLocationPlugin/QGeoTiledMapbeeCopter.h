#pragma once

#include <QtCore/QLoggingCategory>
#include <QtLocation/private/qgeotiledmap_p.h>

Q_DECLARE_LOGGING_CATEGORY(QGeoTiledMapbeeCopterLog)

class QGeoTiledMappingManagerEnginebeeCopter;

class QGeoTiledMapbeeCopter : public QGeoTiledMap
{
    Q_OBJECT

public:
    explicit QGeoTiledMapbeeCopter(QGeoTiledMappingManagerEnginebeeCopter *engine, QObject *parent = nullptr);
    ~QGeoTiledMapbeeCopter();

    QGeoMap::Capabilities capabilities() const final;

private:
    // void evaluateCopyrights(const QSet<QGeoTileSpec> &visibleTiles) final;
};
