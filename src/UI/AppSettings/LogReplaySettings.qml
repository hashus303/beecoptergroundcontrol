import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls

RowLayout {
    spacing: _colSpacing

    function saveSettings() {
        console.log(logField.text)
        subEditConfig.filename = logField.text
    }

    beeCopterLabel { text: qsTr("Log File") }

    beeCopterTextField {
        id: logField
        Layout.preferredWidth: _secondColumnWidth
        text: subEditConfig.filename
    }

    beeCopterButton {
        text: qsTr("Browse")
        onClicked: filePicker.openForLoad()
    }

    beeCopterFileDialog {
        id: filePicker
        title: qsTr("Select Telemetery Log")
        nameFilters: [ qsTr("Telemetry Logs (*.%1)").arg(_logFileExtension), qsTr("All Files (*)") ]
        folder: beeCopter.settingsManager.appSettings.telemetrySavePath

        property string _logFileExtension: beeCopter.settingsManager.appSettings.telemetryFileExtension

        onAcceptedForLoad: (file) => {
            logField.text = file
            close()
        }
    }
}
