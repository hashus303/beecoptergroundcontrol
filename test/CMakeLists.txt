# ============================================================================
# beeCopter Unit Tests
# ============================================================================

if(NOT beeCopter_BUILD_TESTING)
    return()
endif()

# ----------------------------------------------------------------------------
# Test Framework Sources
# ----------------------------------------------------------------------------
target_sources(${CMAKE_PROJECT_NAME}
    PRIVATE
        UnitTestList.cc
        UnitTestList.h
)

# ----------------------------------------------------------------------------
# Test Dependencies
# ----------------------------------------------------------------------------
find_package(Qt6 REQUIRED COMPONENTS Test)
target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE Qt6::Test)

target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

target_compile_definitions(${CMAKE_PROJECT_NAME} PRIVATE beeCopter_UNITTEST_BUILD)

# ----------------------------------------------------------------------------
# CTest Integration (CTest included in root CMakeLists.txt)
# ----------------------------------------------------------------------------
include(beeCopterTest)
include(Coverage)
include(Sanitizers)

# ============================================================================
# Test Subdirectories & Registration
# ============================================================================

# ----------------------------------------------------------------------------
# Unit Test Framework (must be first - provides MultiSignalSpy, etc.)
# ----------------------------------------------------------------------------
add_subdirectory(UnitTestFramework)
add_beeCopter_test(MultiSignalSpyTest LABELS Unit)
add_beeCopter_test(QmlTestRunner LABELS Unit)

# ----------------------------------------------------------------------------
# ADSB
# ----------------------------------------------------------------------------
add_subdirectory(ADSB)
add_beeCopter_test(ADSBTest LABELS Unit)

# ----------------------------------------------------------------------------
# AnalyzeView
# ----------------------------------------------------------------------------
add_subdirectory(AnalyzeView)
add_beeCopter_test(DataFlashParserTest LABELS Unit AnalyzeView RESOURCE_LOCK TempFiles)
add_beeCopter_test(ExifParserTest LABELS Unit AnalyzeView RESOURCE_LOCK TempFiles)
add_beeCopter_test(GeoTagControllerTest LABELS Unit AnalyzeView RESOURCE_LOCK TempFiles)
add_beeCopter_test(GeoTagDataTest LABELS Unit AnalyzeView)
add_beeCopter_test(GeoTagImageModelTest LABELS Unit AnalyzeView)
add_beeCopter_test(ULogParserTest LABELS Unit AnalyzeView RESOURCE_LOCK TempFiles)
add_beeCopter_test(LogDownloadTest LABELS Integration Vehicle RESOURCE_LOCK MockLink)
# add_beeCopter_test(MavlinkLogTest LABELS Integration)

# ----------------------------------------------------------------------------
# Camera
# ----------------------------------------------------------------------------
add_subdirectory(Camera)
add_beeCopter_test(beeCopterCameraManagerTest LABELS Integration Vehicle RESOURCE_LOCK MockLink)

# ----------------------------------------------------------------------------
# Comms
# ----------------------------------------------------------------------------
add_subdirectory(Comms)
add_beeCopter_test(beeCopterSerialPortInfoTest LABELS Unit Comms)

# ----------------------------------------------------------------------------
# FactSystem
# ----------------------------------------------------------------------------
add_subdirectory(FactSystem)
add_beeCopter_test(FactSystemTestGeneric LABELS Integration Vehicle RESOURCE_LOCK MockLink)
add_beeCopter_test(FactSystemTestPX4 LABELS Integration Vehicle RESOURCE_LOCK MockLink)
add_beeCopter_test(ParameterManagerTest LABELS Integration Vehicle SERIAL TIMEOUT 180)

# ----------------------------------------------------------------------------
# FollowMe
# ----------------------------------------------------------------------------
add_subdirectory(FollowMe)
add_beeCopter_test(FollowMeTest LABELS Integration Vehicle RESOURCE_LOCK MockLink)

# ----------------------------------------------------------------------------
# GPS
# ----------------------------------------------------------------------------
add_subdirectory(GPS)
# add_beeCopter_test(GpsTest LABELS Unit)  # Not registered in UnitTestList.cc

# ----------------------------------------------------------------------------
# Joystick
# ----------------------------------------------------------------------------
add_subdirectory(Joystick)
add_beeCopter_test(JoystickTest LABELS Unit)
add_beeCopter_test(JoystickManagerTest LABELS Unit)

# ----------------------------------------------------------------------------
# MAVLink
# ----------------------------------------------------------------------------
add_subdirectory(MAVLink)
add_beeCopter_test(StatusTextHandlerTest LABELS Unit MAVLink)
add_beeCopter_test(SigningTest LABELS Unit MAVLink)

# ----------------------------------------------------------------------------
# MissionManager
# ----------------------------------------------------------------------------
add_subdirectory(MissionManager)
add_beeCopter_test(CameraCalcTest LABELS Unit MissionManager)
add_beeCopter_test(CameraSectionTest LABELS Unit MissionManager)
add_beeCopter_test(CorridorScanComplexItemTest LABELS Unit MissionManager RESOURCE_LOCK PlanViewSettings)
# add_beeCopter_test(FWLandingPatternTest LABELS Unit MissionManager)
# add_beeCopter_test(LandingComplexItemTest LABELS Unit MissionManager)
# add_beeCopter_test(MissionCommandTreeEditorTest LABELS Unit MissionManager)
add_beeCopter_test(MissionCommandTreeTest LABELS Unit MissionManager)
add_beeCopter_test(MissionControllerManagerTest LABELS Integration MissionManager RESOURCE_LOCK MockLink)
add_beeCopter_test(MissionControllerTest LABELS Integration MissionManager RESOURCE_LOCK MockLink)
add_beeCopter_test(MissionItemTest LABELS Unit MissionManager)
add_beeCopter_test(MissionManagerTest LABELS Integration MissionManager SERIAL)
add_beeCopter_test(MissionSettingsTest LABELS Unit MissionManager)
add_beeCopter_test(PlanMasterControllerTest LABELS Integration MissionManager RESOURCE_LOCK MockLink)
add_beeCopter_test(beeCopterMapPolygonTest LABELS Unit MissionManager)
add_beeCopter_test(beeCopterMapPolylineTest LABELS Unit MissionManager)
# add_beeCopter_test(SectionTest LABELS Unit MissionManager)
add_beeCopter_test(SimpleMissionItemTest LABELS Unit MissionManager)
add_beeCopter_test(SpeedSectionTest LABELS Unit MissionManager)
add_beeCopter_test(StructureScanComplexItemTest LABELS Unit MissionManager RESOURCE_LOCK PlanViewSettings)
add_beeCopter_test(SurveyComplexItemTest LABELS Unit MissionManager RESOURCE_LOCK PlanViewSettings)
add_beeCopter_test(TransectStyleComplexItemTest LABELS Unit MissionManager RESOURCE_LOCK PlanViewSettings)
# add_beeCopter_test(VisualMissionItemTest LABELS Unit MissionManager)

# add_beeCopter_test(FileDialogTest LABELS Unit)
# add_beeCopter_test(MainWindowTest LABELS Integration Slow)
# add_beeCopter_test(MessageBoxTest LABELS Unit)

# ----------------------------------------------------------------------------
# QtLocationPlugin
# ----------------------------------------------------------------------------
add_subdirectory(QtLocationPlugin)
add_beeCopter_test(MapProviderTest LABELS Unit)
add_beeCopter_test(beeCopterCacheWorkerTest LABELS Unit)
add_beeCopter_test(beeCopterCachedTileSetTest LABELS Unit)
add_beeCopter_test(beeCopterMapEngineManagerArchiveTest LABELS Unit)
add_beeCopter_test(beeCopterTileCacheDatabaseTest LABELS Unit)
add_beeCopter_test(beeCopterTileSetTest LABELS Unit)
add_beeCopter_test(UrlFactoryTest LABELS Unit)

# ----------------------------------------------------------------------------
# Terrain
# ----------------------------------------------------------------------------
add_subdirectory(Terrain)
add_beeCopter_test(TerrainQueryTest LABELS Integration Network)
add_beeCopter_test(TerrainTileTest LABELS Unit)

# ----------------------------------------------------------------------------
# Utilities
# ----------------------------------------------------------------------------
add_subdirectory(Utilities)
# Audio
add_beeCopter_test(AudioOutputTest LABELS Unit Utilities)
# Compression
add_beeCopter_test(beeCopterArchiveModelTest LABELS Unit Utilities)
add_beeCopter_test(beeCopterCompressionTest LABELS Unit Utilities)
add_beeCopter_test(beeCopterStreamingDecompressionTest LABELS Unit Utilities)
# Network
add_beeCopter_test(beeCopterNetworkHelperTest LABELS Unit Utilities Network)
# Parsing
add_beeCopter_test(DataFlashUtilityTest LABELS Unit Utilities)
add_beeCopter_test(ExifUtilityTest LABELS Unit Utilities)
add_beeCopter_test(JsonParsingTest LABELS Unit Utilities)
add_beeCopter_test(ULogUtilityTest LABELS Unit Utilities)
# FileSystem
add_beeCopter_test(beeCopterArchiveWatcherTest LABELS Unit Utilities)
add_beeCopter_test(beeCopterCachedFileDownloadTest LABELS Integration Network Utilities)
add_beeCopter_test(beeCopterFileDownloadTest LABELS Integration Network Utilities)
add_beeCopter_test(beeCopterFileHelperTest LABELS Unit Utilities)
add_beeCopter_test(beeCopterFileWatcherTest LABELS Unit Utilities)
# Geo
add_beeCopter_test(GeoTest LABELS Unit Utilities)
# Platform (desktop only)
if(NOT ANDROID AND NOT IOS)
    add_beeCopter_test(PlatformTest LABELS Unit Utilities)
    add_beeCopter_test(RunGuardTest LABELS Unit Utilities)
    add_beeCopter_test(SignalHandlerTest LABELS Unit Utilities)
endif()
# Shape
add_beeCopter_test(ShapeTest LABELS Unit Utilities)

# ----------------------------------------------------------------------------
# Viewer3D
# ----------------------------------------------------------------------------
add_subdirectory(Viewer3D)
add_beeCopter_test(CityMapGeometryTest LABELS Unit Viewer3D)
add_beeCopter_test(OsmParserTest LABELS Unit Viewer3D)
add_beeCopter_test(OsmParserThreadTest LABELS Unit Viewer3D)
add_beeCopter_test(Viewer3DTerrainGeometryTest LABELS Unit Viewer3D)
add_beeCopter_test(Viewer3DTileQueryTest LABELS Unit Viewer3D)
add_beeCopter_test(GeoCoordinateTypeTest LABELS Unit Viewer3D)
add_beeCopter_test(Viewer3DInstancingTest LABELS Unit Viewer3D)
add_beeCopter_test(Viewer3DManagerTest LABELS Unit Viewer3D)
add_beeCopter_test(Viewer3DMapProviderTest LABELS Unit Viewer3D)

# ----------------------------------------------------------------------------
# Vehicle
# ----------------------------------------------------------------------------
add_subdirectory(Vehicle)
add_beeCopter_test(APMAirframeComponentControllerTest LABELS Integration Vehicle RESOURCE_LOCK MockLink)
add_beeCopter_test(ComponentInformationCacheTest LABELS Unit Vehicle)
add_beeCopter_test(ComponentInformationTranslationTest LABELS Unit Vehicle)
add_beeCopter_test(FTPControllerTest LABELS Integration Vehicle RESOURCE_LOCK MockLink)
add_beeCopter_test(FTPManagerTest LABELS Integration Vehicle SERIAL)
add_beeCopter_test(FirmwareUpgradeControllerTest LABELS Unit Vehicle)
# add_beeCopter_test(InitialConnectTest LABELS Integration Vehicle)
add_beeCopter_test(MAVLinkLogManagerTest LABELS Integration Vehicle RESOURCE_LOCK MockLink)
# add_beeCopter_test(RequestMessageTest LABELS Integration Vehicle)
# add_beeCopter_test(SendMavCommandWithHandlerTest LABELS Integration Vehicle)
# add_beeCopter_test(SendMavCommandWithSignalingTest LABELS Integration Vehicle)
add_beeCopter_test(VehicleLinkManagerTest LABELS Integration Vehicle RESOURCE_LOCK MockLink)

# Disabled tests
# add_beeCopter_test(FlightGearUnitTest LABELS Integration)
# add_beeCopter_test(LinkManagerTest LABELS Integration Comms)
# add_beeCopter_test(SendMavCommandTest LABELS Integration Vehicle)
# add_beeCopter_test(TCPLinkTest LABELS Integration Comms Network)
