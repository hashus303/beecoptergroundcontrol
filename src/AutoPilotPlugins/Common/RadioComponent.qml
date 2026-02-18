import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import beeCopter
import beeCopter.FactControls
import beeCopter.Controls
import beeCopter.VehicleSetup

SetupPage {
    id: radioPage
    pageComponent: pageComponent

    Component {
        id: pageComponent

        RemoteControlCalibration {
            id: remoteControlCalibration

            useDeadband: false

            controller: RadioComponentController {
                statusText: remoteControlCalibration.statusText
                cancelButton: remoteControlCalibration.cancelButton
                nextButton: remoteControlCalibration.nextButton
                joystickMode: false

                onThrottleReversedCalFailure: mainWindow.showMessageDialog(qsTr("Throttle channel reversed"), qsTr("Calibration failed. The throttle channel on your transmitter is reversed. You must correct this on your transmitter in order to complete calibration."))
            }

            Component.onCompleted: controller.start()

            additionalSetupComponent: ColumnLayout {
                spacing: ScreenTools.defaultFontPixelHeight / 2

                ColumnLayout {
                    id: switchSettings
                    Layout.fillWidth: true

                    Repeater {
                        model: beeCopter.multiVehicleManager.activeVehicle.px4Firmware ?
                                    (beeCopter.multiVehicleManager.activeVehicle.multiRotor ?
                                        [ "RC_MAP_AUX1", "RC_MAP_AUX2", "RC_MAP_PARAM1", "RC_MAP_PARAM2", "RC_MAP_PARAM3", "RC_MAP_PAY_SW"] :
                                        [ "RC_MAP_FLAPS", "RC_MAP_AUX1", "RC_MAP_AUX2", "RC_MAP_PARAM1", "RC_MAP_PARAM2", "RC_MAP_PARAM3", "RC_MAP_PAY_SW"]) :
                                    0

                        LabelledFactComboBox {
                            label: fact.shortDescription
                            fact: controller.getParameterFact(-1, modelData)
                            indexModel: false
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 1
                    color: beeCopterPal.text
                }

                RowLayout {
                    spacing: ScreenTools.defaultFontPixelWidth

                    beeCopterButton {
                        id: bindButton
                        text: qsTr("Spektrum Bind")
                        onClicked: spektrumBindDialogComponent.createObject(mainWindow).open()
                    }

                    beeCopterButton {
                        text: qsTr("CRSF Bind")
                        onClicked: mainWindow.showMessageDialog(qsTr("CRSF Bind"),
                                                                qsTr("Click Ok to place your CRSF receiver in the bind mode."),
                                                                Dialog.Ok | Dialog.Cancel,
                                                                function() { controller.crsfBindMode() })
                    }

                    beeCopterButton {
                        text: qsTr("Copy Trims")
                        onClicked: mainWindow.showMessageDialog(qsTr("Copy Trims"),
                                                                qsTr("Center your sticks and move throttle all the way down, then press Ok to copy trims. After pressing Ok, reset the trims on your radio back to zero."),
                                                                Dialog.Ok | Dialog.Cancel,
                                                                function() { controller.copyTrims() })
                    }
                }

                Component {
                    id: spektrumBindDialogComponent

                    beeCopterPopupDialog {
                        title: qsTr("Spektrum Bind")
                        buttons: Dialog.Ok | Dialog.Cancel

                        onAccepted: { controller.spektrumBindMode(radioGroup.checkedButton.bindMode) }

                        ButtonGroup { id: radioGroup }

                        ColumnLayout {
                            spacing: ScreenTools.defaultFontPixelHeight / 2

                            beeCopterLabel {
                                wrapMode: Text.WordWrap
                                text: qsTr("Click Ok to place your Spektrum receiver in the bind mode.")
                            }

                            beeCopterLabel {
                                wrapMode: Text.WordWrap
                                text: qsTr("Select the specific receiver type below:")
                            }

                            beeCopterRadioButton {
                                text: qsTr("DSM2 Mode")
                                ButtonGroup.group: radioGroup
                                property int bindMode: RadioComponentController.DSM2
                            }

                            beeCopterRadioButton {
                                text: qsTr("DSMX (7 channels or less)")
                                ButtonGroup.group: radioGroup
                                property int bindMode: RadioComponentController.DSMX7
                            }

                            beeCopterRadioButton {
                                checked: true
                                text: qsTr("DSMX (8 channels or more)")
                                ButtonGroup.group: radioGroup
                                property int bindMode: RadioComponentController.DSMX8
                            }
                        }
                    }
                }
            }
        }
    }
}
