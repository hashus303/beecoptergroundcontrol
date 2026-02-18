import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls
import beeCopter.FlightMap
import beeCopter.FlyView

Item {
    property real   _margin:              ScreenTools.defaultFontPixelWidth / 2
    property real   _widgetHeight:        ScreenTools.defaultFontPixelHeight * 2.5
    property var    _guidedController:    globals.guidedControllerFlyView
    property var    _activeVehicleColor:  "green"
    property var    _activeVehicle:       beeCopter.multiVehicleManager.activeVehicle
    property var    selectedVehicles:     beeCopter.multiVehicleManager.selectedVehicles

    implicitHeight: vehicleList.contentHeight

    function armAvailable() {
        for (var i = 0; i < selectedVehicles.count; i++) {
            var vehicle = selectedVehicles.get(i)
            if (vehicle.armed === false) {
                return true
            }
        }
        return false
    }


    function disarmAvailable() {
        for (var i = 0; i < selectedVehicles.count; i++) {
            var vehicle = selectedVehicles.get(i)
            if (vehicle.armed === true) {
                return true
            }
        }
        return false
    }

    function startAvailable() {
        for (var i = 0; i < selectedVehicles.count; i++) {
            var vehicle = selectedVehicles.get(i)
            if (vehicle.armed === true && vehicle.flightMode !== vehicle.missionFlightMode){
                return true
            }
        }
        return false
    }

    function pauseAvailable() {
        for (var i = 0; i < selectedVehicles.count; i++) {
            var vehicle = selectedVehicles.get(i)
            if (vehicle.armed === true && vehicle.pauseVehicleSupported) {
                return true
            }
        }
        return false
    }

    function selectVehicle(vehicleId) {
        beeCopter.multiVehicleManager.selectVehicle(vehicleId)
    }

    function deselectVehicle(vehicleId) {
        beeCopter.multiVehicleManager.deselectVehicle(vehicleId)
    }

    function toggleSelect(vehicleId) {
        if (!vehicleSelected(vehicleId)) {
            selectVehicle(vehicleId)
        } else {
            deselectVehicle(vehicleId)
        }
    }

    function selectAll() {
        var vehicles = beeCopter.multiVehicleManager.vehicles
        for (var i = 0; i < vehicles.count; i++) {
            var vehicle = vehicles.get(i)
            var vehicleId = vehicle.id
            if (!vehicleSelected(vehicleId)) {
                selectVehicle(vehicleId)
            }
        }
    }

    function deselectAll() {
        beeCopter.multiVehicleManager.deselectAllVehicles()
    }

    function vehicleSelected(vehicleId) {
        for (var i = 0; i < selectedVehicles.count; i++ ) {
            var currentId = selectedVehicles.get(i).id
            if (vehicleId === currentId) {
                return true
            }
        }
        return false
    }

    beeCopterListView {
        id:                 vehicleList
        anchors.left:       parent.left
        anchors.right:      parent.right
        anchors.top:        parent.top
        anchors.bottom:     parent.bottom
        spacing:            ScreenTools.defaultFontPixelWidth * 0.75 // _layoutMargin
        orientation:        ListView.Vertical
        model:              beeCopter.multiVehicleManager.vehicles
        cacheBuffer:        _cacheBuffer < 0 ? 0 : _cacheBuffer
        clip:               true

        property real _cacheBuffer:     height * 2

        delegate: Rectangle {
            width:          vehicleList.width
            height:         innerColumn.height + _margin * 2
            color:          beeCopter.multiVehicleManager.activeVehicle == _vehicle ? _activeVehicleColor : beeCopterPal.button
            radius:         _margin
            border.width:   _vehicle && vehicleSelected(_vehicle.id) ? 2 : 0
            border.color:   beeCopterPal.text

            property var    _vehicle:   object

            beeCopterMouseArea {
                anchors.fill:       parent
                onClicked:          toggleSelect(_vehicle.id)
            }

            Column {
                id:                         innerColumn
                anchors.centerIn:           parent
                spacing:                    _margin

                RowLayout {
                    anchors.horizontalCenter:   parent.horizontalCenter
                    anchors.margins:    _margin
                    spacing:            _margin

                    IntegratedCompassAttitude {
                        id: compassWidget
                        compassRadius:              _widgetHeight / 2 - attitudeSize / 2
                        compassBorder:              0
                        attitudeSize:               ScreenTools.defaultFontPixelWidth / 2
                        attitudeSpacing:            attitudeSize / 2
                        usedByMultipleVehicleList:   true
                        vehicle:                     _vehicle
                    }

                    beeCopterLabel {
                        text: " | "
                        font.pointSize:       ScreenTools.largeFontPointSize
                        color:                beeCopterPal.text
                        Layout.alignment:     Qt.AlignHCenter
                    }

                    beeCopterLabel {
                        text:                 _vehicle ? _vehicle.id : ""
                        font.pointSize:       ScreenTools.largeFontPointSize
                        color:                beeCopterPal.text
                        Layout.alignment:     Qt.AlignHCenter
                    }

                    beeCopterLabel {
                        text: " | "
                        font.pointSize:       ScreenTools.largeFontPointSize
                        color:                beeCopterPal.text
                        Layout.alignment:     Qt.AlignHCenter
                    }

                    ColumnLayout {
                        spacing:              _margin
                        Layout.rightMargin:   compassWidget.width / 4
                        Layout.alignment:     Qt.AlignCenter

                        FlightModeMenu {
                            Layout.alignment:     Qt.AlignHCenter
                            font.pointSize:       ScreenTools.largeFontPointSize
                            color:                beeCopterPal.text
                            currentVehicle:       _vehicle
                        }

                        beeCopterLabel {
                            Layout.alignment:     Qt.AlignHCenter
                            text:                 _vehicle && _vehicle.armed ? qsTr("Armed") : qsTr("Disarmed")
                            color:                beeCopterPal.text
                        }
                    }
                }

                beeCopterFlickable {
                    anchors.horizontalCenter:   parent.horizontalCenter
                    width:          Math.min(contentWidth, vehicleList.width)
                    height:         control.height
                    contentWidth:   control.width
                    contentHeight:  control.height

                    TelemetryValuesBar {
                        id:                     control
                        settingsGroup:          factValueGrid.vehicleCardSettingsGroup
                        specificVehicleForCard: _vehicle
                    }
                }
            }
        }
    }
}
