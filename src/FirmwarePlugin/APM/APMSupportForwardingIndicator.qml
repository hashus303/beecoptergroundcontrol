import QtQuick
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls

//-------------------------------------------------------------------------
//-- Telemetry RSSI
Item {
    id:             control
    anchors.top:    parent.top
    anchors.bottom: parent.bottom
    width:          forwardingSupportIcon.width * 1.1

    property bool showIndicator: beeCopter.linkManager.mavlinkSupportForwardingEnabled

    Component {
        id: forwardingSupportInfoPage

        ToolIndicatorPage {
            contentComponent: SettingsGroupLayout {
                beeCopterLabel { text: qsTr("Mavlink traffic is being forwarded to a support server") }

                LabelledLabel {
                    label:      qsTr("Server name:")
                    labelText:  beeCopter.settingsManager.mavlinkSettings.forwardMavlinkAPMSupportHostName.value
                }
            }
        }
    }

    Image {
        id:                 forwardingSupportIcon
        anchors.top:        parent.top
        anchors.bottom:     parent.bottom
        width:              height
        sourceSize.height:  height
        source:             "/qmlimages/ForwardingSupportIconGreen.svg"
        fillMode:           Image.PreserveAspectFit
    }

    MouseArea {
        anchors.fill: parent
        onClicked:      mainWindow.showIndicatorDrawer(forwardingSupportInfoPage, control)
    }
}
