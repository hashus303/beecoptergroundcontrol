import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs

import beeCopter
import beeCopter.Controls
import beeCopter.FactControls

beeCopterPopupDialog {
    title:      qsTr("RC To Param")
    buttons:    Dialog.Cancel | Dialog.Ok

    property alias tuningFact: controller.tuningFact

    onAccepted: beeCopter.multiVehicleManager.activeVehicle.sendParamMapRC(tuningFact.name, scale.text, centerValue.text, tuningID.currentIndex, minValue.text, maxValue.text)

    RCToParamDialogController {
        id: controller
    }

    ColumnLayout {
        spacing: ScreenTools.defaultDialogControlSpacing

        beeCopterLabel {
            Layout.preferredWidth:  mainGrid.width
            Layout.fillWidth:       true
            wrapMode:               Text.WordWrap
            text:                   qsTr("Bind an RC Channel to a parameter value. Tuning IDs can be mapped to an RC Channel from Radio Setup page.")
        }

        beeCopterLabel {
            Layout.preferredWidth:  mainGrid.width
            Layout.fillWidth:       true
            text:                   qsTr("Waiting on parameter update from Vehicle.")
            visible:                !controller.ready
        }

        GridLayout {
            id:             mainGrid
            columns:        2
            rowSpacing:     ScreenTools.defaultDialogControlSpacing
            columnSpacing:  ScreenTools.defaultDialogControlSpacing
            enabled:        controller.ready

            beeCopterLabel { text: qsTr("Parameter") }
            beeCopterLabel { text: tuningFact.name }

            beeCopterLabel { text: qsTr("Tuning ID") }
            beeCopterComboBox {
                id:                 tuningID
                Layout.fillWidth:   true
                currentIndex:       0
                model:              [ 1, 2, 3 ]
            }

            beeCopterLabel { text: qsTr("Scale") }
            beeCopterTextField {
                id:     scale
                text:   controller.scale.valueString
            }

            beeCopterLabel { text: qsTr("Center Value") }
            beeCopterTextField {
                id:     centerValue
                text:   controller.center.valueString
            }

            beeCopterLabel { text: qsTr("Min Value") }
            beeCopterTextField {
                id:     minValue
                text:   controller.min.valueString
            }

            beeCopterLabel { text: qsTr("Max Value") }
            beeCopterTextField {
                id:     maxValue
                text:   controller.max.valueString
            }
        }

        beeCopterLabel {
            Layout.preferredWidth:  mainGrid.width
            Layout.fillWidth:       true
            wrapMode:               Text.WordWrap
            text:                   qsTr("Double check that all values are correct prior to confirming dialog.")
        }
    }
}
