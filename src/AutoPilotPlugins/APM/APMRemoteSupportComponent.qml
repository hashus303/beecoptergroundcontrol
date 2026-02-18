import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls
import beeCopter.FactControls

SetupPage {
    pageComponent:  pageComponent

    Component {
        id: pageComponent

        Rectangle {
            id:                 backgroundRectangle
            width:              availableWidth
            height:             elementsRow.height * 1.5
            color:              beeCopterPal.windowShade

            GridLayout {
                id:               elementsRow
                columns:          2

                anchors.left:           parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins:        ScreenTools.defaultFontPixelWidth

                columnSpacing:          ScreenTools.defaultFontPixelWidth
                rowSpacing:             ScreenTools.defaultFontPixelWidth

                beeCopterLabel {
                    visible:            beeCopter.settingsManager.mavlinkSettings.forwardMavlinkAPMSupportHostName.visible
                    text:               qsTr("Host name:")
                }
                FactTextField {
                    id:                     mavlinkForwardingHostNameField
                    fact:                   beeCopter.settingsManager.mavlinkSettings.forwardMavlinkAPMSupportHostName
                    Layout.preferredWidth:  ScreenTools.defaultFontPixelWidth * 40
                }
                beeCopterButton {
                    text:    qsTr("Connect")
                    enabled: !beeCopter.linkManager.mavlinkSupportForwardingEnabled

                    onPressed: {
                        beeCopter.linkManager.createMavlinkForwardingSupportLink()
                    }
                }
                beeCopterLabel {
                    visible:            beeCopter.linkManager.mavlinkSupportForwardingEnabled
                    text:               qsTr("Forwarding traffic: Mavlink traffic will keep being forwarded until application restarts")
                }
            }
        }
    }
}
