# ============================================================================
# FileSystem Utilities Unit Tests
# Tests for file download and filesystem operations
# ============================================================================

target_sources(${CMAKE_PROJECT_NAME}
    PRIVATE
        beeCopterArchiveWatcherTest.cc
        beeCopterArchiveWatcherTest.h
        beeCopterCachedFileDownloadTest.cc
        beeCopterCachedFileDownloadTest.h
        beeCopterFileDownloadTest.cc
        beeCopterFileDownloadTest.h
        beeCopterFileHelperTest.cc
        beeCopterFileHelperTest.h
        beeCopterFileWatcherTest.cc
        beeCopterFileWatcherTest.h
)

target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
