import QtQuick
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls

Rectangle {
    color:          beeCopterPal.window
    anchors.fill:   parent

    readonly property real _margins: ScreenTools.defaultFontPixelHeight

    beeCopterPalette { id: beeCopterPal; colorGroupEnabled: true }

    beeCopterFlickable {
        anchors.margins:    _margins
        anchors.fill:       parent
        contentWidth:       grid.width
        contentHeight:      grid.height
        clip:               true

        GridLayout {
            id:         grid
            columns:    2

            beeCopterLabel { text: qsTr("beeCopter User Guide") }
            beeCopterLabel {
                linkColor:          beeCopterPal.text
                text:               "<a href=\"https://docs.beeCopter.com\">https://docs.beeCopter.com</a>"
                onLinkActivated:    (link) => Qt.openUrlExternally(link)
            }

            beeCopterLabel { text: qsTr("PX4 Users Discussion Forum") }
            beeCopterLabel {
                linkColor:          beeCopterPal.text
                text:               "<a href=\"http://discuss.px4.io/c/beeCopter\">http://discuss.px4.io/c/beeCopter</a>"
                onLinkActivated:    (link) => Qt.openUrlExternally(link)
            }

            beeCopterLabel { text: qsTr("ArduPilot Users Discussion Forum") }
            beeCopterLabel {
                linkColor:          beeCopterPal.text
                text:               "<a href=\"https://discuss.ardupilot.org/c/ground-control-software/beeCopter\">https://discuss.ardupilot.org/c/ground-control-software/beeCopter</a>"
                onLinkActivated:    (link) => Qt.openUrlExternally(link)
            }

            beeCopterLabel { text: qsTr("beeCopter Discord Channel") }
            beeCopterLabel {
                linkColor:          beeCopterPal.text
                text:               "<a href=\"https://discord.com/channels/1022170275984457759/1022185820683255908\">https://discord.com/channels/1022170275984457759/1022185820683255908</a>"
                onLinkActivated:    (link) => Qt.openUrlExternally(link)
            }
        }
    }
}
