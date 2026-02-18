# ============================================================================
# Communications Module
# Handles all communication links (TCP, UDP, Serial, Bluetooth, etc.)
# ============================================================================

# ----------------------------------------------------------------------------
# Core Communication Sources
# ----------------------------------------------------------------------------
target_sources(${CMAKE_PROJECT_NAME}
    PRIVATE
        LinkConfiguration.cc
        LinkConfiguration.h
        LinkInterface.cc
        LinkInterface.h
        LinkManager.cc
        LinkManager.h
        LogReplayLink.cc
        LogReplayLink.h
        LogReplayLinkController.cc
        LogReplayLinkController.h
        MAVLinkProtocol.cc
        MAVLinkProtocol.h
        TCPLink.cc
        TCPLink.h
        UDPLink.cc
        UDPLink.h
)

# USB board information JSON data
qt_add_resources(${CMAKE_PROJECT_NAME} json_comm
    PREFIX "/json"
    FILES USBBoardInfo.json
)

target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

# Uncomment to enable Qt socket debugging
# target_compile_definitions(${CMAKE_PROJECT_NAME} PRIVATE QABSTRACTSOCKET_DEBUG)

# ============================================================================
# Optional Communication Features
# ============================================================================

# ----------------------------------------------------------------------------
# Serial Port Communication
# ----------------------------------------------------------------------------

if(beeCopter_NO_SERIAL_LINK)
    target_compile_definitions(${CMAKE_PROJECT_NAME} PRIVATE beeCopter_NO_SERIAL_LINK)
else()
    target_sources(${CMAKE_PROJECT_NAME}
        PRIVATE
            beeCopterSerialPortInfo.cc
            beeCopterSerialPortInfo.h
            SerialLink.cc
            SerialLink.h
            UdpIODevice.cc
            UdpIODevice.h
    )

    # Qt SerialPort not available on mobile platforms
    if(NOT ANDROID AND NOT IOS)
        target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE Qt6::SerialPort)
    endif()
endif()

# ----------------------------------------------------------------------------
# Bluetooth Communication
# ----------------------------------------------------------------------------
if(beeCopter_ENABLE_BLUETOOTH)
    target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE Qt6::Bluetooth)
    target_sources(${CMAKE_PROJECT_NAME}
        PRIVATE
            BluetoothLink.cc
            BluetoothLink.h
    )

    target_compile_definitions(${CMAKE_PROJECT_NAME} PRIVATE beeCopter_ENABLE_BLUETOOTH)
endif()

# ----------------------------------------------------------------------------
# ZeroConf/mDNS Service Discovery
# ----------------------------------------------------------------------------
if(beeCopter_ZEROCONF_ENABLED)
    CPMAddPackage(
        NAME qmdnsengine
        GITHUB_REPOSITORY nitroshare/qmdnsengine
        GIT_TAG master
        OPTIONS
            "BUILD_DOC OFF"
            "BUILD_EXAMPLES OFF"
            "BUILD_TESTS OFF"
    )

    if(TARGET qmdnsengine)
        beeCopter_disable_dependency_warnings(qmdnsengine)
        target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE qmdnsengine)
        target_compile_definitions(${CMAKE_PROJECT_NAME} PRIVATE beeCopter_ZEROCONF_ENABLED)
    else()
        message(WARNING "beeCopter: qmdnsengine target not created, ZeroConf will be disabled")
    endif()
endif()

# ============================================================================
# Communication Link Subdirectories
# ============================================================================

add_subdirectory(MockLink)
