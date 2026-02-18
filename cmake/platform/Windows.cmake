# ----------------------------------------------------------------------------
# beeCopter Windows Platform Configuration
# ----------------------------------------------------------------------------

if(NOT WIN32)
    message(FATAL_ERROR "beeCopter: Invalid Platform: Windows.cmake included but platform is not Windows")
endif()

# ----------------------------------------------------------------------------
# Windows-Specific Definitions
# ----------------------------------------------------------------------------
target_compile_definitions(${CMAKE_PROJECT_NAME}
    PRIVATE
        _USE_MATH_DEFINES    # Enable M_PI and other math constants
        NOMINMAX             # Prevent min/max macro conflicts
        WIN32_LEAN_AND_MEAN  # Reduce Windows.h bloat
)

# ----------------------------------------------------------------------------
# Windows Executable Configuration
# ----------------------------------------------------------------------------
set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES WIN32_EXECUTABLE TRUE)

if(COMMAND _qt_internal_generate_win32_rc_file)
    set_target_properties(${CMAKE_PROJECT_NAME}
        PROPERTIES
            QT_TARGET_COMPANY_NAME "${beeCopter_ORG_NAME}"
            QT_TARGET_DESCRIPTION "${CMAKE_PROJECT_DESCRIPTION}"
            QT_TARGET_VERSION "${CMAKE_PROJECT_VERSION}"
            QT_TARGET_COPYRIGHT "${beeCopter_APP_COPYRIGHT}"
            QT_TARGET_PRODUCT_NAME "${CMAKE_PROJECT_NAME}"
            # QT_TARGET_COMMENTS: ${beeCopter_QT_TARGET_COMMENTS}
            # QT_TARGET_ORIGINAL_FILENAME: ${beeCopter_QT_TARGET_ORIGINAL_FILENAME}
            # QT_TARGET_TRADEMARKS: ${beeCopter_QT_TARGET_TRADEMARKS}
            # QT_TARGET_INTERNALNAME: ${beeCopter_QT_TARGET_INTERNALNAME}
            QT_TARGET_RC_ICONS "${beeCopter_WINDOWS_ICON_PATH}"
    )
    _qt_internal_generate_win32_rc_file(${CMAKE_PROJECT_NAME})
elseif(EXISTS "${beeCopter_WINDOWS_RESOURCE_FILE_PATH}")
    target_sources(${CMAKE_PROJECT_NAME} PRIVATE "${beeCopter_WINDOWS_RESOURCE_FILE_PATH}")
    set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES QT_TARGET_WINDOWS_RC_FILE "${beeCopter_WINDOWS_RESOURCE_FILE_PATH}")
elseif(EXISTS "${CMAKE_SOURCE_DIR}/deploy/windows/beeCopter.rc.in")
    configure_file(
        "${CMAKE_SOURCE_DIR}/deploy/windows/beeCopter.rc.in"
        "${CMAKE_BINARY_DIR}/beeCopter.rc"
        @ONLY
    )
    target_sources(${CMAKE_PROJECT_NAME} PRIVATE "${CMAKE_BINARY_DIR}/beeCopter.rc")
else()
    message(WARNING "beeCopter: No Windows resource file found")
endif()

if(MSVC)
    # qt_add_win_app_sdk(${CMAKE_PROJECT_NAME} PRIVATE)
endif()

message(STATUS "beeCopter: Windows platform configuration applied")
