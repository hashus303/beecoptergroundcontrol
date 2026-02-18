# ============================================================================
# QML Controls Module
# Reusable QML UI controls and controllers
# ============================================================================

target_sources(${CMAKE_PROJECT_NAME}
    PRIVATE
        EditPositionDialogController.cc
        EditPositionDialogController.h
        FactValueGrid.cc
        FactValueGrid.h
        FlightPathSegment.cc
        FlightPathSegment.h
        HorizontalFactValueGrid.cc
        HorizontalFactValueGrid.h
        InstrumentValueData.cc
        InstrumentValueData.h
        MavlinkAction.cc
        MavlinkAction.h
        MavlinkActionManager.cc
        MavlinkActionManager.h
        ObjectListModelBase.cc
        ObjectListModelBase.h
        ParameterEditorController.cc
        ParameterEditorController.h
        beeCopterFenceCircle.cc
        beeCopterFenceCircle.h
        beeCopterFencePolygon.cc
        beeCopterFencePolygon.h
        beeCopterFileDialogController.cc
        beeCopterFileDialogController.h
        beeCopterGeoBoundingCube.cc
        beeCopterGeoBoundingCube.h
        beeCopterImageProvider.cc
        beeCopterImageProvider.h
        beeCopterMapCircle.cc
        beeCopterMapCircle.h
        beeCopterMapPalette.cc
        beeCopterMapPalette.h
        beeCopterMapPolygon.cc
        beeCopterMapPolygon.h
        beeCopterMapPolyline.cc
        beeCopterMapPolyline.h
        beeCopterPalette.cc
        beeCopterPalette.h
        beeCopterQGeoCoordinate.cc
        beeCopterQGeoCoordinate.h
        beeCopterQmlGlobal.cc
        beeCopterQmlGlobal.h
        QmlObjectListModel.cc
        QmlObjectListModel.h
        QmlUnitsConversion.h
        RCChannelMonitorController.cc
        RCChannelMonitorController.h
        RCToParamDialogController.cc
        RCToParamDialogController.h
        ScreenToolsController.cc
        ScreenToolsController.h
        TerrainProfile.cc
        TerrainProfile.h
        ToolStripAction.cc
        ToolStripAction.h
        ToolStripActionList.cc
        ToolStripActionList.h
)

target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

# ----------------------------------------------------------------------------
# QML Controls Module
# ----------------------------------------------------------------------------
qt_add_library(beeCopterControlsModule STATIC)

set_source_files_properties(ScreenTools.qml PROPERTIES
    QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(beeCopterControlsModule
    URI beeCopter.Controls
    VERSION 1.0
    RESOURCE_PREFIX /qml
    QML_FILES
        AltModeCombo.qml
        AltModeDialog.qml
        AppSettings.qml
        APMSubMotorDisplay.qml
        AppLogging.qml
        AutotuneUI.qml
        AxisMonitor.qml
        ClickableColor.qml
        ConfigButton.qml
        DeadMouseArea.qml
        DropButton.qml
        DropPanel.qml
        EditPositionDialog.qml
        ExclusiveGroupItem.qml
        FactSlider.qml
        FileButton.qml
        FlightModeMenu.qml
        HeightIndicator.qml
        HorizontalFactValueGrid.qml
        IndicatorButton.qml
        InstrumentValueEditDialog.qml
        InstrumentValueLabel.qml
        InstrumentValueValue.qml
        JoystickThumbPad.qml
        KMLOrSHPFileDialog.qml
        LabelledButton.qml
        LabelledComboBox.qml
        LabelledLabel.qml
        LogReplayStatusBar.qml
        MainWindowSavedState.qml
        MAVLinkChart.qml
        MAVLinkMessageButton.qml
        MissionCommandDialog.qml
        MissionItemIndexLabel.qml
        MvPanelPage.qml
        OfflineMapButton.qml
        ParameterDiffDialog.qml
        ParameterEditor.qml
        ParameterEditorDialog.qml
        PIDTuning.qml
        PipState.qml
        PipView.qml
        PreFlightCheckButton.qml
        PreFlightCheckGroup.qml
        PreFlightCheckModel.qml
        beeCopterButton.qml
        beeCopterCheckBox.qml
        beeCopterCheckBoxSlider.qml
        beeCopterColoredImage.qml
        beeCopterColumnButton.qml
        beeCopterComboBox.qml
        beeCopterDelayButton.qml
        beeCopterDynamicObjectManager.qml
        beeCopterFileDialog.qml
        beeCopterFlickable.qml
        beeCopterFlickableScrollIndicator.qml
        beeCopterGroupBox.qml
        beeCopterLabel.qml
        beeCopterListView.qml
        beeCopterMapLabel.qml
        beeCopterMarqueeLabel.qml
        beeCopterMenu.qml
        beeCopterMenuItem.qml
        beeCopterMenuSeparator.qml
        beeCopterMouseArea.qml
        beeCopterMovableItem.qml
        beeCopterOptionsComboBox.qml
        beeCopterPageIndicator.qml
        beeCopterPopupDialog.qml
        beeCopterRadioButton.qml
        beeCopterRoundButton.qml
        beeCopterSimpleMessageDialog.qml
        beeCopterSlider.qml
        beeCopterSwipeView.qml
        beeCopterTabBar.qml
        beeCopterTabButton.qml
        beeCopterTextField.qml
        beeCopterToolBarButton.qml
        beeCopterToolInsets.qml
        RCChannelMonitor.qml
        RCToParamDialog.qml
        SectionHeader.qml
        SelectableControl.qml
        SettingsButton.qml
        SettingsGroupLayout.qml
        SetupPage.qml
        SliderSwitch.qml
        SubMenuButton.qml
        TimedProgressTracker.qml
        ToolIndicatorPage.qml
        ToolStrip.qml
        ToolStripDropPanel.qml
        ToolStripHoverButton.qml
        ValueSlider.qml
        VehicleRotationCal.qml
        VehicleSummaryRow.qml

# NOTE: Due to Windows limitations with set_source_files_properties and qt_add_qml_module,
# various QML files from other modules are temporarily included here.
# This will be revisited in a future release.

        # src/AnalyzeView/
        AnalyzePage.qml

        # src/FirstRunPromptDialogs/
        FirstRunPrompt.qml

        # src/PlanView/
        CameraCalcCamera.qml
        CameraCalcGrid.qml
        CameraSection.qml
        CorridorScanEditor.qml
        CorridorScanMapVisual.qml
        FWLandingPatternEditor.qml
        FWLandingPatternMapVisual.qml
        GeoFenceEditor.qml
        GeoFenceMapVisuals.qml
        MissionItemEditor.qml
        MissionItemMapVisual.qml
        MissionItemStatus.qml
        MissionSettingsEditor.qml
        MissionStats.qml
        PlanEditToolbar.qml
        PlanToolBarIndicators.qml
        PlanView.qml
        PlanViewRightPanel.qml
        RallyPointEditorHeader.qml
        RallyPointItemEditor.qml
        RallyPointMapVisuals.qml
        SimpleItemEditor.qml
        SimpleItemMapVisual.qml
        StructureScanEditor.qml
        StructureScanMapVisual.qml
        SurveyItemEditor.qml
        SurveyMapVisual.qml
        TakeoffItemMapVisual.qml
        TerrainStatus.qml
        TransectStyleComplexItemEditor.qml
        TransectStyleComplexItemStats.qml
        TransectStyleComplexItemTabBar.qml
        TransectStyleComplexItemTerrainFollow.qml
        TransectStyleMapVisuals.qml
        VTOLLandingPatternEditor.qml
        VTOLLandingPatternMapVisual.qml

        # src/UI/preferences/
        OfflineMapInfo.qml

        # src/UI/toolbar/
        BatteryIndicator.qml
        FlightModeIndicator.qml
        FlightModeMenuIndicator.qml
        FlyViewToolBar.qml
        FlyViewToolBarIndicators.qml
        GPSIndicator.qml
        GPSIndicatorPage.qml
        MainStatusIndicator.qml
        MainStatusIndicatorOfflinePage.qml
        ParameterDownloadProgress.qml
        PlanViewToolBar.qml
        RemoteIDIndicatorPage.qml
        SignalStrength.qml
        VehicleMessageList.qml

        # src/QtLocationPlugin/QMLControl/
        OfflineMapEditor.qml

        ScreenTools.qml
    NO_PLUGIN
)

# ----------------------------------------------------------------------------
# Control Configuration Resources
# ----------------------------------------------------------------------------
file(GLOB_RECURSE JSON_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/*.json)
qt_add_resources(${CMAKE_PROJECT_NAME} json_controls
    PREFIX "/json"
    FILES ${JSON_FILES}
)
