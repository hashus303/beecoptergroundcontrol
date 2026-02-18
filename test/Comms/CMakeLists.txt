# ============================================================================
# Communications Unit Tests
# Tests for serial port detection and communication links
# ============================================================================

target_sources(${CMAKE_PROJECT_NAME}
    PRIVATE
        beeCopterSerialPortInfoTest.cc
        beeCopterSerialPortInfoTest.h
)

target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
