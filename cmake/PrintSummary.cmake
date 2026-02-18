# ============================================================================
# beeCopter Build Configuration Summary
# Prints a comprehensive summary of the build configuration
# ============================================================================

# ----------------------------------------------------------------------------
# Configuration Timestamp
# ----------------------------------------------------------------------------
string(TIMESTAMP beeCopter_CONFIGURE_TIME "%Y-%m-%d %H:%M:%S %Z")
message(STATUS "")
message(STATUS "==================================================================")
message(STATUS "beeCopter Configuration Summary")
message(STATUS "Generated at: ${beeCopter_CONFIGURE_TIME}")
message(STATUS "==================================================================")

# ----------------------------------------------------------------------------
# Helper Macro for ON/OFF Options
# ----------------------------------------------------------------------------
macro(OptionOutput _label)
    if(${ARGN})
        set(_val "ON")
    else()
        set(_val "OFF")
    endif()
    message(STATUS "  ${_label}: ${_val}")
endmacro()

# ----------------------------------------------------------------------------
# CMake System Information
# ----------------------------------------------------------------------------
message(STATUS "")
message(STATUS "CMake System:")
message(STATUS "  CMake version:      ${CMAKE_VERSION}")
message(STATUS "  Generator:          ${CMAKE_GENERATOR}")
message(STATUS "  Build type:         ${CMAKE_BUILD_TYPE}")
message(STATUS "  Source directory:   ${CMAKE_SOURCE_DIR}")
message(STATUS "  Install prefix:     ${CMAKE_INSTALL_PREFIX}")
message(STATUS "  Host system:        ${CMAKE_HOST_SYSTEM_NAME} ${CMAKE_HOST_SYSTEM_VERSION}")
message(STATUS "  Target system:      ${CMAKE_SYSTEM_NAME} ${CMAKE_SYSTEM_VERSION}")
if(CMAKE_TOOLCHAIN_FILE)
    message(STATUS "  Toolchain file:     ${CMAKE_TOOLCHAIN_FILE}")
endif()
if(CMAKE_PREFIX_PATH)
    message(STATUS "  Prefix path:        ${CMAKE_PREFIX_PATH}")
endif()

message(STATUS "")
message(STATUS "Compiler & Linker:")
message(STATUS "  C++ compiler:       ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
message(STATUS "  C++ standard:       C++${CMAKE_CXX_STANDARD}")
if(CMAKE_CXX_FLAGS)
    message(STATUS "  Compiler flags:     ${CMAKE_CXX_FLAGS}")
endif()
if(CMAKE_EXE_LINKER_FLAGS)
    message(STATUS "  Linker flags:       ${CMAKE_EXE_LINKER_FLAGS}")
endif()
if(beeCopter_LINKER)
    message(STATUS "  Linker:             ${beeCopter_LINKER}")
else()
    message(STATUS "  Linker:             system default")
endif()
if(CMAKE_INTERPROCEDURAL_OPTIMIZATION)
    message(STATUS "  IPO/LTO:            ON")
else()
    message(STATUS "  IPO/LTO:            OFF")
endif()
if(beeCopter_CACHE_PROGRAM)
    get_filename_component(_cache_tool "${beeCopter_CACHE_PROGRAM}" NAME_WE)
    message(STATUS "  Build cache:        ${_cache_tool} (${beeCopter_CACHE_PROGRAM})")
else()
    message(STATUS "  Build cache:        none")
endif()

# ----------------------------------------------------------------------------
# Application Metadata
# ----------------------------------------------------------------------------
message(STATUS "")
message(STATUS "Application:")
message(STATUS "  Name:               ${beeCopter_APP_NAME}")
message(STATUS "  Version:            ${beeCopter_APP_VERSION_STR}")
message(STATUS "  Description:        ${beeCopter_APP_DESCRIPTION}")
message(STATUS "  Organization:       ${beeCopter_ORG_NAME} (${beeCopter_ORG_DOMAIN})")
message(STATUS "  Package name:       ${beeCopter_PACKAGE_NAME}")
message(STATUS "  Settings version:   ${beeCopter_SETTINGS_VERSION}")
message(STATUS "  Qt version:         ${Qt6_VERSION}")

# ----------------------------------------------------------------------------
# Build & Feature Flags
# ----------------------------------------------------------------------------
message(STATUS "")
message(STATUS "Build & Feature Flags:")
OptionOutput("Stable build                          " beeCopter_STABLE_BUILD)
OptionOutput("Use build caching                     " beeCopter_USE_CACHE)
OptionOutput("Unity build                           " beeCopter_UNITY_BUILD)
OptionOutput("Enable testing                        " beeCopter_BUILD_TESTING)
OptionOutput("Enable QML debugging                  " beeCopter_DEBUG_QML)
OptionOutput("Enable QML linting                    " beeCopter_ENABLE_QMLLINT)
OptionOutput("Enable Bluetooth links                " beeCopter_ENABLE_BLUETOOTH)
OptionOutput("Enable ZeroConf compatibility         " beeCopter_ZEROCONF_ENABLED)
OptionOutput("Disable serial links                  " beeCopter_NO_SERIAL_LINK)
OptionOutput("Enable UVC devices                    " beeCopter_ENABLE_UVC)
OptionOutput("Enable GStreamer video                " beeCopter_ENABLE_GST_VIDEOSTREAMING)
OptionOutput("Enable Qt video backend               " beeCopter_ENABLE_QT_VIDEOSTREAMING)
OptionOutput("Disable APM MAVLink dialect           " beeCopter_DISABLE_APM_MAVLINK)
OptionOutput("Disable APM plugin                    " beeCopter_DISABLE_APM_PLUGIN)
OptionOutput("Disable PX4 plugin                    " beeCopter_DISABLE_PX4_PLUGIN)
OptionOutput("Enable code coverage                  " beeCopter_ENABLE_COVERAGE)
OptionOutput("Enable AddressSanitizer               " beeCopter_ENABLE_ASAN)
OptionOutput("Enable UndefinedBehaviorSanitizer     " beeCopter_ENABLE_UBSAN)
OptionOutput("Enable ThreadSanitizer                " beeCopter_ENABLE_TSAN)
OptionOutput("Enable MemorySanitizer                " beeCopter_ENABLE_MSAN)
OptionOutput("Enable clang-tidy                     " beeCopter_ENABLE_CLANG_TIDY)
OptionOutput("Git submodule update                  " GIT_SUBMODULE)

# ----------------------------------------------------------------------------
# External Dependencies
# ----------------------------------------------------------------------------
message(STATUS "")
message(STATUS "External Dependencies:")
message(STATUS "  MAVLink repo:       ${beeCopter_MAVLINK_GIT_REPO}")
message(STATUS "  MAVLink tag:        ${beeCopter_MAVLINK_GIT_TAG}")
message(STATUS "  CPM cache:          ${CPM_SOURCE_CACHE}")
if(CMAKE_GENERATOR MATCHES "Ninja")
  message(STATUS "  Link job pool:      ${beeCopter_LINK_PARALLEL_LEVEL} parallel jobs")
endif()
message(STATUS "  QML output dir:     ${QT_QML_OUTPUT_DIRECTORY}")
if(beeCopter_ENABLE_COVERAGE)
  message(STATUS "  Coverage line min:  ${beeCopter_COVERAGE_LINE_THRESHOLD}%")
  message(STATUS "  Coverage branch min: ${beeCopter_COVERAGE_BRANCH_THRESHOLD}%")
endif()
if(VALGRIND_EXECUTABLE)
  message(STATUS "  Valgrind:           ${VALGRIND_EXECUTABLE}")
  message(STATUS "  Valgrind timeout:   ${beeCopter_VALGRIND_TIMEOUT_MULTIPLIER}x")
endif()

# ----------------------------------------------------------------------------
# Platform-Specific Settings
# ----------------------------------------------------------------------------
if(ANDROID)
  message(STATUS "")
  message(STATUS "Android Platform:")
  message(STATUS "  Target SDK:         ${beeCopter_QT_ANDROID_TARGET_SDK_VERSION}")
  message(STATUS "  Min SDK:            ${beeCopter_QT_ANDROID_MIN_SDK_VERSION}")
  message(STATUS "  Package:            ${beeCopter_ANDROID_PACKAGE_NAME}")
  message(STATUS "  APK signing:        ${QT_ANDROID_SIGN_APK}")
  message(STATUS "  AAB signing:        ${QT_ANDROID_SIGN_AAB}")
endif()

if(MACOS)
  message(STATUS "")
  message(STATUS "macOS Platform:")
  message(STATUS "  Bundle ID:          ${beeCopter_MACOS_BUNDLE_ID}")
  message(STATUS "  Deployment target:  ${CMAKE_OSX_DEPLOYMENT_TARGET}")
  if(beeCopter_MACOS_UNIVERSAL_BUILD)
    message(STATUS "  Architectures:      ${CMAKE_OSX_ARCHITECTURES}")
  endif()
endif()

if(IOS)
  message(STATUS "")
  message(STATUS "iOS Platform:")
  message(STATUS "  Deployment target:  ${beeCopter_IOS_DEPLOYMENT_TARGET}")
  message(STATUS "  Device family:      ${beeCopter_IOS_TARGETED_DEVICE_FAMILY}")
endif()

if(WIN32 AND NOT ANDROID)
  message(STATUS "")
  message(STATUS "Windows Platform:")
  message(STATUS "  Icon:               ${beeCopter_WINDOWS_ICON_PATH}")
  message(STATUS "  Resource file:      ${beeCopter_WINDOWS_RESOURCE_FILE_PATH}")
endif()

if(LINUX AND NOT ANDROID)
  message(STATUS "")
  message(STATUS "Linux Platform:")
  if(beeCopter_CREATE_APPIMAGE)
    message(STATUS "  AppImage:           Enabled")
  endif()
endif()

message(STATUS "")
message(STATUS "==================================================================")
message(STATUS "")
