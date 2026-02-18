import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls

ColumnLayout {
    spacing: _rowSpacing

    function saveSettings() {
        // No need
    }

    beeCopterLabel {
        Layout.preferredWidth: _secondColumnWidth
        Layout.fillWidth:       true
        font.pointSize:         ScreenTools.smallFontPointSize
        wrapMode:               Text.WordWrap
        text:                   qsTr("Note: For best perfomance, please disable AutoConnect to UDP devices on the General page.")
    }

    RowLayout {
        spacing: _colSpacing

        beeCopterLabel { text: qsTr("Port") }
        beeCopterTextField {
            id:                     portField
            text:                   subEditConfig.localPort.toString()
            focus:                  true
            Layout.preferredWidth:  _secondColumnWidth
            inputMethodHints:       Qt.ImhFormattedNumbersOnly
            onTextChanged:          subEditConfig.localPort = parseInt(portField.text)
        }
    }

    beeCopterLabel { text: qsTr("Server Addresses (optional)") }

    Repeater {
        model: subEditConfig.hostList

        delegate: RowLayout {
            spacing: _colSpacing

            beeCopterLabel {
                Layout.preferredWidth:  _secondColumnWidth
                text:                   modelData
            }

            beeCopterButton {
                text:       qsTr("Remove")
                onClicked:  subEditConfig.removeHost(modelData)
            }
        }
    }

    RowLayout {
        spacing: _colSpacing

        beeCopterTextField {
            id:                     hostField
            Layout.preferredWidth:  _secondColumnWidth
            placeholderText:        qsTr("Example: 127.0.0.1:14550")
        }
        beeCopterButton {
            text:       qsTr("Add Server")
            enabled:    hostField.text !== ""
            onClicked: {
                subEditConfig.addHost(hostField.text)
                hostField.text = ""
            }
        }
    }
}
