# ============================================================================
# beeCopter Build Configuration Options
# All options can be overridden by custom builds via CustomOverrides.cmake
# ============================================================================

include(CMakeDependentOption)

# Load centralized build configuration from .github/build-config.json
include(BuildConfig)

# ============================================================================
# Application Metadata
# ============================================================================

set(beeCopter_APP_NAME "beeCopter" CACHE STRING "Application name")
string(TIMESTAMP _copyright_year "%Y")
set(beeCopter_APP_COPYRIGHT "Copyright (c) ${_copyright_year} beeCopter. All rights reserved." CACHE STRING "Copyright notice")
set(beeCopter_APP_DESCRIPTION "beeCopter Yer Kontrol İstasyonu" CACHE STRING "Application description")
set(beeCopter_ORG_NAME "beeCopter" CACHE STRING "Organization name")
set(beeCopter_ORG_DOMAIN "beecopter.com" CACHE STRING "Organization domain")
set(beeCopter_PACKAGE_NAME "com.beecopter.groundcontrol" CACHE STRING "Package identifier")

# Settings version - increment to clear stored settings on next boot after incompatible changes
set(beeCopter_SETTINGS_VERSION "9" CACHE STRING "Settings schema version")

# ============================================================================
# Build Configuration
# ============================================================================

option(BUILD_SHARED_LIBS "Build using shared libraries" OFF)
option(beeCopter_STABLE_BUILD "Stable release build (disables daily build features)" OFF)
option(beeCopter_USE_CACHE "Enable compiler caching (ccache/sccache)" ON)
option(beeCopter_UNITY_BUILD "Enable unity builds for faster compilation" OFF)
option(beeCopter_BUILD_INSTALLER "Build platform installers/packages" ON)
option(beeCopter_ENABLE_WERROR "Treat compiler warnings as errors for beeCopter source code" ON)

# Debug-dependent options
cmake_dependent_option(beeCopter_BUILD_TESTING "Enable unit tests" ON "CMAKE_BUILD_TYPE STREQUAL Debug" OFF)
cmake_dependent_option(beeCopter_DEBUG_QML "Enable QML debugging/profiling" ON "CMAKE_BUILD_TYPE STREQUAL Debug" OFF)
cmake_dependent_option(beeCopter_ENABLE_COVERAGE "Enable code coverage instrumentation" OFF "CMAKE_BUILD_TYPE STREQUAL Debug" OFF)
option(beeCopter_ENABLE_CLANG_TIDY "Enable clang-tidy static analysis during build" OFF)

# Git options
option(GIT_SUBMODULE "Update submodules during configuration" OFF)

# Link parallelism (Ninja only)
set(beeCopter_LINK_PARALLEL_LEVEL 2 CACHE STRING "Maximum parallel link jobs (prevents OOM during LTO)")

# Coverage thresholds
set(beeCopter_COVERAGE_LINE_THRESHOLD 30 CACHE STRING "Minimum line coverage percentage")
set(beeCopter_COVERAGE_BRANCH_THRESHOLD 20 CACHE STRING "Minimum branch coverage percentage")

# Valgrind options
set(beeCopter_VALGRIND_TIMEOUT_MULTIPLIER 20 CACHE STRING "Timeout multiplier for Valgrind")

# ============================================================================
# Compression Format Options
# ============================================================================
# Core formats (gzip, xz, zstd, zip) are always enabled.
# These optional formats are rarely used in the drone ecosystem.

option(beeCopter_ENABLE_BZIP2 "Enable BZip2 decompression support" OFF)
option(beeCopter_ENABLE_LZ4 "Enable LZ4 decompression support" OFF)

# MAVLink Inspector is disabled by default due to GPL licensing of QtCharts
# option(beeCopter_DISABLE_MAVLINK_INSPECTOR "Disable MAVLink Inspector" OFF)

# ============================================================================
# Communication Options
# ============================================================================

option(beeCopter_ENABLE_BLUETOOTH "Enable Bluetooth communication links" ON)
option(beeCopter_ZEROCONF_ENABLED "Enable ZeroConf/Bonjour discovery" OFF)
option(beeCopter_NO_SERIAL_LINK "Disable serial port communication" OFF)

# ============================================================================
# Video Streaming Options
# ============================================================================

option(beeCopter_ENABLE_UVC "Enable UVC (USB Video Class) device support" ON)
option(beeCopter_ENABLE_GST_VIDEOSTREAMING "Enable GStreamer video backend" ON)
cmake_dependent_option(beeCopter_CUSTOM_GST_PACKAGE "Use beeCopter-provided GStreamer packages" OFF "beeCopter_ENABLE_GST_VIDEOSTREAMING" OFF)
option(beeCopter_ENABLE_QT_VIDEOSTREAMING "Enable QtMultimedia video backend" OFF)

# ============================================================================
# MAVLink Configuration
# ============================================================================

set(beeCopter_MAVLINK_GIT_REPO "https://github.com/mavlink/mavlink.git" CACHE STRING "MAVLink repository URL")
set(beeCopter_MAVLINK_GIT_TAG "b1fb5a1a32c41c6e46fea70600d626a0b5a8edbe" CACHE STRING "MAVLink repository commit/tag")
set(beeCopter_MAVLINK_DIALECT "all" CACHE STRING "MAVLink dialect")
set(beeCopter_MAVLINK_VERSION "2.0" CACHE STRING "MAVLink protocol version")

# ============================================================================
# Autopilot Plugin Configuration
# ============================================================================

# ArduPilot (APM) Plugin
option(beeCopter_DISABLE_APM_MAVLINK "Disable ArduPilot MAVLink dialect" OFF)
option(beeCopter_DISABLE_APM_PLUGIN "Disable ArduPilot plugin" OFF)
option(beeCopter_DISABLE_APM_PLUGIN_FACTORY "Disable ArduPilot plugin factory" OFF)

# PX4 Plugin
option(beeCopter_DISABLE_PX4_PLUGIN "Disable PX4 plugin" OFF)
option(beeCopter_DISABLE_PX4_PLUGIN_FACTORY "Disable PX4 plugin factory" OFF)

# ============================================================================
# Platform-Specific Configuration
# ============================================================================

# ----------------------------------------------------------------------------
# Android Platform
# ----------------------------------------------------------------------------
set(beeCopter_QT_ANDROID_COMPILE_SDK_VERSION "${beeCopter_CONFIG_ANDROID_PLATFORM}" CACHE STRING "Android compile SDK version")
set(beeCopter_QT_ANDROID_TARGET_SDK_VERSION "${beeCopter_CONFIG_ANDROID_PLATFORM}" CACHE STRING "Android target SDK version")
set(beeCopter_QT_ANDROID_MIN_SDK_VERSION "${beeCopter_CONFIG_ANDROID_MIN_SDK}" CACHE STRING "Android minimum SDK version")
set(beeCopter_ANDROID_PACKAGE_NAME "${beeCopter_PACKAGE_NAME}" CACHE STRING "Android package identifier")
set(beeCopter_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_SOURCE_DIR}/android" CACHE PATH "Android package source directory")
set(QT_ANDROID_DEPLOYMENT_TYPE "" CACHE STRING "Android deployment type (empty or Release)")
option(QT_ANDROID_SIGN_APK "Enable APK signing" OFF)
option(QT_ANDROID_SIGN_AAB "Enable AAB signing" OFF)
option(QT_USE_TARGET_ANDROID_BUILD_DIR "Use target-specific Android build directory" OFF)

# ----------------------------------------------------------------------------
# macOS Platform
# ----------------------------------------------------------------------------
set(beeCopter_MACOS_PLIST_PATH "${CMAKE_SOURCE_DIR}/deploy/macos/MacOSXBundleInfo.plist.in" CACHE FILEPATH "macOS Info.plist template path")
set(beeCopter_MACOS_BUNDLE_ID "${beeCopter_PACKAGE_NAME}" CACHE STRING "macOS bundle identifier")
set(beeCopter_MACOS_ICON_PATH "${CMAKE_SOURCE_DIR}/deploy/macos/beeCopter.icns" CACHE FILEPATH "macOS application icon path")
set(beeCopter_MACOS_ENTITLEMENTS_PATH "${CMAKE_SOURCE_DIR}/deploy/macos/beeCopter.entitlements" CACHE FILEPATH "macOS entitlements file path")
option(beeCopter_MACOS_UNIVERSAL_BUILD "Build macOS universal binary (x86_64h + arm64)" ON)

# ----------------------------------------------------------------------------
# iOS Platform
# ----------------------------------------------------------------------------
set(beeCopter_IOS_DEPLOYMENT_TARGET "${beeCopter_CONFIG_IOS_DEPLOYMENT_TARGET}" CACHE STRING "iOS minimum deployment target")
set(beeCopter_IOS_TARGETED_DEVICE_FAMILY "1,2" CACHE STRING "iOS targeted device family (1=iPhone, 2=iPad)")

# ----------------------------------------------------------------------------
# Linux Platform
# ----------------------------------------------------------------------------
option(beeCopter_CREATE_APPIMAGE "Create AppImage package after build" ON)
set(beeCopter_APPIMAGE_ICON_256_PATH "${CMAKE_SOURCE_DIR}/deploy/linux/beeCopter_256.png" CACHE FILEPATH "AppImage 256x256 icon path")
set(beeCopter_APPIMAGE_ICON_SCALABLE_PATH "${CMAKE_SOURCE_DIR}/deploy/linux/beeCopter.svg" CACHE FILEPATH "AppImage SVG icon path")
set(beeCopter_APPIMAGE_APPRUN_PATH "${CMAKE_SOURCE_DIR}/deploy/linux/AppRun" CACHE FILEPATH "AppImage AppRun script path")
set(beeCopter_APPIMAGE_DESKTOP_ENTRY_PATH "${CMAKE_SOURCE_DIR}/deploy/linux/org.mavlink.beeCopter.desktop.in" CACHE FILEPATH "AppImage desktop entry path")
set(beeCopter_APPIMAGE_METADATA_PATH "${CMAKE_SOURCE_DIR}/deploy/linux/org.mavlink.beeCopter.appdata.xml.in" CACHE FILEPATH "AppImage metadata path")
set(beeCopter_APPIMAGE_APPDATA_DEVELOPER "beeCopter" CACHE STRING "AppImage developer name")

# ----------------------------------------------------------------------------
# Windows Platform
# ----------------------------------------------------------------------------
set(beeCopter_WINDOWS_INSTALL_HEADER_PATH "${CMAKE_SOURCE_DIR}/deploy/windows/installheader.bmp" CACHE FILEPATH "Windows installer header image")
set(beeCopter_WINDOWS_ICON_PATH "${CMAKE_SOURCE_DIR}/deploy/windows/WindowsbeeCopter.ico" CACHE FILEPATH "Windows application icon")
set(beeCopter_WINDOWS_RESOURCE_FILE_PATH "${CMAKE_SOURCE_DIR}/deploy/windows/beeCopter.rc" CACHE FILEPATH "Windows resource file")

# ============================================================================
# Qt Configuration
# ============================================================================

set(beeCopter_QT_MINIMUM_VERSION "${beeCopter_CONFIG_QT_MINIMUM_VERSION}" CACHE STRING "Minimum supported Qt version")
set(beeCopter_QT_MAXIMUM_VERSION "${beeCopter_CONFIG_QT_VERSION}" CACHE STRING "Maximum supported Qt version")

set(QT_QML_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/qml" CACHE PATH "QML output directory")
set(QML_IMPORT_PATH "${QT_QML_OUTPUT_DIRECTORY}" CACHE STRING "Additional QML import paths")

option(QT_SILENCE_MISSING_DEPENDENCY_TARGET_WARNING "Silence missing dependency warnings" OFF)
option(QT_ENABLE_VERBOSE_DEPLOYMENT "Enable verbose deployment output" OFF)
option(QT_DEBUG_FIND_PACKAGE "Print search paths when package not found" ON)
option(QT_QML_GENERATE_QMLLS_INI "Generate qmlls.ini for QML language server" ON)
option(beeCopter_ENABLE_QMLLINT "Enable automatic QML linting during build" OFF)

set(beeCopter_QT_DISABLE_DEPRECATED_UP_TO "0x061000" CACHE STRING "Disable Qt APIs deprecated before this version")
set(beeCopter_QT_ENABLE_STRICT_MODE_UP_TO "0x061000" CACHE STRING "Enable strict Qt API mode up to this version")

# Debug environment variables (uncomment to enable)
# set(ENV{QT_DEBUG_PLUGINS} "1")
# set(ENV{QML_IMPORT_TRACE} "1")

# ============================================================================
# CMake Package Manager (CPM)
# ============================================================================

# Uncomment to use named cache directories for better organization
# set(CPM_USE_NAMED_CACHE_DIRECTORIES ON CACHE BOOL "Use package name subdirectories in CPM cache")

# ============================================================================
# CMake Configuration
# ============================================================================

# Uncomment for verbose package finding
# option(CMAKE_FIND_DEBUG_MODE "Print search paths when finding packages" OFF)
