import QtQuick
import QtQuick.Controls

import beeCopter
import beeCopter.Controls

Rectangle {
    // Indicates whether calibration is valid for this control
    property bool calValid: false

    // Indicates whether the control is currently being calibrated
    property bool calInProgress: false

    // Text to show while calibration is in progress
    property string calInProgressText: qsTr("Hold Still")

    // Image source
    property var imageSource: ""

    property var __beeCopterPal: beeCopterPalette { colorGroupEnabled: enabled }

    color:  calInProgress ? "yellow" : (calValid ? "green" : "red")

    Rectangle {
        readonly property int inset: 5

        x:      inset
        y:      inset
        width:  parent.width - (inset * 2)
        height: parent.height - (inset * 2)
        color: beeCopterPal.windowShade

        Image {
            width:      parent.width
            height:     parent.height
            source:     imageSource
            fillMode:   Image.PreserveAspectFit
            smooth: true
        }

        beeCopterLabel {
            width:                  parent.width
            height:                 parent.height
            horizontalAlignment:    Text.AlignHCenter
            verticalAlignment:      Text.AlignBottom
            font.pointSize:         ScreenTools.mediumFontPointSize
            text:                   calInProgress ? calInProgressText : (calValid ? qsTr("Completed") : qsTr("Incomplete"))
        }
    }
}
