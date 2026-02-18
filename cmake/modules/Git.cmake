# ----------------------------------------------------------------------------
# beeCopter Git Configuration
# Extracts version information and metadata from Git repository
# ----------------------------------------------------------------------------

find_package(Git QUIET)

if(NOT GIT_FOUND OR NOT EXISTS "${CMAKE_SOURCE_DIR}/.git")
    message(WARNING "beeCopter: Git not found or not a git repository. Using fallback version info.")
    set(beeCopter_GIT_BRANCH "unknown")
    set(beeCopter_GIT_HASH "0000000")
    set(beeCopter_APP_VERSION_STR "v0.0.0")
    set(beeCopter_APP_VERSION "0.0.0")
    set(beeCopter_APP_VERSION_MAJOR "0")
    set(beeCopter_APP_VERSION_MINOR "0")
    set(beeCopter_APP_VERSION_PATCH "0")
    string(TIMESTAMP beeCopter_APP_DATE "%Y-%m-%dT%H:%M:%S%z" UTC)
    configure_file(
        "${CMAKE_SOURCE_DIR}/src/beeCopter_version.h.in"
        "${CMAKE_BINARY_DIR}/beeCopter_version.h"
        @ONLY
    )
    return()
endif()

# Optionally update submodules during configuration
if(GIT_SUBMODULE)
    message(STATUS "Updating Git submodules...")
    execute_process(
        COMMAND ${GIT_EXECUTABLE} submodule update --init --recursive
        WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
        RESULT_VARIABLE GIT_SUBMODULE_RESULT
        OUTPUT_VARIABLE GIT_SUBMODULE_OUTPUT
        ERROR_VARIABLE GIT_SUBMODULE_ERROR
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if(NOT GIT_SUBMODULE_RESULT EQUAL 0)
        include(CMakePrintHelpers)
        cmake_print_variables(GIT_SUBMODULE_RESULT GIT_SUBMODULE_OUTPUT GIT_SUBMODULE_ERROR)
        message(FATAL_ERROR "Git submodule update failed with code ${GIT_SUBMODULE_RESULT}")
    endif()
    message(STATUS "Git submodules updated successfully")
endif()

include(CMakePrintHelpers)

# ----------------------------------------------------------------------------
# Extract Git Branch
# ----------------------------------------------------------------------------

execute_process(
    COMMAND ${GIT_EXECUTABLE} rev-parse --abbrev-ref @
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    OUTPUT_VARIABLE beeCopter_GIT_BRANCH
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
)
if(NOT beeCopter_GIT_BRANCH)
    set(beeCopter_GIT_BRANCH "unknown")
endif()
# cmake_print_variables(beeCopter_GIT_BRANCH)

# ----------------------------------------------------------------------------
# Extract Git Commit Hash
# ----------------------------------------------------------------------------
execute_process(
    COMMAND ${GIT_EXECUTABLE} rev-parse --short @
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    OUTPUT_VARIABLE beeCopter_GIT_HASH
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
)
if(NOT beeCopter_GIT_HASH)
    set(beeCopter_GIT_HASH "0000000")
endif()
# cmake_print_variables(beeCopter_GIT_HASH)

# ----------------------------------------------------------------------------
# Extract Version String from Git Tags
# ----------------------------------------------------------------------------
execute_process(
    COMMAND ${GIT_EXECUTABLE} describe --always --tags
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    OUTPUT_VARIABLE beeCopter_APP_VERSION_STR
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
)
if(NOT beeCopter_APP_VERSION_STR)
    set(beeCopter_APP_VERSION_STR "v0.0.0")
endif()
# cmake_print_variables(beeCopter_APP_VERSION_STR)

# ----------------------------------------------------------------------------
# Extract Clean Version Tag
# ----------------------------------------------------------------------------
execute_process(
    COMMAND ${GIT_EXECUTABLE} describe --always --abbrev=0
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    OUTPUT_VARIABLE beeCopter_APP_VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
)
if(NOT beeCopter_APP_VERSION)
    set(beeCopter_APP_VERSION "v0.0.0")
endif()
# cmake_print_variables(beeCopter_APP_VERSION)

# ----------------------------------------------------------------------------
# Extract Commit Date for Version Timestamp
# ----------------------------------------------------------------------------

if(beeCopter_STABLE_BUILD)
    set(beeCopter_APP_DATE_VERSION "${beeCopter_APP_VERSION}")
else()
    # Daily builds use date of last commit
    set(beeCopter_APP_DATE_VERSION "")
endif()

execute_process(
    COMMAND ${GIT_EXECUTABLE} log -1 --format=%aI ${beeCopter_APP_DATE_VERSION}
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    OUTPUT_VARIABLE beeCopter_APP_DATE
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
)
if(NOT beeCopter_APP_DATE)
    string(TIMESTAMP beeCopter_APP_DATE "%Y-%m-%dT%H:%M:%S%z" UTC)
endif()
# cmake_print_variables(beeCopter_APP_DATE)

# ----------------------------------------------------------------------------
# Parse Version Components (Major.Minor.Patch)
# ----------------------------------------------------------------------------
# Strip 'v' prefix if present (e.g., v1.2.3 -> 1.2.3)
string(REGEX REPLACE "^v" "" beeCopter_APP_VERSION_CLEAN "${beeCopter_APP_VERSION}")

# Extract version components using regex
if(beeCopter_APP_VERSION_CLEAN MATCHES "^([0-9]+)\\.([0-9]+)\\.([0-9]+)")
    set(beeCopter_APP_VERSION "${beeCopter_APP_VERSION_CLEAN}")
    set(beeCopter_APP_VERSION_MAJOR "${CMAKE_MATCH_1}")
    set(beeCopter_APP_VERSION_MINOR "${CMAKE_MATCH_2}")
    set(beeCopter_APP_VERSION_PATCH "${CMAKE_MATCH_3}")
else()
    # Fallback if version doesn't match expected format
    message(WARNING "beeCopter: Could not parse semantic version from Git tag: '${beeCopter_APP_VERSION_CLEAN}'. Using fallback 0.0.0")
    set(beeCopter_APP_VERSION "0.0.0")
    set(beeCopter_APP_VERSION_MAJOR "0")
    set(beeCopter_APP_VERSION_MINOR "0")
    set(beeCopter_APP_VERSION_PATCH "0")
endif()
# cmake_print_variables(beeCopter_APP_VERSION beeCopter_APP_VERSION_MAJOR beeCopter_APP_VERSION_MINOR beeCopter_APP_VERSION_PATCH)

# ----------------------------------------------------------------------------
# Generate Version Header
# ----------------------------------------------------------------------------
configure_file(
    "${CMAKE_SOURCE_DIR}/src/beeCopter_version.h.in"
    "${CMAKE_BINARY_DIR}/beeCopter_version.h"
    @ONLY
)
