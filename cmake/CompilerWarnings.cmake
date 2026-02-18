# ----------------------------------------------------------------------------
# beeCopter Compiler Warnings Configuration
# Sets warning levels and treats warnings as errors for beeCopter source code
# while allowing more lenient settings for third-party dependencies
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# beeCopter Warning Flags for Main Source Code
# ----------------------------------------------------------------------------
function(beeCopter_set_warning_flags target)
    if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        target_compile_options(${target} PRIVATE
            -Wall                       # Enable common warnings
            -Wextra                     # Enable extra warnings
            -Werror                     # Treat warnings as errors
            -Wshadow                    # Warn about variable shadowing
            #-Wnon-virtual-dtor          # Warn about non-virtual destructors
            #-Wold-style-cast            # Warn about C-style casts
            #-Wcast-align                # Warn about pointer cast alignment
            #-Wunused                    # Warn about unused entities
            #-Woverloaded-virtual        # Warn about overloaded virtual functions
            #-Wsign-conversion           # Warn about sign conversions
            #-Wmisleading-indentation    # Warn about misleading indentation
            #-Wduplicated-cond           # Warn about duplicated conditions (GCC/Clang 14+)
            #-Wduplicated-branches       # Warn about duplicated branches (GCC/Clang 14+)
            #-Wnull-dereference          # Warn about null pointer dereferences
            #-Wformat=2                  # Strict format string checking
            #-Wconversion                # Warn about implicit conversions
            #-Wdouble-promotion          # Warn about float to double promotion
            #-Wswitch-enum               # Warn about missing enum cases in switch

            # The following warnings are temporarily disabled due to known issues in beeCopter codebase that need to be addressed
            -Wno-switch

            # Qt-specific warnings to disable
            -Wno-deprecated-enum-enum-conversion  # Qt has some deprecated enum conversions
            -Wno-unknown-warning-option           # Don't error on unknown warning options
        )

    elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        target_compile_options(${target} PRIVATE
            -Wall                       # Enable common warnings
            -Wextra                     # Enable extra warnings
            -Werror                     # Treat warnings as errors
            -Wshadow                    # Warn about variable shadowing
            #-Wnon-virtual-dtor          # Warn about non-virtual destructors
            #-Wold-style-cast            # Warn about C-style casts
            #-Wcast-align                # Warn about pointer cast alignment
            #-Wunused                    # Warn about unused entities
            #-Woverloaded-virtual        # Warn about overloaded virtual functions
            #-Wsign-conversion           # Warn about sign conversions
            #-Wmisleading-indentation    # Warn about misleading indentation
            #-Wduplicated-cond           # Warn about duplicated conditions
            #-Wduplicated-branches       # Warn about duplicated branches
            #-Wlogical-op                # Warn about logical operations
            #-Wnull-dereference          # Warn about null pointer dereferences
            #-Wuseless-cast              # Warn about useless casts
            #-Wformat=2                  # Strict format string checking
            #-Wdouble-promotion          # Warn about float to double promotion
            #-Wconversion                # Warn about implicit conversions
            #-Wswitch-enum               # Warn about missing enum cases in switch
        )

    elseif(MSVC)
        target_compile_options(${target} PRIVATE
            /W2                         # Warning level 2 (ultimate target is level 3)
            /WX                         # Treat warnings as errors

            # The following warnings are temporarily disabled due to known issues in beeCopter codebase that need to be addressed
            /wd4996                     # deprecated functions (strncpy, etc)
            /wd4389                     # signed/unsigned mismatch

            # Disable specific warnings
            /wd4068                     # unknown pragma (for clang pragmas)
            /wd4127                     # conditional expression is constant (Qt macros)
            /wd4251                     # needs to have dll-interface (Qt classes)
            /wd4275                     # non dll-interface class used as base (Qt classes)
            /wd4819                     # character encoding issues (non-issue for UTF-8)
        )
    endif()
endfunction()

# ----------------------------------------------------------------------------
# Lenient Warning Settings for Third-Party Dependencies (CPM packages)
#
# Use this function to suppress warnings for compiled (STATIC/SHARED) third-party
# library targets. Call it after CPMAddPackage() with the target name.
#
# DO NOT use this for header-only (INTERFACE) libraries. Because INTERFACE compile
# options propagate to all consuming targets, calling this on an INTERFACE library
# would silently suppress ALL warnings in beeCopter's own source code.
#
# For header-only dependencies, use SYSTEM include directories instead:
#   target_include_directories(${CMAKE_PROJECT_NAME} SYSTEM PRIVATE ${dep_SOURCE_DIR}/include)
# This tells the compiler to treat those headers as system headers, suppressing
# warnings within them without affecting beeCopter source code.
# ----------------------------------------------------------------------------
function(beeCopter_disable_dependency_warnings target)
    # Check if target exists
    if(NOT TARGET ${target})
        message(WARNING "beeCopter_disable_dependency_warnings: Target '${target}' does not exist")
        return()
    endif()

    # Get target type
    get_target_property(_target_type ${target} TYPE)
    if(_target_type STREQUAL "INTERFACE_LIBRARY")
        message(WARNING "beeCopter_disable_dependency_warnings: Target '${target}' is an INTERFACE library. "
            "Warning flags would propagate to all consumers. Use SYSTEM include directories instead.")
        return()
    endif()

    set(_scope PRIVATE)

    if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        target_compile_options(${target} ${_scope}
            -w                          # Suppress all warnings
            -Wno-error                  # Don't treat warnings as errors
            -Wno-unknown-warning-option # Don't warn about unknown warning options
        )

    elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        target_compile_options(${target} ${_scope}
            -w                          # Suppress all warnings
            -Wno-error                  # Don't treat warnings as errors
        )

    elseif(MSVC)
        target_compile_options(${target} ${_scope}
            /W0                         # Disable all warnings
            /WX-                        # Don't treat warnings as errors
        )
    endif()
endfunction()

# ----------------------------------------------------------------------------
# Apply warning flags to beeCopter main target
# Called from main CMakeLists.txt after target is created
# ----------------------------------------------------------------------------
function(beeCopter_apply_warning_flags)
    if(beeCopter_ENABLE_WERROR)
        message(STATUS "beeCopter: Enabling warnings as errors for main source code")
        beeCopter_set_warning_flags(${CMAKE_PROJECT_NAME})
    else()
        message(STATUS "beeCopter: Warnings as errors disabled (set beeCopter_ENABLE_WERROR=ON to enable)")
    endif()
endfunction()
