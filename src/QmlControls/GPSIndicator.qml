import QtQuick
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls

// Used as the base class control for nboth VehicleGPSIndicator and RTKGPSIndicator

Item {
    id:             control
    width:          gpsIndicatorRow.width
    anchors.top:    parent.top
    anchors.bottom: parent.bottom

    property var    _activeVehicle: beeCopter.multiVehicleManager.activeVehicle
    property bool   _rtkConnected:  beeCopter.gpsRtk.connected.value

    beeCopterPalette { id: beeCopterPal }

    Row {
        id:             gpsIndicatorRow
        anchors.top:    parent.top
        anchors.bottom: parent.bottom
        spacing:        ScreenTools.defaultFontPixelWidth / 2

        Row {
            anchors.top:    parent.top
            anchors.bottom: parent.bottom
            spacing:        -ScreenTools.defaultFontPixelWidth / 2

            beeCopterLabel {
                id:                     gpsLabel
                rotation:               90
                text:                   qsTr("RTK")
                color:                  beeCopterPal.windowTransparentText
                anchors.verticalCenter: parent.verticalCenter
                visible:                _rtkConnected
            }

            beeCopterColoredImage {
                id:                 gpsIcon
                width:              height
                anchors.top:        parent.top
                anchors.bottom:     parent.bottom
                source:             "/qmlimages/Gps.svg"
                fillMode:           Image.PreserveAspectFit
                sourceSize.height:  height
                opacity:            (_activeVehicle && _activeVehicle.gps.count.value >= 0) ? 1 : 0.5
                color:              beeCopterPal.windowTransparentText
            }
        }

        Column {
            id:                     gpsValuesColumn
            anchors.verticalCenter: parent.verticalCenter
            visible:                _activeVehicle && !isNaN(_activeVehicle.gps.hdop.value)
            spacing:                0

            beeCopterLabel {
                anchors.horizontalCenter:   hdopValue.horizontalCenter
                color:              beeCopterPal.windowTransparentText
                text:               _activeVehicle ? _activeVehicle.gps.count.valueString : ""
            }

            beeCopterLabel {
                id:     hdopValue
                color:  beeCopterPal.windowTransparentText
                text:   _activeVehicle ? _activeVehicle.gps.hdop.value.toFixed(1) : ""
            }
        }
    }

    MouseArea {
        anchors.fill:   parent
        onClicked:      mainWindow.showIndicatorDrawer(gpsIndicatorPage, control)
    }

    Component {
        id: gpsIndicatorPage

        GPSIndicatorPage { }
    }
}
