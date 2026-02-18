# ============================================================================
# SignMacBundle.cmake
# Code signing and notarization for macOS application bundles
# ============================================================================

message(STATUS "beeCopter: Signing Bundle using signing identity")

# ----------------------------------------------------------------------------
# Environment Variable Validation
# ----------------------------------------------------------------------------
if(NOT DEFINED ENV{beeCopter_MACOS_SIGNING_IDENTITY} OR "$ENV{beeCopter_MACOS_SIGNING_IDENTITY}" STREQUAL "")
    message(FATAL_ERROR "beeCopter: beeCopter_MACOS_SIGNING_IDENTITY environment variable must be set to sign MacOS bundle")
endif()
if(NOT DEFINED ENV{beeCopter_MACOS_NOTARIZATION_USERNAME} OR "$ENV{beeCopter_MACOS_NOTARIZATION_USERNAME}" STREQUAL "")
    message(FATAL_ERROR "beeCopter: beeCopter_MACOS_NOTARIZATION_USERNAME environment variable must be set to notarize MacOS bundle")
endif()
if(NOT DEFINED ENV{beeCopter_MACOS_NOTARIZATION_TEAM_ID} OR "$ENV{beeCopter_MACOS_NOTARIZATION_TEAM_ID}" STREQUAL "")
    message(FATAL_ERROR "beeCopter: beeCopter_MACOS_NOTARIZATION_TEAM_ID environment variable must be set to notarize MacOS bundle")
endif()
if(NOT DEFINED ENV{beeCopter_MACOS_NOTARIZATION_PASSWORD} OR "$ENV{beeCopter_MACOS_NOTARIZATION_PASSWORD}" STREQUAL "")
    message(FATAL_ERROR "beeCopter: beeCopter_MACOS_NOTARIZATION_PASSWORD environment variable must be set to notarize MacOS bundle")
endif()

# ----------------------------------------------------------------------------
# Clean Up GStreamer Symlinks
# ----------------------------------------------------------------------------
file(REMOVE "${beeCopter_STAGING_BUNDLE_PATH}/Contents/Frameworks/GStreamer.framework/Commands")
file(REMOVE "${beeCopter_STAGING_BUNDLE_PATH}/Contents/Frameworks/GStreamer.framework/Versions/1.0/Commands")

# ----------------------------------------------------------------------------
# Sign All Libraries and Executables
# ----------------------------------------------------------------------------
# Sign all dynamic libraries
execute_process(
    COMMAND find "${beeCopter_STAGING_BUNDLE_PATH}/Contents" -type f -name "*.dylib" -exec codesign --timestamp --options=runtime --force -s "$ENV{beeCopter_MACOS_SIGNING_IDENTITY}" "{}" \\;
    COMMAND_ERROR_IS_FATAL ANY
)

# Sign all shared objects
execute_process(
    COMMAND find "${beeCopter_STAGING_BUNDLE_PATH}/Contents" -type f -name "*.so" -exec codesign --timestamp --options=runtime --force -s "$ENV{beeCopter_MACOS_SIGNING_IDENTITY}" "{}" \\;
    COMMAND_ERROR_IS_FATAL ANY
)

# ----------------------------------------------------------------------------
# Sign GStreamer Framework Components
# ----------------------------------------------------------------------------
if(EXISTS "${beeCopter_STAGING_BUNDLE_PATH}/Contents/Frameworks/GStreamer.framework")
    execute_process(
        COMMAND find "${beeCopter_STAGING_BUNDLE_PATH}/Contents/Frameworks/GStreamer.framework/Versions/1.0/libexec/gstreamer-1.0" -type f -exec codesign --timestamp --options=runtime --force -s "$ENV{beeCopter_MACOS_SIGNING_IDENTITY}" "{}" \\;
        COMMAND_ERROR_IS_FATAL ANY
    )
    execute_process(
        COMMAND codesign --timestamp --options=runtime --force -s "$ENV{beeCopter_MACOS_SIGNING_IDENTITY}" "${beeCopter_STAGING_BUNDLE_PATH}/Contents/Frameworks/GStreamer.framework/Versions/1.0/lib/GStreamer"
        COMMAND_ERROR_IS_FATAL ANY
    )
    execute_process(
        COMMAND codesign --timestamp --options=runtime --force -s "$ENV{beeCopter_MACOS_SIGNING_IDENTITY}" "${beeCopter_STAGING_BUNDLE_PATH}/Contents/Frameworks/GStreamer.framework/Versions/1.0/GStreamer"
        COMMAND_ERROR_IS_FATAL ANY
    )
endif()

# ----------------------------------------------------------------------------
# Sign All Frameworks
# ----------------------------------------------------------------------------
file(GLOB FRAMEWORK_DIRS "${beeCopter_STAGING_BUNDLE_PATH}/Contents/Frameworks/*.framework")
foreach(FRAMEWORK_DIR ${FRAMEWORK_DIRS})
    if(EXISTS "${FRAMEWORK_DIR}/Versions/1.0")
        execute_process(
            COMMAND find "${FRAMEWORK_DIR}/Versions/1.0" -type f -exec codesign --timestamp --options=runtime --force -s "$ENV{beeCopter_MACOS_SIGNING_IDENTITY}" "{}" \\;
            COMMAND_ERROR_IS_FATAL ANY
        )
    endif()
    if(EXISTS "${FRAMEWORK_DIR}/Versions/A")
        execute_process(
            COMMAND find "${FRAMEWORK_DIR}/Versions/A" -type f -exec codesign --timestamp --options=runtime --force -s "$ENV{beeCopter_MACOS_SIGNING_IDENTITY}" "{}" \\;
            COMMAND_ERROR_IS_FATAL ANY
        )
    endif()
endforeach()

# ----------------------------------------------------------------------------
# Sign Main Application Bundle
# ----------------------------------------------------------------------------
execute_process(
    COMMAND codesign --timestamp --options=runtime --force -s "$ENV{beeCopter_MACOS_SIGNING_IDENTITY}" "${beeCopter_STAGING_BUNDLE_PATH}"
    COMMAND_ERROR_IS_FATAL ANY
)

# ============================================================================
# Notarization Process
# ============================================================================

set(_notarize_zip "${CMAKE_BINARY_DIR}/beeCopter_notarization_upload.zip")
message(STATUS "beeCopter: Archiving Bundle for Notarization upload")
file(REMOVE "${_notarize_zip}")
execute_process(
    COMMAND ditto -c -k --keepParent "${beeCopter_STAGING_BUNDLE_PATH}" "${_notarize_zip}"
    COMMAND_ERROR_IS_FATAL ANY
)
message(STATUS "beeCopter: Notarizing app bundle. This may take a while...")
execute_process(
    COMMAND xcrun notarytool submit "${_notarize_zip}" --apple-id "$ENV{beeCopter_MACOS_NOTARIZATION_USERNAME}" --team-id "$ENV{beeCopter_MACOS_NOTARIZATION_TEAM_ID}" --password "$ENV{beeCopter_MACOS_NOTARIZATION_PASSWORD}" --wait
    COMMAND_ERROR_IS_FATAL ANY
)
message(STATUS "beeCopter: Stapling notarization ticket to app bundle")
execute_process(
    COMMAND xcrun stapler staple "${beeCopter_STAGING_BUNDLE_PATH}"
    COMMAND_ERROR_IS_FATAL ANY
)
