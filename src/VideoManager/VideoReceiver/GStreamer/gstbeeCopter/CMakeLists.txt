# ============================================================================
# GStreamer beeCopter Video Sink Plugin
# Custom GStreamer elements for beeCopter video streaming
# ============================================================================

target_sources(${CMAKE_PROJECT_NAME}
    PRIVATE
        gstbeeCopter.cc
        gstbeeCopterelement.cc
        gstbeeCopterelements.h
        gstbeeCoptervideosinkbin.cc
        gstbeeCoptervideosinkbin.h
)

target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
