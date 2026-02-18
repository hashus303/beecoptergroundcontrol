import QtQuick
import QtQuick.Controls

import beeCopter
import beeCopter.Controls

/// Provides UI for parameter download progress. This is overlayed on top of the FlyViewToolBar.

Item {
    id: control

    property var    _activeVehicle: beeCopter.multiVehicleManager.activeVehicle

    // Small parameter download progress bar
    Rectangle {
        anchors.bottom: parent.bottom
        height:         control.height * 0.05
        width:          _activeVehicle ? _activeVehicle.loadProgress * parent.width : 0
        color:          beeCopter.globalPalette.colorGreen
        visible:        !largeProgressBar.visible
    }

    // Large parameter download progress bar
    Rectangle {
        id:             largeProgressBar
        anchors.bottom: parent.bottom
        anchors.left:   parent.left
        anchors.right:  parent.right
        height:         parent.height
        color:          beeCopter.globalPalette.window
        visible:        _showLargeProgress

        property bool _initialDownloadComplete: _activeVehicle ? _activeVehicle.initialConnectComplete : true
        property bool _userHide:                false
        property bool _showLargeProgress:       !_initialDownloadComplete && !_userHide && beeCopter.globalPalette.globalTheme === beeCopterPalette.Light

        Connections {
            target: beeCopter.multiVehicleManager
            function onActiveVehicleChanged(activeVehicle) { largeProgressBar._userHide = false }
        }

        Rectangle {
            anchors.top:    parent.top
            anchors.bottom: parent.bottom
            width:          _activeVehicle ? _activeVehicle.loadProgress * parent.width : 0
            color:          beeCopter.globalPalette.colorGreen
        }

        beeCopterLabel {
            anchors.centerIn:   parent
            text:               qsTr("Downloading")
            font.pointSize:     ScreenTools.largeFontPointSize
        }

        beeCopterLabel {
            anchors.margins:    _margin
            anchors.right:      parent.right
            anchors.bottom:     parent.bottom
            text:               qsTr("Click anywhere to hide")

            property real _margin: ScreenTools.defaultFontPixelWidth / 2
        }

        MouseArea {
            anchors.fill:   parent
            onClicked:      parent._userHide = true
        }
    }
}
