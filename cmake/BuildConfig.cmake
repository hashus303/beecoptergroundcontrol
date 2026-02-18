# ============================================================================
# BuildConfig.cmake - Read .github/build-config.json
# ============================================================================

set(beeCopter_BUILD_CONFIG_FILE "${CMAKE_SOURCE_DIR}/.github/build-config.json")

if(NOT EXISTS "${beeCopter_BUILD_CONFIG_FILE}")
    message(FATAL_ERROR "BuildConfig: Config file not found: ${beeCopter_BUILD_CONFIG_FILE}")
endif()

# Read the JSON file
file(READ "${beeCopter_BUILD_CONFIG_FILE}" beeCopter_BUILD_CONFIG_CONTENT)

# Extract value from JSON using CMake's native JSON parser
function(beeCopter_config_get_value VAR_NAME JSON_KEY)
    string(JSON _value ERROR_VARIABLE _err GET "${beeCopter_BUILD_CONFIG_CONTENT}" "${JSON_KEY}")
    if(_err)
        message(FATAL_ERROR "BuildConfig: Key '${JSON_KEY}' not found in ${beeCopter_BUILD_CONFIG_FILE}")
    endif()
    set(${VAR_NAME} "${_value}" CACHE STRING "${JSON_KEY}" FORCE)
endfunction()

beeCopter_config_get_value(beeCopter_CONFIG_QT_VERSION "qt_version")
beeCopter_config_get_value(beeCopter_CONFIG_QT_MINIMUM_VERSION "qt_minimum_version")
beeCopter_config_get_value(beeCopter_CONFIG_GSTREAMER_VERSION "gstreamer_version")
beeCopter_config_get_value(beeCopter_CONFIG_GSTREAMER_ANDROID_VERSION "gstreamer_android_version")
beeCopter_config_get_value(beeCopter_CONFIG_GSTREAMER_MACOS_VERSION "gstreamer_macos_version")
beeCopter_config_get_value(beeCopter_CONFIG_GSTREAMER_WIN_VERSION "gstreamer_windows_version")
beeCopter_config_get_value(beeCopter_CONFIG_NDK_VERSION "ndk_version")
beeCopter_config_get_value(beeCopter_CONFIG_NDK_FULL_VERSION "ndk_full_version")
beeCopter_config_get_value(beeCopter_CONFIG_JAVA_VERSION "java_version")
beeCopter_config_get_value(beeCopter_CONFIG_ANDROID_PLATFORM "android_platform")
beeCopter_config_get_value(beeCopter_CONFIG_ANDROID_MIN_SDK "android_min_sdk")
beeCopter_config_get_value(beeCopter_CONFIG_CMAKE_MINIMUM "cmake_minimum_version")
beeCopter_config_get_value(beeCopter_CONFIG_MACOS_DEPLOYMENT_TARGET "macos_deployment_target")
beeCopter_config_get_value(beeCopter_CONFIG_IOS_DEPLOYMENT_TARGET "ios_deployment_target")

message(STATUS "BuildConfig: Qt ${beeCopter_CONFIG_QT_VERSION}, GStreamer ${beeCopter_CONFIG_GSTREAMER_VERSION}, NDK ${beeCopter_CONFIG_NDK_VERSION}")
