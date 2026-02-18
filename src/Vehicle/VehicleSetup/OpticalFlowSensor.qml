import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs

import beeCopter
import beeCopter.Controls

Item {
    beeCopterLabel {
        text: qsTr("Optical Flow Camera")
        font.bold: true
    }

    Image {
        source: globals.activeVehicle ? "image://beeCopterImages/" + globals.activeVehicle.id + "/" + globals.activeVehicle.flowImageIndex : ""
        width: parent.width * 0.5
        height: width * 0.75
        cache: false
        fillMode: Image.PreserveAspectFit
        anchors.centerIn: parent
    }
}
