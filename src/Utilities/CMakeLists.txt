# ============================================================================
# Utilities Module
# Core utilities, logging, file system helpers, and platform abstractions
# ============================================================================

# ----------------------------------------------------------------------------
# Core Utility Sources
# ----------------------------------------------------------------------------
target_sources(${CMAKE_PROJECT_NAME}
    PRIVATE
        DeviceInfo.cc
        DeviceInfo.h
        JsonHelper.cc
        JsonHelper.h
        FileSystem/beeCopterCachedFileDownload.cc
        FileSystem/beeCopterCachedFileDownload.h
        FileSystem/beeCopterFileDownload.cc
        FileSystem/beeCopterFileDownload.h
        FileSystem/beeCopterFileHelper.cc
        FileSystem/beeCopterFileHelper.h
        FileSystem/beeCopterArchiveWatcher.cc
        FileSystem/beeCopterArchiveWatcher.h
        FileSystem/beeCopterFileWatcher.cc
        FileSystem/beeCopterFileWatcher.h
        beeCopter.cc
        beeCopter.h
        beeCopterCommandLineParser.cc
        beeCopterCommandLineParser.h
        beeCopterLogging.cc
        beeCopterLogging.h
        beeCopterLoggingCategory.cc
        beeCopterLoggingCategory.h
        StateMachine.cc
        StateMachine.h
)

target_include_directories(${CMAKE_PROJECT_NAME}
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
        Compression
        FileSystem
        Parsing
        Parsing/DataFlash
        Parsing/Exif
        Parsing/ULog
)

# ============================================================================
# Utility Subdirectories
# ============================================================================

add_subdirectory(Audio)
add_subdirectory(Compression)
add_subdirectory(Geo)
add_subdirectory(Network)
add_subdirectory(Parsing)
add_subdirectory(Platform)
add_subdirectory(SDL)
add_subdirectory(StateMachine)
