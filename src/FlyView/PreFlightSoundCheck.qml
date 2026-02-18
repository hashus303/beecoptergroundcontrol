import QtQuick

import beeCopter
import beeCopter.Controls

PreFlightCheckButton {
    name:                   qsTr("Sound output")
    manualText:             qsTr("beeCopter audio output enabled. System audio output enabled, too?")
    telemetryTextFailure:   qsTr("beeCopter audio output is disabled. Please enable it under application settings->general to hear audio warnings!")
    telemetryFailure:       beeCopter.settingsManager.appSettings.audioMuted.rawValue
}
