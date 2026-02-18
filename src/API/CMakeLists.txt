# ============================================================================
# API Module
# Core plugin architecture and QML component interfaces
# ============================================================================

target_sources(${CMAKE_PROJECT_NAME}
    PRIVATE
        beeCopterCorePlugin.cc
        beeCopterCorePlugin.h
        beeCopterOptions.cc
        beeCopterOptions.h
        QmlComponentInfo.cc
        QmlComponentInfo.h
)

target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
