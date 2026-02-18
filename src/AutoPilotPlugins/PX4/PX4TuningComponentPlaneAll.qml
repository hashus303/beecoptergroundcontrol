import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls

PX4TuningComponent {
    model: ListModel {
        ListElement {
            buttonText: qsTr("Rate Controller")
            tuningPage: "PX4TuningComponentPlaneRate.qml"
        }
        ListElement {
            buttonText: qsTr("Rate Controller")
            tuningPage: "PX4TuningComponentPlaneAttitude.qml"
        }
    }
}
