# ============================================================================
# State Machine Subsystem
# ============================================================================

target_sources(${CMAKE_PROJECT_NAME}
    PRIVATE
        beeCopterFinalState.cc
        beeCopterFinalState.h
        beeCopterState.cc
        beeCopterState.h
        beeCopterStateMachine.cc
        beeCopterStateMachine.h
        DelayState.cc
        DelayState.h
        FunctionState.cc
        FunctionState.h
        SendMavlinkCommandState.cc
        SendMavlinkCommandState.h
        SendMavlinkMessageState.cc
        SendMavlinkMessageState.h
        ShowAppMessageState.cc
        ShowAppMessageState.h
        WaitForMavlinkMessageState.cc
        WaitForMavlinkMessageState.h
)

target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
