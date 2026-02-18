import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import beeCopter
import beeCopter.Controls

Rectangle {
    id: _root
    width: parent.width
    height: ScreenTools.toolbarHeight
    color: beeCopterPal.toolbarBackground

    property var planMasterController

    property var _activeVehicle: beeCopter.multiVehicleManager.activeVehicle
    property real _controllerProgressPct: planMasterController.missionController.progressPct

    beeCopterPalette { id: beeCopterPal }

    /// Bottom single pixel divider
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: "black"
        visible: beeCopterPal.globalTheme === beeCopterPalette.Light
    }

    beeCopterToolBarButton {
        id: beeCopterButton
        height: parent.height
        icon.source: "/res/beeCopterLogoFull.svg"
        logo: true
        onClicked: mainWindow.showToolSelectDialog()
    }

    beeCopterFlickable {
        id: toolsFlickable
        anchors.bottomMargin: 1
        anchors.left: beeCopterButton.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        contentWidth: toolIndicators.width
        flickableDirection: Flickable.HorizontalFlick

        PlanToolBarIndicators {
            id: toolIndicators
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            planMasterController: _root.planMasterController
        }
    }

    // Small mission download progress bar
    Rectangle {
        id: progressBar
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        height: 4
        width: _controllerProgressPct * parent.width
        color: beeCopterPal.colorGreen
        visible: false

        onVisibleChanged: {
            if (visible) {
                largeProgressBar._userHide = false
            }
        }
    }

    // Large mission download progress bar
    Rectangle {
        id: largeProgressBar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height
        color: beeCopterPal.window
        visible: _showLargeProgress

        property bool _userHide: false
        property bool _showLargeProgress: progressBar.visible && !_userHide && beeCopterPal.globalTheme === beeCopterPalette.Light

        Connections {
            target: beeCopter.multiVehicleManager
            function onActiveVehicleChanged(activeVehicle) { largeProgressBar._userHide = false }
        }

        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: _controllerProgressPct * parent.width
            color: beeCopterPal.colorGreen
        }

        beeCopterLabel {
            anchors.centerIn: parent
            text: qsTr("Syncing Mission")
            font.pointSize: ScreenTools.largeFontPointSize
            visible: _controllerProgressPct !== 1
        }

        beeCopterLabel {
            anchors.centerIn: parent
            text: qsTr("Done")
            font.pointSize: ScreenTools.largeFontPointSize
            visible: _controllerProgressPct === 1
        }

        beeCopterLabel {
            anchors.margins: _margin
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            text: qsTr("Click anywhere to hide")

            property real _margin: ScreenTools.defaultFontPixelWidth / 2
        }

        MouseArea {
            anchors.fill: parent
            onClicked: largeProgressBar._userHide = true
        }
    }

    // Progress bar
    Connections {
        target: planMasterController.missionController

        function onProgressPctChanged(progressPct) {
            if (progressPct === 1) {
                if (_root.visible) {
                    resetProgressTimer.start()
                } else {
                    progressBar.visible = false
                }
            } else if (progressPct > 0) {
                progressBar.visible = true
            }
        }
    }

    Timer {
        id: resetProgressTimer
        interval: 3000
        onTriggered: progressBar.visible = false
    }
}
