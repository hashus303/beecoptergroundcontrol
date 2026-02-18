# ----------------------------------------------------------------------------
# beeCopter Android Platform Configuration
# ----------------------------------------------------------------------------

if(NOT ANDROID)
    message(FATAL_ERROR "beeCopter: Invalid Platform: Android.cmake included but platform is not Android")
endif()

# ----------------------------------------------------------------------------
# Android NDK Version Validation
# ----------------------------------------------------------------------------
# CMAKE_ANDROID_NDK_VERSION format varies: "27.2" or "27.2.12829759"
# Extract major.minor from ndk_full_version for reliable comparison
if(DEFINED beeCopter_CONFIG_NDK_FULL_VERSION AND Qt6_VERSION VERSION_GREATER_EQUAL "${beeCopter_CONFIG_QT_MINIMUM_VERSION}")
    string(REGEX MATCH "^([0-9]+\\.[0-9]+)" _ndk_major_minor "${beeCopter_CONFIG_NDK_FULL_VERSION}")
    if(_ndk_major_minor AND NOT CMAKE_ANDROID_NDK_VERSION VERSION_GREATER_EQUAL "${_ndk_major_minor}")
        message(FATAL_ERROR "beeCopter: NDK ${CMAKE_ANDROID_NDK_VERSION} is too old. Qt ${Qt6_VERSION} requires NDK ${_ndk_major_minor}+ (${beeCopter_CONFIG_NDK_VERSION})")
    endif()
    unset(_ndk_major_minor)
endif()

# ----------------------------------------------------------------------------
# Android Version Number Validation
# ----------------------------------------------------------------------------

# Generation of Android version numbers must be consistent release to release
# to ensure they are always increasing for Google Play Store
if(CMAKE_PROJECT_VERSION_MAJOR GREATER 9)
    message(FATAL_ERROR "beeCopter: Major version must be single digit (0-9), got: ${CMAKE_PROJECT_VERSION_MAJOR}")
endif()
if(CMAKE_PROJECT_VERSION_MINOR GREATER 9)
    message(FATAL_ERROR "beeCopter: Minor version must be single digit (0-9), got: ${CMAKE_PROJECT_VERSION_MINOR}")
endif()
if(CMAKE_PROJECT_VERSION_PATCH GREATER 99)
    message(FATAL_ERROR "beeCopter: Patch version must be two digits (0-99), got: ${CMAKE_PROJECT_VERSION_PATCH}")
endif()

# ----------------------------------------------------------------------------
# Android ABI to Bitness Code Mapping
# ----------------------------------------------------------------------------
# NOTE: Bitness codes are 66/34 instead of 64/32 due to a historical
# version number bump requirement from an earlier Android release
set(ANDROID_BITNESS_CODE)
if(CMAKE_ANDROID_ARCH_ABI STREQUAL "armeabi-v7a" OR CMAKE_ANDROID_ARCH_ABI STREQUAL "x86")
    set(ANDROID_BITNESS_CODE 34)
elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL "arm64-v8a" OR CMAKE_ANDROID_ARCH_ABI STREQUAL "x86_64")
    set(ANDROID_BITNESS_CODE 66)
else()
    message(FATAL_ERROR "beeCopter: Unsupported Android ABI: ${CMAKE_ANDROID_ARCH_ABI}. Supported: armeabi-v7a, arm64-v8a, x86, x86_64")
endif()

# ----------------------------------------------------------------------------
# Android Version Code Generation
# ----------------------------------------------------------------------------
# Zero-pad patch version if less than 10
set(ANDROID_PATCH_VERSION ${CMAKE_PROJECT_VERSION_PATCH})
if(CMAKE_PROJECT_VERSION_PATCH LESS 10)
    set(ANDROID_PATCH_VERSION "0${CMAKE_PROJECT_VERSION_PATCH}")
endif()

# Version code format: BBMIPPDDD (B=Bitness, M=Major, I=Minor, P=Patch, D=Dev) - Dev not currently supported and always 000
set(ANDROID_VERSION_CODE "${ANDROID_BITNESS_CODE}${CMAKE_PROJECT_VERSION_MAJOR}${CMAKE_PROJECT_VERSION_MINOR}${ANDROID_PATCH_VERSION}000")
message(STATUS "beeCopter: Android version code: ${ANDROID_VERSION_CODE}")

set_target_properties(${CMAKE_PROJECT_NAME}
    PROPERTIES
        # QT_ANDROID_ABIS ${CMAKE_ANDROID_ARCH_ABI}
        # QT_ANDROID_SDK_BUILD_TOOLS_REVISION
        QT_ANDROID_MIN_SDK_VERSION ${beeCopter_QT_ANDROID_MIN_SDK_VERSION}
        QT_ANDROID_TARGET_SDK_VERSION ${beeCopter_QT_ANDROID_TARGET_SDK_VERSION}
        QT_ANDROID_COMPILE_SDK_VERSION ${beeCopter_QT_ANDROID_COMPILE_SDK_VERSION}
        QT_ANDROID_PACKAGE_NAME "${beeCopter_ANDROID_PACKAGE_NAME}"
        QT_ANDROID_PACKAGE_SOURCE_DIR "${beeCopter_ANDROID_PACKAGE_SOURCE_DIR}"
        QT_ANDROID_VERSION_NAME "${CMAKE_PROJECT_VERSION}"
        QT_ANDROID_VERSION_CODE ${ANDROID_VERSION_CODE}
        QT_ANDROID_APP_NAME "${CMAKE_PROJECT_NAME}"
        QT_ANDROID_APP_ICON "@drawable/icon"
        # QT_QML_IMPORT_PATH
        QT_QML_ROOT_PATH "${CMAKE_SOURCE_DIR}"
        # QT_ANDROID_SYSTEM_LIBS_PREFIX
)

# if(CMAKE_BUILD_TYPE STREQUAL "Debug")
#     set(QT_ANDROID_APPLICATION_ARGUMENTS)
# endif()

list(APPEND QT_ANDROID_MULTI_ABI_FORWARD_VARS beeCopter_STABLE_BUILD QT_HOST_PATH)

# ----------------------------------------------------------------------------
# Android OpenSSL Libraries
# ----------------------------------------------------------------------------
CPMAddPackage(
    NAME android_openssl
    GITHUB_REPOSITORY KDAB/android_openssl
    GIT_TAG b71f1470962019bd89534a2919f5925f93bc5779
)

if(android_openssl_ADDED)
    include(${android_openssl_SOURCE_DIR}/android_openssl.cmake)
    add_android_openssl_libraries(${CMAKE_PROJECT_NAME})
    message(STATUS "beeCopter: Android OpenSSL libraries added")
else()
    message(WARNING "beeCopter: Failed to add Android OpenSSL libraries")
endif()

# ----------------------------------------------------------------------------
# Android Permissions
# ----------------------------------------------------------------------------

if(beeCopter_ENABLE_BLUETOOTH)
    qt_add_android_permission(${CMAKE_PROJECT_NAME}
        NAME android.permission.BLUETOOTH_SCAN
        ATTRIBUTES
            minSdkVersion 31
            usesPermissionFlags neverForLocation
    )
    qt_add_android_permission(${CMAKE_PROJECT_NAME}
        NAME android.permission.BLUETOOTH_CONNECT
        ATTRIBUTES
            minSdkVersion 31
            usesPermissionFlags neverForLocation
    )
endif()

if(NOT beeCopter_NO_SERIAL_LINK)
    qt_add_android_permission(${CMAKE_PROJECT_NAME}
        NAME android.permission.USB_PERMISSION
    )
endif()

# Need MulticastLock to receive broadcast UDP packets
qt_add_android_permission(${CMAKE_PROJECT_NAME}
    NAME android.permission.CHANGE_WIFI_MULTICAST_STATE
)

# Needed to keep working while 'asleep'
qt_add_android_permission(${CMAKE_PROJECT_NAME}
    NAME android.permission.WAKE_LOCK
)

# Needed for read/write to SD Card Path in AppSettings
qt_add_android_permission(${CMAKE_PROJECT_NAME}
    NAME android.permission.WRITE_EXTERNAL_STORAGE
    ATTRIBUTES
        maxSdkVersion 32
)
qt_add_android_permission(${CMAKE_PROJECT_NAME}
    NAME android.permission.READ_EXTERNAL_STORAGE
    ATTRIBUTES
        maxSdkVersion 33
)
qt_add_android_permission(${CMAKE_PROJECT_NAME}
    NAME android.permission.MANAGE_EXTERNAL_STORAGE
)

# Joystick
qt_add_android_permission(${CMAKE_PROJECT_NAME}
    NAME android.permission.VIBRATE
)

message(STATUS "beeCopter: Android platform configuration applied")
