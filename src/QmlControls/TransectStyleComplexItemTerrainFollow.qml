import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls
import beeCopter.FactControls

ColumnLayout {
    spacing: _margin
    visible: tabBar.currentIndex === 2

    property var missionItem

    MouseArea {
        Layout.preferredWidth:  childrenRect.width
        Layout.preferredHeight: childrenRect.height

        onClicked: {
            var removeModes = []
            var updateFunction = function(altMode){ missionItem.cameraCalc.distanceMode = altMode }
            removeModes.push(beeCopter.AltitudeModeMixed)
            if (!missionItem.masterController.controllerVehicle.supportsTerrainFrame) {
                removeModes.push(beeCopter.AltitudeModeTerrainFrame)
            }
            if (!beeCopter.corePlugin.options.showMissionAbsoluteAltitude || !_missionItem.cameraCalc.isManualCamera) {
                removeModes.push(beeCopter.AltitudeModeAbsolute)
            }
            altModeDialogComponent.createObject(mainWindow, { rgRemoveModes: removeModes, updateAltModeFn: updateFunction }).open()
        }

        Component { id: altModeDialogComponent; AltModeDialog { } }

        RowLayout {
            spacing: ScreenTools.defaultFontPixelWidth / 2

            beeCopterLabel { text: beeCopter.altitudeModeShortDescription(missionItem.cameraCalc.distanceMode) }
            beeCopterColoredImage {
                height:     ScreenTools.defaultFontPixelHeight / 2
                width:      height
                source:     "/res/DropArrow.svg"
                color:      beeCopterPal.text
            }
        }
    }

    GridLayout {
        Layout.fillWidth:   true
        columnSpacing:      _margin
        rowSpacing:         _margin
        columns:            2
        enabled:            missionItem.cameraCalc.distanceMode === beeCopter.AltitudeModeCalcAboveTerrain

        beeCopterLabel { text: qsTr("Tolerance") }
        FactTextField {
            fact:               missionItem.terrainAdjustTolerance
            Layout.fillWidth:   true
        }

        beeCopterLabel { text: qsTr("Max Climb Rate") }
        FactTextField {
            fact:               missionItem.terrainAdjustMaxClimbRate
            Layout.fillWidth:   true
        }

        beeCopterLabel { text: qsTr("Max Descent Rate") }
        FactTextField {
            fact:               missionItem.terrainAdjustMaxDescentRate
            Layout.fillWidth:   true
        }
    }
}
