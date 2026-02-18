import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import beeCopter
import beeCopter.Controls

Rectangle {
    height: visible ? (rowLayout.height + (_margins * 2)) : 0
    color: beeCopterPal.window

    property real _margins: ScreenTools.defaultFontPixelHeight / 4
    property var _logReplayLink: null

    function pickLogFile() {
        if (globals.activeVehicle) {
            mainWindow.showMessageDialog(qsTr("Log Replay"), qsTr("You must close all connections prior to replaying a log."))
            return
        }

        filePicker.openForLoad()
    }

    beeCopterPalette { id: beeCopterPal }

    beeCopterFileDialog {
        id: filePicker
        title: qsTr("Select Telemetery Log")
        nameFilters: [ qsTr("Telemetry Logs (*.%1)").arg(_logFileExtension), qsTr("All Files (*)") ]
        folder: beeCopter.settingsManager.appSettings.telemetrySavePath
        onAcceptedForLoad: (file) => {
            controller.link = beeCopter.linkManager.startLogReplay(file)
            close()
        }

        property string _logFileExtension: beeCopter.settingsManager.appSettings.telemetryFileExtension
    }

    LogReplayLinkController {
        id: controller

        onPercentCompleteChanged: (percentComplete) => slider.updatePercentComplete(percentComplete)
    }

    RowLayout {
        id: rowLayout
        anchors {
            margins: _margins
            top: parent.top
            left: parent.left
            right: parent.right
        }

        beeCopterButton {
            enabled: controller.link
            text: controller.isPlaying ? qsTr("Pause") : qsTr("Play")
            onClicked: controller.isPlaying = !controller.isPlaying
        }

        beeCopterComboBox {
            textRole: "text"
            currentIndex: 3

            model: ListModel {
                ListElement { text: "0.1";  value: 0.1 }
                ListElement { text: "0.25"; value: 0.25 }
                ListElement { text: "0.5";  value: 0.5 }
                ListElement { text: "1x";   value: 1 }
                ListElement { text: "2x";   value: 2 }
                ListElement { text: "5x";   value: 5 }
                ListElement { text: "10x";  value: 10 }
            }

            onActivated: (index) => { controller.playbackSpeed = model.get(currentIndex).value }
        }

        beeCopterLabel { text: controller.playheadTime }

        Slider {
            id: slider
            Layout.fillWidth: true
            from: 0
            to: 100
            enabled: controller.link

            property bool manualUpdate: false

            function updatePercentComplete(percentComplete) {
                manualUpdate = true
                value = percentComplete
                manualUpdate = false
            }

            onValueChanged: {
                if (!manualUpdate) {
                    controller.percentComplete = value
                }
            }
        }

        beeCopterLabel { text: controller.totalTime }

        beeCopterButton {
            text: qsTr("Load Telemetry Log")
            onClicked: pickLogFile()
            visible: !controller.link
        }

        beeCopterButton {
            text: qsTr("Close")
            onClicked: {
                var activeVehicle = beeCopter.multiVehicleManager.activeVehicle
                if (activeVehicle) {
                    activeVehicle.closeVehicle()
                }
                beeCopter.settingsManager.flyViewSettings.showLogReplayStatusBar.rawValue = false
            }
        }
    }
}
