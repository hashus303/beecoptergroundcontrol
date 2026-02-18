# ============================================================================
# QtLocationPlugin Unit Tests
# Tests for tile cache database operations
# ============================================================================

target_sources(${CMAKE_PROJECT_NAME}
    PRIVATE
        MapProviderTest.cc
        MapProviderTest.h
        beeCopterMapEngineManagerArchiveTest.cc
        beeCopterMapEngineManagerArchiveTest.h
        beeCopterCachedTileSetTest.cc
        beeCopterCachedTileSetTest.h
        beeCopterCacheWorkerTest.cc
        beeCopterCacheWorkerTest.h
        beeCopterTileCacheDatabaseTest.cc
        beeCopterTileCacheDatabaseTest.h
        beeCopterTileSetTest.cc
        beeCopterTileSetTest.h
        UrlFactoryTest.cc
        UrlFactoryTest.h
)

target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
