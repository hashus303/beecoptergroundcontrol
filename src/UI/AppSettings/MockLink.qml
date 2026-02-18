import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls

Rectangle {
    color:          beeCopterPal.window
    anchors.fill:   parent

    readonly property real _margins: ScreenTools.defaultFontPixelHeight

    beeCopterPalette { id: beeCopterPal; colorGroupEnabled: true }

    beeCopterFlickable {
        anchors.fill:   parent
        contentWidth:   column.width  + (_margins * 2)
        contentHeight:  column.height + (_margins * 2)
        clip:           true

        ColumnLayout {
            id:                 column
            anchors.margins:    _margins
            anchors.left:       parent.left
            anchors.top:        parent.top
            spacing:            ScreenTools.defaultFontPixelHeight / 4

            beeCopterCheckBox {
                id:             sendStatusText
                text:           qsTr("Send status text + voice")
            }
            beeCopterCheckBox {
                id:             enableCamera
                text:           qsTr("Enable camera")
            }
            beeCopterButton {
                text:               qsTr("PX4 Vehicle")
                Layout.fillWidth:   true
                onClicked:          beeCopter.startPX4MockLink(sendStatusText.checked, enableCamera.checked)
            }
            beeCopterButton {
                text:               qsTr("APM ArduCopter Vehicle")
                visible:            beeCopter.hasAPMSupport
                Layout.fillWidth:   true
                onClicked:          beeCopter.startAPMArduCopterMockLink(sendStatusText.checked, enableCamera.checked)
            }
            beeCopterButton {
                text:               qsTr("APM ArduPlane Vehicle")
                visible:            beeCopter.hasAPMSupport
                Layout.fillWidth:   true
                onClicked:          beeCopter.startAPMArduPlaneMockLink(sendStatusText.checked, enableCamera.checked)
            }
            beeCopterButton {
                text:               qsTr("APM ArduSub Vehicle")
                visible:            beeCopter.hasAPMSupport
                Layout.fillWidth:   true
                onClicked:          beeCopter.startAPMArduSubMockLink(sendStatusText.checked, enableCamera.checked)
            }
            beeCopterButton {
                text:               qsTr("APM ArduRover Vehicle")
                visible:            beeCopter.hasAPMSupport
                Layout.fillWidth:   true
                onClicked:          beeCopter.startAPMArduRoverMockLink(sendStatusText.checked, enableCamera.checked)
            }
            beeCopterButton {
                text:               qsTr("Generic Vehicle")
                Layout.fillWidth:   true
                onClicked:          beeCopter.startGenericMockLink(sendStatusText.checked, enableCamera.checked)
            }
            beeCopterButton {
                text:               qsTr("Stop One MockLink")
                Layout.fillWidth:   true
                onClicked:          beeCopter.stopOneMockLink()
            }
        }
    }
}
