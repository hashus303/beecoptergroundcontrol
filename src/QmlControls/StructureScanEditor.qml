import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls
import beeCopter.FactControls
import beeCopter.FlightMap

// Editor for Survery mission items
Rectangle {
    id:         _root
    height:     visible ? (editorColumn.height + (_margin * 2)) : 0
    width:      availableWidth
    color:      beeCopterPal.windowShadeDark
    radius:     _radius

    // The following properties must be available up the hierarchy chain
    //property real   availableWidth    ///< Width for control
    //property var    missionItem       ///< Mission Item for editor

    property real   _margin:                    ScreenTools.defaultFontPixelWidth / 2
    property real   _fieldWidth:                ScreenTools.defaultFontPixelWidth * 10.5
    property var    _vehicle:                   beeCopter.multiVehicleManager.activeVehicle ? beeCopter.multiVehicleManager.activeVehicle : beeCopter.multiVehicleManager.offlineEditingVehicle
    property real   _cameraMinTriggerInterval:  missionItem.cameraCalc.minTriggerInterval.rawValue

    function polygonCaptureStarted() {
        missionItem.clearPolygon()
    }

    function polygonCaptureFinished(coordinates) {
        for (var i=0; i<coordinates.length; i++) {
            missionItem.addPolygonCoordinate(coordinates[i])
        }
    }

    function polygonAdjustVertex(vertexIndex, vertexCoordinate) {
        missionItem.adjustPolygonCoordinate(vertexIndex, vertexCoordinate)
    }

    function polygonAdjustStarted() { }
    function polygonAdjustFinished() { }

    beeCopterPalette { id: beeCopterPal; colorGroupEnabled: true }

    ColumnLayout {
        id:                 editorColumn
        anchors.margins:    _margin
        anchors.top:        parent.top
        anchors.left:       parent.left
        anchors.right:      parent.right

        beeCopterLabel {
                id:                 wizardLabel
                Layout.fillWidth:   true
                wrapMode:           Text.WordWrap
                horizontalAlignment:    Text.AlignHCenter
                text:               qsTr("Use the Polygon Tools to create the polygon which outlines the structure.")
                visible:        !missionItem.structurePolygon.isValid || missionItem.wizardMode
            }

        ColumnLayout {
            Layout.fillWidth:   true
            spacing:        _margin
            visible:        !wizardLabel.visible

            beeCopterTabBar {
                id:             tabBar
                Layout.fillWidth:   true

                Component.onCompleted: currentIndex = 0

                beeCopterTabButton { text: qsTr("Grid") }
                beeCopterTabButton { text: qsTr("Camera") }
            }

            ColumnLayout {
                Layout.fillWidth:   true
                spacing:            _margin
                visible:            tabBar.currentIndex == 0

                beeCopterLabel {
                    Layout.fillWidth:   true
                    text:           qsTr("Note: Polygon respresents structure surface not vehicle flight path.")
                    wrapMode:       Text.WordWrap
                    font.pointSize: ScreenTools.smallFontPointSize
                }

                beeCopterLabel {
                    Layout.fillWidth:   true
                    text:           qsTr("WARNING: Photo interval is below minimum interval (%1 secs) supported by camera.").arg(_cameraMinTriggerInterval.toFixed(1))
                    wrapMode:       Text.WordWrap
                    color:          beeCopterPal.warningText
                    visible:        missionItem.cameraShots > 0 && _cameraMinTriggerInterval !== 0 && _cameraMinTriggerInterval > missionItem.timeBetweenShots
                }

                CameraCalcGrid {
                    Layout.fillWidth:   true
                    cameraCalc:                     missionItem.cameraCalc
                    vehicleFlightIsFrontal:         false
                    distanceToSurfaceLabel:         qsTr("Scan Distance")
                    frontalDistanceLabel:           qsTr("Layer Height")
                    sideDistanceLabel:              qsTr("Trigger Distance")
                }

                SectionHeader {
                    id:             scanHeader
                    Layout.fillWidth:   true
                    text:           qsTr("Scan")
                }

                ColumnLayout {
                    Layout.fillWidth:   true
                    spacing:        _margin
                    visible:        scanHeader.checked

                    GridLayout {
                        Layout.fillWidth:   true
                        columnSpacing:  _margin
                        rowSpacing:     _margin
                        columns:        2

                        FactComboBox {
                            fact:               missionItem.startFromTop
                            indexModel:         true
                            model:              [ qsTr("Start Scan From Bottom"), qsTr("Start Scan From Top") ]
                            Layout.columnSpan:  2
                            Layout.fillWidth:   true
                        }

                        beeCopterLabel {
                            text:       qsTr("Structure Height")
                        }
                        FactTextField {
                            fact:               missionItem.structureHeight
                            Layout.fillWidth:   true
                        }

                        beeCopterLabel { text: qsTr("Scan Bottom Alt") }
                        AltitudeFactTextField {
                            fact:               missionItem.scanBottomAlt
                            altitudeMode:       beeCopter.AltitudeModeRelative
                            Layout.fillWidth:   true
                        }

                        beeCopterLabel { text: qsTr("Entrance/Exit Alt") }
                        AltitudeFactTextField {
                            fact:               missionItem.entranceAlt
                            altitudeMode:       beeCopter.AltitudeModeRelative
                            Layout.fillWidth:   true
                        }

                        beeCopterLabel {
                            text:       qsTr("Gimbal Pitch")
                            visible:    missionItem.cameraCalc.isManualCamera
                        }
                        FactTextField {
                            fact:               missionItem.gimbalPitch
                            Layout.fillWidth:   true
                            visible:            missionItem.cameraCalc.isManualCamera
                        }
                    }

                    Item {
                        height: ScreenTools.defaultFontPixelHeight / 2
                        width:  1
                    }

                    beeCopterButton {
                        text:       qsTr("Rotate entry point")
                        onClicked:  missionItem.rotateEntryPoint()
                    }
                } // Column - Scan

                SectionHeader {
                    id:             statsHeader
                    Layout.fillWidth:   true
                    text:           qsTr("Statistics")
                }

                Grid {
                    columns:        2
                    columnSpacing:  ScreenTools.defaultFontPixelWidth
                    visible:        statsHeader.checked

                    beeCopterLabel { text: qsTr("Layers") }
                    beeCopterLabel { text: missionItem.layers.valueString }

                    beeCopterLabel { text: qsTr("Layer Height") }
                    beeCopterLabel { text: missionItem.cameraCalc.adjustedFootprintFrontal.valueString + " " + beeCopter.unitsConversion.appSettingsHorizontalDistanceUnitsString }

                    beeCopterLabel { text: qsTr("Top Layer Alt") }
                    beeCopterLabel { text: beeCopter.unitsConversion.metersToAppSettingsVerticalDistanceUnits(missionItem.topFlightAlt).toFixed(1) + " " + beeCopter.unitsConversion.appSettingsHorizontalDistanceUnitsString }

                    beeCopterLabel { text: qsTr("Bottom Layer Alt") }
                    beeCopterLabel { text: beeCopter.unitsConversion.metersToAppSettingsVerticalDistanceUnits(missionItem.bottomFlightAlt).toFixed(1) + " " + beeCopter.unitsConversion.appSettingsHorizontalDistanceUnitsString }

                    beeCopterLabel { text: qsTr("Photo Count") }
                    beeCopterLabel { text: missionItem.cameraShots }

                    beeCopterLabel { text: qsTr("Photo Interval") }
                    beeCopterLabel { text: missionItem.timeBetweenShots.toFixed(1) + " " + qsTr("secs") }

                    beeCopterLabel { text: qsTr("Trigger Distance") }
                    beeCopterLabel { text: missionItem.cameraCalc.adjustedFootprintSide.valueString + " " + beeCopter.unitsConversion.appSettingsHorizontalDistanceUnitsString }
                }
            } // Grid Column

            ColumnLayout {
                Layout.fillWidth:   true
                spacing:            _margin
                visible:            tabBar.currentIndex == 1

                CameraCalcCamera {
                    Layout.fillWidth:   true
                    cameraCalc: missionItem.cameraCalc
                }
            }
        }
    }
}
