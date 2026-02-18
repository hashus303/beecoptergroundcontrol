import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls
import beeCopter.VehicleSetup
import beeCopter.FactControls

ColumnLayout {
    spacing: ScreenTools.defaultFontPixelHeight / 2

    required property var joystick
    required property var controller

    property int _maxButtons: 64

    beeCopterLabel {
        Layout.preferredWidth: parent.width
        wrapMode: Text.WordWrap
        text: qsTr("Multiple buttons that have the same action must be pressed simultaneously to invoke the action.")
    }

    RowLayout {
        id: buttonAssignmentRow
        spacing: ScreenTools.defaultFontPixelWidth

        property int selectedButtonIndex: 0
        property var _assignedButtonModel: assignedButtonModel

        function _rebuildAssignedButtonModel() {
            assignedButtonModel.clear()
            let buttonActions = joystick.buttonActions
            for (let i = 0; i < joystick.buttonCount; i++) {
                if (buttonActions[i] !== joystick.buttonActionNone) {
                    assignedButtonModel.append( { "buttonIndex": i, "buttonAction": buttonActions[i], "repeat": joystick.getButtonRepeat(i) } )
                }
            }
        }

        Component.onCompleted: _rebuildAssignedButtonModel()
        Connections { target: joystick; function onButtonActionsChanged() { buttonAssignmentRow._rebuildAssignedButtonModel() } }

        ListModel {
            id: assignedButtonModel
        }

        beeCopterComboBox {
            id: buttonIndexCombo
            model: joystick.buttonCount

            onActivated: (index) => { buttonAssignmentRow.selectedButtonIndex = index }
        }

        beeCopterComboBox {
            id: buttonActionCombo
            model: joystick.assignableActionTitles
            sizeToContents: true

            onActivated: (index) => { joystick.setButtonAction(buttonAssignmentRow.selectedButtonIndex, textAt(index)) }

            function _findCurrentButtonAction() {
                let buttonActionIndex = find(joystick.buttonActions[buttonAssignmentRow.selectedButtonIndex])
                if (buttonActionIndex < 0) {
                    buttonActionIndex = 0
                }
                currentIndex = buttonActionIndex
            }

            Component.onCompleted: _findCurrentButtonAction()
            Connections { target: buttonAssignmentRow; function onSelectedButtonIndexChanged() { buttonActionCombo._findCurrentButtonAction() } }
        }

        beeCopterCheckBox {
            text: qsTr("Repeat")
            checked: joystick.getButtonRepeat(buttonAssignmentRow.selectedButtonIndex)
            enabled: {
                if (buttonActionCombo.currentIndex < 0) return false
                var action = joystick.assignableActions.get(buttonActionCombo.currentIndex)
                return action ? action.canRepeat : false
            }

            onClicked: {
                joystick.setButtonRepeat(buttonAssignmentRow.selectedButtonIndex, checked)
                buttonAssignmentRow._rebuildAssignedButtonModel()
            }
        }
    }

    GridLayout {
        rows: buttonAssignmentRow._assignedButtonModel.count
        columnSpacing: ScreenTools.defaultFontPixelWidth
        rowSpacing: 0
        flow: GridLayout.TopToBottom

        Repeater {
            model: buttonAssignmentRow._assignedButtonModel
            beeCopterLabel { text: buttonIndex }
        }
        Repeater {
            model: buttonAssignmentRow._assignedButtonModel
            beeCopterLabel { text: buttonAction }
        }
        Repeater {
            model: buttonAssignmentRow._assignedButtonModel
            beeCopterLabel { text: repeat ? "Repeat" : "" }
        }
    }

    /*Column {
        id:         buttonCol
        Layout.fillWidth: true
        visible:    globals.activeVehicle.supportsJSButton
        spacing:    ScreenTools.defaultFontPixelHeight / 3

        Row {
            spacing: ScreenTools.defaultFontPixelWidth
            beeCopterLabel {
                horizontalAlignment: Text.AlignHCenter
                width: ScreenTools.defaultFontPixelHeight * 1.5
                text: qsTr("#")
            }
            beeCopterLabel {
                width: ScreenTools.defaultFontPixelWidth * 26
                text: qsTr("Function: ")
            }
            beeCopterLabel {
                width: ScreenTools.defaultFontPixelWidth * 26
                visible: globals.activeVehicle.supportsJSButton
                text: qsTr("Shift Function: ")
            }
        }
        Repeater {
            id: jsButtonActionRepeater
            model: joystick ? Math.min(joystick.buttonCount, _maxButtons) : 0

            Row {
                spacing: ScreenTools.defaultFontPixelWidth
                visible: globals.activeVehicle.supportsJSButton
                property var parameterName: `BTN${index}_FUNCTION`
                property var parameterShiftName: `BTN${index}_SFUNCTION`
                property bool hasFirmwareSupport: controller.parameterExists(-1, parameterName)

                property bool pressed
                property var currentAssignableAction: joystick ? joystick.assignableActions.get(buttonActionCombo.currentIndex) : null

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: ScreenTools.defaultFontPixelHeight * 1.5
                    height: width
                    border.width: 1
                    border.color: beeCopterPal.text
                    color: pressed ? beeCopterPal.buttonHighlight : beeCopterPal.button


                    beeCopterLabel {
                        anchors.fill: parent
                        color: pressed ? beeCopterPal.buttonHighlightText : beeCopterPal.buttonText
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: modelData
                    }
                }

                beeCopterComboBox {
                    id: buttonActionCombo
                    width: ScreenTools.defaultFontPixelWidth * 26
                    property Fact fact: controller.parameterExists(-1, parameterName) ? controller.getParameterFact(-1, parameterName) : null
                    property Fact fact_shift: controller.parameterExists(-1, parameterShiftName) ? controller.getParameterFact(-1, parameterShiftName) : null
                    property var factOptions: fact ? fact.enumStrings : [];
                    property var beeCopterActions: joystick.assignableActionTitles.filter(
                        function (s) {
                            return [
                                s.includes("Camera"),
                                s.includes("Stream"),
                                s.includes("Stream"),
                                s.includes("Zoom"),
                                s.includes("Gimbal"),
                                s.includes("No Action")
                            ].some(Boolean)
                        }
                    )

                    model: [...beeCopterActions, ...factOptions]
                    property var isFwAction: currentIndex >= beeCopterActions.length
                    sizeToContents: true

                    function _findCurrentButtonAction() {
                        // Find the index in the dropdown of the current action, checks FW and beeCopter actions
                        if (joystick) {
                            if (fact && fact.value > 0) {
                                // This is a firmware function
                                currentIndex = beeCopterActions.length + fact.enumIndex
                                // For sanity reasons, make sure beeCopter is set to "no action" if the firmware is set to do something
                                joystick.setButtonAction(modelData, "No Action")
                            } else {
                                // If there is not firmware function, check beeCopter ones
                                currentIndex = find(joystick.buttonActions[modelData])
                            }
                        }
                    }

                    Component.onCompleted: _findCurrentButtonAction()
                    onModelChanged: _findCurrentButtonAction()
                    onActivated: function (optionIndex) {
                        var func = textAt(optionIndex)
                        if (factOptions.indexOf(func) > -1) {
                            // This is a FW action, set parameter to the action and set beeCopter's handler to No Action
                            fact.enumStringValue = func
                            joystick.setButtonAction(modelData, "No Action")
                        } else {
                            // This is a beeCopter action, set parameters to Disabled and beeCopter to the desired action
                            joystick.setButtonAction(modelData, func)
                            fact.value = 0
                            fact_shift.value = 0
                        }
                    }
                }
                beeCopterCheckBox {
                    id: repeatCheck
                    text: qsTr("Repeat")
                    enabled: currentAssignableAction && joystick.calibrated && currentAssignableAction.canRepeat
                    visible: !globals.activeVehicle.supportsJSButton

                    onClicked: {
                        joystick.setButtonRepeat(modelData, checked)
                    }
                    Component.onCompleted: {
                        if (joystick) {
                            checked = joystick.getButtonRepeat(modelData)
                        }
                    }
                    anchors.verticalCenter: parent.verticalCenter
                }
                Item {
                    width: ScreenTools.defaultFontPixelWidth * 2
                    height: 1
                }

                FactComboBox {
                    id: shiftJSButtonActionCombo
                    width: ScreenTools.defaultFontPixelWidth * 26
                    fact: controller.parameterExists(-1, parameterShiftName) ? controller.getParameterFact(-1, parameterShiftName) : null;
                    indexModel: false
                    visible: buttonActionCombo.isFwAction
                    sizeToContents: true
                }

                beeCopterLabel {
                    text: qsTr("beeCopter functions do not support shift actions")
                    width: ScreenTools.defaultFontPixelWidth * 15
                    visible: hasFirmwareSupport && !buttonActionCombo.isFwAction
                    anchors.verticalCenter: parent.verticalCenter
                }
                beeCopterLabel {
                    text: qsTr("No firmware support")
                    width: ScreenTools.defaultFontPixelWidth * 15
                    visible: !hasFirmwareSupport
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }*/
}
