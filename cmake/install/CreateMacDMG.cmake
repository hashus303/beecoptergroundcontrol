# ============================================================================
# CreateMacDMG.cmake
# Creates macOS DMG disk image for distribution
# ============================================================================
#
# Required Variables (passed from Install.cmake):
#   beeCopter_STAGING_BUNDLE_PATH => Full path to MyApp.app bundle
#   CREATE_DMG_PROGRAM      => Full path to create-dmg program
#

message(STATUS "beeCopter: Creating macOS DMG disk image...")

# ============================================================================
# Prepare Package Directory
# ============================================================================

set(beeCopter_DMG_PATH "${CMAKE_BINARY_DIR}/package")

# Clean and create package directory
file(REMOVE_RECURSE "${beeCopter_DMG_PATH}")
file(MAKE_DIRECTORY "${beeCopter_DMG_PATH}")

# Copy the application bundle to package directory
file(COPY "${beeCopter_STAGING_BUNDLE_PATH}" DESTINATION "${beeCopter_DMG_PATH}")

# ============================================================================
# Create DMG
# ============================================================================

cmake_path(GET beeCopter_STAGING_BUNDLE_PATH STEM beeCopter_TARGET_APP_NAME)
set(beeCopter_DMG_NAME "${beeCopter_TARGET_APP_NAME}.dmg")
set(beeCopter_TARGET_APP_BUNDLE "${beeCopter_TARGET_APP_NAME}.app")

set(beeCopter_DMG_WINDOW_POS 200 120)
set(beeCopter_DMG_WINDOW_SIZE 640 480)
set(beeCopter_DMG_ICON_SIZE 128)
set(beeCopter_DMG_APP_ICON_POS 160 220)
set(beeCopter_DMG_DROP_ICON_POS 480 220)

message(STATUS "beeCopter: Building ${beeCopter_DMG_NAME}...")

set(beeCopter_CREATE_DMG_ARGS
    --volname "${beeCopter_TARGET_APP_NAME}"
    --filesystem APFS
)
list(APPEND beeCopter_CREATE_DMG_ARGS --window-pos ${beeCopter_DMG_WINDOW_POS})
list(APPEND beeCopter_CREATE_DMG_ARGS --window-size ${beeCopter_DMG_WINDOW_SIZE})
list(APPEND beeCopter_CREATE_DMG_ARGS --icon-size ${beeCopter_DMG_ICON_SIZE})
list(APPEND beeCopter_CREATE_DMG_ARGS --icon "${beeCopter_TARGET_APP_BUNDLE}" ${beeCopter_DMG_APP_ICON_POS})
# Drop target drives drag-and-drop install experience for Applications folder
list(APPEND beeCopter_CREATE_DMG_ARGS --app-drop-link ${beeCopter_DMG_DROP_ICON_POS})
list(APPEND beeCopter_CREATE_DMG_ARGS "${beeCopter_DMG_NAME}" "${beeCopter_DMG_PATH}/")

execute_process(
    COMMAND "${CREATE_DMG_PROGRAM}" ${beeCopter_CREATE_DMG_ARGS}
    WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
    COMMAND_ECHO STDOUT
    COMMAND_ERROR_IS_FATAL ANY
)

message(STATUS "beeCopter: DMG created successfully: ${CMAKE_BINARY_DIR}/${beeCopter_DMG_NAME}")
