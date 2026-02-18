# ============================================================================
# Custom Build Configuration Overrides
# Template for customizing QGroundControl branding and feature set
# ============================================================================

# ----------------------------------------------------------------------------
# Application Branding
# ----------------------------------------------------------------------------
set(beeCopter_APP_NAME "Custom-QGroundControl" CACHE STRING "App Name" FORCE)

# ----------------------------------------------------------------------------
# Custom Icons and Graphics
# ----------------------------------------------------------------------------

# macOS Icon
if(EXISTS "${CMAKE_SOURCE_DIR}/custom/res/icons/custom_qgroundcontrol.icns")
    set(beeCopter_MACOS_ICON_PATH "${CMAKE_SOURCE_DIR}/custom/res/icons/custom_qgroundcontrol.icns" CACHE FILEPATH "MacOS Icon Path" FORCE)
endif()

# Linux AppImage Icon
if(EXISTS "${CMAKE_SOURCE_DIR}/custom/res/icons/custom_qgroundcontrol.svg")
    set(beeCopter_APPIMAGE_ICON_SCALABLE_PATH "${CMAKE_SOURCE_DIR}/custom/res/icons/custom_qgroundcontrol.svg" CACHE FILEPATH "AppImage Icon SVG Path" FORCE)
endif()

# Windows Installer Header
if(EXISTS "${CMAKE_SOURCE_DIR}/custom/deploy/windows/installheader.bmp")
    set(beeCopter_WINDOWS_INSTALL_HEADER_PATH "${CMAKE_SOURCE_DIR}/custom/deploy/windows/installheader.bmp" CACHE FILEPATH "Windows Install Header Path" FORCE)
endif()

# Windows Application Icon
if(EXISTS "${CMAKE_SOURCE_DIR}/custom/deploy/windows/WindowsbeeCopter.ico")
    set(beeCopter_WINDOWS_ICON_PATH "${CMAKE_SOURCE_DIR}/custom/deploy/windows/WindowsbeeCopter.ico" CACHE FILEPATH "Windows Icon Path" FORCE)
endif()

# ----------------------------------------------------------------------------
# Feature Set Customization
# ----------------------------------------------------------------------------

# Build a single flight stack by disabling APM support
set(beeCopter_DISABLE_APM_MAVLINK ON CACHE BOOL "Disable APM Dialect" FORCE)
set(beeCopter_DISABLE_APM_PLUGIN ON CACHE BOOL "Disable APM Plugin" FORCE)
set(beeCopter_DISABLE_APM_PLUGIN_FACTORY ON CACHE BOOL "Disable APM Plugin Factory" FORCE)

# Implement custom PX4 plugin factory
set(beeCopter_DISABLE_PX4_PLUGIN_FACTORY ON CACHE BOOL "Disable PX4 Plugin Factory" FORCE)
