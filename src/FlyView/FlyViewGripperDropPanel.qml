import QtQuick
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls

ColumnLayout {
    spacing: ScreenTools.defaultFontHeight / 2

    property var _activeVehicle: beeCopter.multiVehicleManager.activeVehicle
    property var _buttonTitles: [qsTr("Release"), qsTr("Grab"), qsTr("Hold")]
    property var _buttonActions: [beeCopterMAVLink.GripperActionRelease, beeCopterMAVLink.GripperActionGrab, beeCopterMAVLink.GripperActionHold]

    Repeater {
        model: _buttonTitles

        beeCopterDelayButton {
            Layout.fillWidth:   true
            text:               _buttonTitles[index]

            onActivated: {
                _activeVehicle.sendGripperAction(_buttonActions[index])
                dropPanel.hide()
            }
        }
    }
}
