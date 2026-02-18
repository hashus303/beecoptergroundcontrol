import QtQuick
import QtQuick.Controls

import beeCopter
import beeCopter.Controls

// Statistics section for TransectStyleComplexItems
Grid {
    // The following properties must be available up the hierarchy chain
    //property var    missionItem       ///< Mission Item for editor

    columns:        2
    columnSpacing:  ScreenTools.defaultFontPixelWidth

    beeCopterLabel { text: qsTr("Survey Area") }
    beeCopterLabel { text: beeCopter.unitsConversion.squareMetersToAppSettingsAreaUnits(missionItem.coveredArea).toFixed(2) + " " + beeCopter.unitsConversion.appSettingsAreaUnitsString }

    beeCopterLabel { text: qsTr("Photo Count") }
    beeCopterLabel { text: missionItem.cameraShots }

    beeCopterLabel { text: qsTr("Photo Interval") }
    beeCopterLabel { text: missionItem.timeBetweenShots.toFixed(1) + " " + qsTr("secs") }

    beeCopterLabel { text: qsTr("Trigger Distance") }
    beeCopterLabel { text: missionItem.cameraCalc.adjustedFootprintFrontal.valueString + " " + missionItem.cameraCalc.adjustedFootprintFrontal.units }
}
