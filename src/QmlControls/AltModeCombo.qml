import QtQuick

import beeCopter
import beeCopter.Controls

beeCopterComboBox {
    required property int altitudeMode
    required property var vehicle

    textRole: "modeName"

    onActivated: (index) => {
        let modeValue = altModeModel.get(index).modeValue
        altitudeMode = modeValue
    }

    ListModel {
        id: altModeModel

        ListElement {
            modeName: qsTr("Relative")
            modeValue: beeCopter.AltitudeModeRelative
        }
        ListElement {
            modeName: qsTr("Absolute")
            modeValue: beeCopter.AltitudeModeAbsolute
        }
        ListElement {
            modeName: qsTr("Terrain")
            modeValue: beeCopter.AltitudeModeTerrainFrame
        }
        ListElement {
            modeName: qsTr("TerrainC")
            modeValue: beeCopter.AltitudeModeCalcAboveTerrain
        }
    }

    Component.onCompleted: {
        let removeModes = []

        if (!beeCopter.corePlugin.options.showMissionAbsoluteAltitude && altitudeMode != beeCopter.AltitudeModeAbsolute) {
            removeModes.push(beeCopter.AltitudeModeAbsolute)
        }
        if (!vehicle.supportsTerrainFrame) {
            removeModes.push(beeCopter.AltitudeModeTerrainFrame)
        }

        // Remove modes specified by consumer
        for (var i=0; i<removeModes.length; i++) {
            for (var j=0; j<altModeModel.count; j++) {
                if (altModeModel.get(j).modeValue == removeModes[i]) {
                    altModeModel.remove(j)
                    break
                }
            }
        }

        model = altModeModel

        // Find the specified alt mode in the model
        for (var k=0; k<altModeModel.count; k++) {
            if (altModeModel.get(k).modeValue == altitudeMode) {
                currentIndex = k
                break
            }
        }
    }
}
