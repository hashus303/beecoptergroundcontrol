import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import beeCopter
import beeCopter.FactControls
import beeCopter.Controls

RowLayout {
    id:         control
    spacing:    0

    property bool   showIndicator:        _multipleVehicles
    property var    _activeVehicle:       beeCopter.multiVehicleManager.activeVehicle
    property bool   _multipleVehicles:    beeCopter.multiVehicleManager.vehicles.count > 1
    property var    _vehicleModel:        [ ]

    Connections {
        target:         beeCopter.multiVehicleManager.vehicles
        function onCountChanged(count) { _updateVehicleModel() }
    }

    Component.onCompleted:      _updateVehicleModel()
    on_ActiveVehicleChanged:    _updateVehicleModel()

    RowLayout {
        Layout.fillWidth: true

        beeCopterColoredImage {
            width:      ScreenTools.defaultFontPixelWidth * 4
            height:     ScreenTools.defaultFontPixelHeight * 1.33
            fillMode:   Image.PreserveAspectFit
            mipmap:     true
            color:      beeCopterPal.text
            source:     "/InstrumentValueIcons/airplane.svg"
        }

        beeCopterLabel {
            text:               _activeVehicle ? qsTr("Vehicle") + " " + _activeVehicle.id : qsTr("N/A")
            font.pointSize:     ScreenTools.mediumFontPointSize
            Layout.alignment:   Qt.AlignCenter

            MouseArea {
                anchors.fill:   parent
                onClicked:      mainWindow.showIndicatorDrawer(vehicleSelectorDrawer, control)
            }
        }
    }

    Component {
        id: vehicleSelectorDrawer

        ToolIndicatorPage {
            showExpand: true

            contentComponent: Component {
                ColumnLayout {
                    spacing: ScreenTools.defaultFontPixelWidth / 2

                    Repeater {
                        model: _vehicleModel

                        beeCopterButton {
                            text:               modelData
                            Layout.fillWidth:   true

                            onClicked: {
                                var vehicleId = modelData.split(" ")[1]
                                var vehicle = beeCopter.multiVehicleManager.getVehicleById(vehicleId)
                                beeCopter.multiVehicleManager.activeVehicle = vehicle
                                mainWindow.closeIndicatorDrawer()
                            }
                        }
                    }
                }
            }

            expandedComponent: Component {
                SettingsGroupLayout {
                    Layout.fillWidth: true

                    FactCheckBoxSlider {
                        Layout.fillWidth:   true
                        text:               qsTr("Enable Multi-Vehicle Panel")
                        fact:               _enableMultiVehiclePanel
                        visible:            _enableMultiVehiclePanel.visible

                        property Fact _enableMultiVehiclePanel: beeCopter.settingsManager.appSettings.enableMultiVehiclePanel
                    }
                }
            }
        }
    }

    function _updateVehicleModel() {
        var newModel = [ ]
        if (_multipleVehicles) {
            for (var i = 0; i < beeCopter.multiVehicleManager.vehicles.count; i++) {
                var vehicle = beeCopter.multiVehicleManager.vehicles.get(i)
                newModel.push(qsTr("Vehicle") + " " + vehicle.id)
            }
        }
        _vehicleModel = newModel
    }
}
