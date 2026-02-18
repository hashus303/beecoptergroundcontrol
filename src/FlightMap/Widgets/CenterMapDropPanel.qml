import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtPositioning

import beeCopter
import beeCopter.Controls

ColumnLayout {
    id:         root
    spacing:    ScreenTools.defaultFontPixelWidth * 0.5

    property var    map
    property var    fitFunctions
    property bool   showMission:          true
    property bool   showAllItems:         true

    beeCopterLabel { text: qsTr("Center map on:") }

    beeCopterButton {
        text:               qsTr("Mission")
        Layout.fillWidth:   true
        visible:            showMission

        onClicked: {
            dropPanel.hide()
            fitFunctions.fitMapViewportToMissionItems()
        }
    }

    beeCopterButton {
        text:               qsTr("All items")
        Layout.fillWidth:   true
        visible:            showAllItems

        onClicked: {
            dropPanel.hide()
            fitFunctions.fitMapViewportToAllItems()
        }
    }

    beeCopterButton {
        text:               qsTr("Launch")
        Layout.fillWidth:   true

        onClicked: {
            dropPanel.hide()
            map.center = fitFunctions.fitHomePosition()
        }
    }

    beeCopterButton {
        text:               qsTr("Vehicle")
        Layout.fillWidth:   true
        enabled:            globals.activeVehicle && globals.activeVehicle.coordinate.isValid

        onClicked: {
            dropPanel.hide()
            map.center = globals.activeVehicle.coordinate
        }
    }

    beeCopterButton {
        text:               qsTr("Current Location")
        Layout.fillWidth:   true
        enabled:            map.gcsPosition.isValid

        onClicked: {
            dropPanel.hide()
            map.center = map.gcsPosition
        }
    }

    beeCopterButton {
        text:               qsTr("Specified Location")
        Layout.fillWidth:   true

        onClicked: {
            dropPanel.hide()
            map.centerToSpecifiedLocation()
        }
    }
} // Column
