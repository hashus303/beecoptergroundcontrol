# ============================================================================
# Flight Map Module
# Map widgets, vehicle indicators, and mission visualization
# ============================================================================

qt_add_library(FlightMapModule STATIC)

qt_add_qml_module(FlightMapModule
    URI beeCopter.FlightMap
    VERSION 1.0
    RESOURCE_PREFIX /qml
    QML_FILES
        MapItems/CameraTriggerIndicator.qml
        MapItems/CustomMapItems.qml
        MapItems/MapLineArrow.qml
        MapItems/MissionItemIndicator.qml
        MapItems/MissionItemIndicatorDrag.qml
        MapItems/MissionLineView.qml
        MapItems/PlanMapItems.qml
        MapItems/ProximityRadarMapView.qml
        MapItems/beeCopterMapCircleVisuals.qml
        MapItems/beeCopterMapPolygonVisuals.qml
        MapItems/beeCopterMapPolylineVisuals.qml
        MapItems/SplitIndicator.qml
        MapItems/VehicleMapItem.qml
        Widgets/CenterMapDropButton.qml
        Widgets/CenterMapDropPanel.qml
        Widgets/CompassDial.qml
        Widgets/CompassHeadingIndicator.qml
        Widgets/HorizontalCompassAttitude.qml
        Widgets/IntegratedAttitudeIndicator.qml
        Widgets/IntegratedCompassAttitude.qml
        Widgets/MapFitFunctions.qml
        Widgets/PhotoVideoControl.qml
        Widgets/beeCopterArtificialHorizon.qml
        Widgets/beeCopterAttitudeWidget.qml
        Widgets/beeCopterCompassWidget.qml
        Widgets/beeCopterPitchIndicator.qml
        Widgets/VerticalCompassAttitude.qml
        FlightMap.qml
        MapScale.qml
    NO_PLUGIN
)
