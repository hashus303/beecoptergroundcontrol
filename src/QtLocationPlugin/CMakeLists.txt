# ============================================================================
# Qt Location Plugin Module
# Custom map tile providers and caching engine
# ============================================================================

qt_add_plugin(beeCopterLocation
    STATIC
    CLASS_NAME QGeoServiceProviderFactorybeeCopter
    OUTPUT_TARGETS beeCopterLocation_targets
    Providers/BingMapProvider.cpp
    Providers/BingMapProvider.h
    Providers/ElevationMapProvider.cpp
    Providers/ElevationMapProvider.h
    Providers/EsriMapProvider.cpp
    Providers/EsriMapProvider.h
    Providers/GenericMapProvider.cpp
    Providers/GenericMapProvider.h
    Providers/GoogleMapProvider.cpp
    Providers/GoogleMapProvider.h
    Providers/MapboxMapProvider.cpp
    Providers/MapboxMapProvider.h
    Providers/MapProvider.cpp
    Providers/MapProvider.h
    Providers/TianDiTuProvider.cpp
    Providers/TianDiTuProvider.h
    beeCopterCachedTileSet.cpp
    beeCopterCachedTileSet.h
    beeCopterCacheTile.h
    beeCopterMapEngine.cpp
    beeCopterMapEngine.h
    beeCopterMapEngineManager.cc
    beeCopterMapEngineManager.h
    beeCopterMapTasks.h
    beeCopterMapUrlEngine.cpp
    beeCopterMapUrlEngine.h
    beeCopterTile.h
    beeCopterTileCacheDatabase.cpp
    beeCopterTileCacheDatabase.h
    beeCopterTileCacheTypes.h
    beeCopterTileCacheWorker.cpp
    beeCopterTileCacheWorker.h
    beeCopterTileSet.h
    QGeoFileTileCachebeeCopter.cpp
    QGeoFileTileCachebeeCopter.h
    QGeoMapReplybeeCopter.cpp
    QGeoMapReplybeeCopter.h
    QGeoServiceProviderPluginbeeCopter.cpp
    QGeoServiceProviderPluginbeeCopter.h
    QGeoTiledMappingManagerEnginebeeCopter.cpp
    QGeoTiledMappingManagerEnginebeeCopter.h
    QGeoTiledMapbeeCopter.cpp
    QGeoTiledMapbeeCopter.h
    QGeoTileFetcherbeeCopter.cpp
    QGeoTileFetcherbeeCopter.h
)

# ----------------------------------------------------------------------------
# Platform-Specific Configuration
# ----------------------------------------------------------------------------
# Google Maps not available on iOS
if(IOS)
    target_compile_definitions(beeCopterLocation PRIVATE beeCopter_NO_GOOGLE_MAPS)
endif()

# ----------------------------------------------------------------------------
# Dependencies
# ----------------------------------------------------------------------------
target_link_libraries(beeCopterLocation
    PRIVATE
        Qt6::Positioning
        Qt6::Sql
    PUBLIC
        Qt6::Core
        Qt6::Location
        Qt6::LocationPrivate
        Qt6::Network
)

target_include_directories(beeCopterLocation
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_CURRENT_SOURCE_DIR}/..
        ${CMAKE_CURRENT_SOURCE_DIR}/../FactSystem
        ${CMAKE_CURRENT_SOURCE_DIR}/../QmlControls
        ${CMAKE_CURRENT_SOURCE_DIR}/../Terrain
        ${CMAKE_CURRENT_SOURCE_DIR}/../Terrain/Providers
        ${CMAKE_CURRENT_SOURCE_DIR}/../Settings
        ${CMAKE_CURRENT_SOURCE_DIR}/../Utilities
        ${CMAKE_CURRENT_SOURCE_DIR}/../Utilities/Compression
        ${CMAKE_CURRENT_SOURCE_DIR}/../Utilities/FileSystem
        ${CMAKE_CURRENT_SOURCE_DIR}/../Utilities/Network
        Providers
)

set_source_files_properties(QMLControl/OfflineMapEditor.qml PROPERTIES QT_RESOURCE_ALIAS OfflineMapEditor.qml)

target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE beeCopterLocation)
