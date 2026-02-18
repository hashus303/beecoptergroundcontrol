import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Dialogs

import beeCopter
import beeCopter.Controls
import beeCopter.FactControls

beeCopterPopupDialog {
    title:      qsTr("Load Parameters")
    buttons:    Dialog.Cancel | (paramController.diffList.count ? Dialog.Ok : 0)

    property var paramController

    onAccepted: paramController.sendDiff()

    Component.onDestruction: paramController.clearDiff();

    ColumnLayout {
        spacing: ScreenTools.defaultDialogControlSpacing

        beeCopterLabel {
            Layout.preferredWidth:  mainGrid.visible ? mainGrid.width : ScreenTools.defaultFontPixelWidth * 40
            wrapMode:               Text.WordWrap
            text:                   paramController.diffList.count ?
                                        qsTr("The following parameters from the loaded file differ from what is currently set on the Vehicle. Click 'Ok' to update them on the Vehicle.") :
                                        qsTr("There are no differences between the file loaded and the current settings on the Vehicle.")
        }

        GridLayout {
            id:         mainGrid
            rows:       paramController.diffList.count + 1
            columns:    paramController.diffMultipleComponents ? 5 : 4
            flow:       GridLayout.TopToBottom
            visible:    paramController.diffList.count

            beeCopterCheckBox {
                checked: true
                onClicked: {
                    for (var i=0; i<paramController.diffList.count; i++) {
                        paramController.diffList.get(i).load = checked
                    }
                }
            }
            Repeater {
                model: paramController.diffList
                beeCopterCheckBox {
                    checked:    object.load
                    onClicked:  object.load = checked
                }
            }

            Repeater {
                model: paramController.diffMultipleComponents ? 1 : 0
                beeCopterLabel { text: qsTr("Comp ID") }
            }
            Repeater {
                model: paramController.diffMultipleComponents ? paramController.diffList : 0
                beeCopterLabel { text: object.componentId }
            }

            beeCopterLabel { text: qsTr("Name") }
            Repeater {
                model: paramController.diffList
                beeCopterLabel { text: object.name }
            }

            beeCopterLabel { text: qsTr("File") }
            Repeater {
                model: paramController.diffList
                beeCopterLabel { text: object.fileValue + " " + object.units }
            }

            beeCopterLabel { text: qsTr("Vehicle") }
            Repeater {
                model: paramController.diffList
                beeCopterLabel { text: object.noVehicleValue ? qsTr("N/A") : object.vehicleValue + " " + object.units }
            }
        }
    }
}
