import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import beeCopter
import beeCopter.FactControls
import beeCopter.Controls
import beeCopter.AutoPilotPlugins.PX4

// Note: Only the _SOURCE parameter can be assumed to be always available. The remainder of the parameters
// may or may not be available depending on the _SOURCE setting.
SetupPage {
    id:             powerPage
    pageComponent:  pageComponent

    Component {
        id: pageComponent

        Item {
            width:  Math.max(availableWidth, innerColumn.width)
            height: innerColumn.height

            readonly property string    _highlightPrefix:           "<font color=\"" + beeCopterPal.warningText + "\">"
            readonly property string    _highlightSuffix:           "</font>"

            property int    _textEditWidth:             ScreenTools.defaultFontPixelWidth * 8
            property Fact   _uavcanEnable:              controller.getParameterFact(-1, "UAVCAN_ENABLE", false)
            property int    _indexedBatteryParamCount:  getIndexedBatteryParamCount()

            function getIndexedBatteryParamCount() {
                var batteryIndex = 1
                do {
                    if (!controller.parameterExists(-1, "BAT#_SOURCE".replace("#", batteryIndex))) {
                        return batteryIndex - 1
                    }
                    batteryIndex++
                } while (true)
            }

            PowerComponentController {
                id:                     controller
                onOldFirmware:          mainWindow.showMessageDialog(qsTr("ESC Calibration"),           qsTr("%1 cannot perform ESC Calibration with this version of firmware. You will need to upgrade to a newer firmware.").arg(beeCopter.appName))
                onNewerFirmware:        mainWindow.showMessageDialog(qsTr("ESC Calibration"),           qsTr("%1 cannot perform ESC Calibration with this version of firmware. You will need to upgrade %1.").arg(beeCopter.appName))
                onDisconnectBattery:    mainWindow.showMessageDialog(qsTr("ESC Calibration failed"),    qsTr("You must disconnect the battery prior to performing ESC Calibration. Disconnect your battery and try again."))
                onConnectBattery:       escCalibrationDlgComponent.createObject(mainWindow).open()
            }

            ColumnLayout {
                id:                         innerColumn
                anchors.horizontalCenter:   parent.horizontalCenter
                spacing:                    ScreenTools.defaultFontPixelHeight

                function drawArrowhead(ctx, x, y, radians)
                {
                    ctx.save();
                    ctx.beginPath();
                    ctx.translate(x,y);
                    ctx.rotate(radians);
                    ctx.moveTo(0,0);
                    ctx.lineTo(5,10);
                    ctx.lineTo(-5,10);
                    ctx.closePath();
                    ctx.restore();
                    ctx.fill();
                }

                function drawLineWithArrow(ctx, x1, y1, x2, y2)
                {
                    ctx.beginPath();
                    ctx.moveTo(x1, y1);
                    ctx.lineTo(x2, y2);
                    ctx.stroke();
                    var rd = Math.atan((y2 - y1) / (x2 - x1));
                    rd += ((x2 > x1) ? 90 : -90) * Math.PI/180;
                    drawArrowhead(ctx, x2, y2, rd);
                }

                Repeater {
                    id:     batterySetupRepeater
                    model:  _indexedBatteryParamCount

                    Loader {
                        sourceComponent: batterySetupComponent

                        property int    batteryIndex:           index + 1
                        property bool   showBatteryIndex:       batterySetupRepeater.count > 1
                    }
                }


                beeCopterGroupBox {
                    Layout.fillWidth:   true
                    title:              qsTr("ESC PWM Minimum and Maximum Calibration")

                    ColumnLayout {
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        spacing:        ScreenTools.defaultFontPixelWidth

                        beeCopterLabel {
                            color:              beeCopterPal.warningText
                            wrapMode:           Text.WordWrap
                            text:               qsTr("WARNING: Propellers must be removed from vehicle prior to performing ESC calibration.")
                            Layout.fillWidth:   true
                        }

                        beeCopterLabel {
                            text: qsTr("You must use USB connection for this operation.")
                        }

                        beeCopterButton {
                            text:       qsTr("Calibrate")
                            width:      ScreenTools.defaultFontPixelWidth * 20
                            onClicked:  controller.calibrateEsc()
                        }
                    }
                }

                beeCopterCheckBox {
                    id:         showUAVCAN
                    text:       qsTr("Show UAVCAN Settings")
                    checked:    _uavcanEnable ? _uavcanEnable.rawValue !== 0 : false
                }

                beeCopterGroupBox {
                    Layout.fillWidth:       true
                    title:                  qsTr("UAVCAN Bus Configuration")
                    visible:                showUAVCAN.checked

                    Row {
                        id:         uavCanConfigRow
                        spacing:    ScreenTools.defaultFontPixelWidth

                        FactComboBox {
                            id:                 _uavcanEnabledCheckBox
                            width:              ScreenTools.defaultFontPixelWidth * 20
                            fact:               _uavcanEnable
                            indexModel:         false
                        }

                        beeCopterLabel {
                            anchors.verticalCenter: parent.verticalCenter
                            text:                   qsTr("Change required restart")
                        }
                    }
                }

                beeCopterGroupBox {
                    Layout.fillWidth:       true
                    title:                  qsTr("UAVCAN Motor Index and Direction Assignment")
                    visible:                showUAVCAN.checked

                    ColumnLayout {
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        spacing:        ScreenTools.defaultFontPixelWidth

                        beeCopterLabel {
                            wrapMode:           Text.WordWrap
                            color:              beeCopterPal.warningText
                            text:               qsTr("WARNING: Propellers must be removed from vehicle prior to performing UAVCAN ESC configuration.")
                            Layout.fillWidth:   true
                        }

                        beeCopterLabel {
                            wrapMode:           Text.WordWrap
                            text:               qsTr("ESC parameters will only be accessible in the editor after assignment.")
                            Layout.fillWidth:   true
                        }

                        beeCopterLabel {
                            wrapMode:           Text.WordWrap
                            text:               qsTr("Start the process, then turn each motor into its turn direction, in the order of their motor indices.")
                            Layout.fillWidth:   true
                        }

                        beeCopterButton {
                            text:       qsTr("Start Assignment")
                            width:      ScreenTools.defaultFontPixelWidth * 20
                            onClicked:  controller.startBusConfigureActuators()
                        }

                        beeCopterButton {
                            text:       qsTr("Stop Assignment")
                            width:      ScreenTools.defaultFontPixelWidth * 20
                            onClicked:  controller.stopBusConfigureActuators()
                        }
                    }
                }

            } // Column

            Component {
                id: batterySetupComponent

                beeCopterGroupBox {
                    Layout.fillWidth:   true
                    title:              qsTr("Battery ") + (showBatteryIndex ? batteryIndex : "")

                    property var _controller:   controller
                    property int _batteryIndex: batteryIndex

                    BatteryParams {
                        id:             batParams
                        controller:     _controller
                        batteryIndex:   _batteryIndex
                    }

                    property bool battNumCellsAvailable:        batParams.battNumCellsAvailable
                    property bool battHighVoltAvailable:        batParams.battHighVoltAvailable
                    property bool battLowVoltAvailable:         batParams.battLowVoltAvailable
                    property bool battVoltLoadDropAvailable:    batParams.battVoltLoadDropAvailable
                    property bool battVoltageDividerAvailable:  batParams.battVoltageDividerAvailable
                    property bool battAmpsPerVoltAvailable:     batParams.battAmpsPerVoltAvailable

                    property Fact battSource:           batParams.battSource
                    property Fact battNumCells:         batParams.battNumCells
                    property Fact battHighVolt:         batParams.battHighVolt
                    property Fact battLowVolt:          batParams.battLowVolt
                    property Fact battVoltLoadDrop:     batParams.battVoltLoadDrop
                    property Fact battVoltageDivider:   batParams.battVoltageDivider
                    property Fact battAmpsPerVolt:      batParams.battAmpsPerVolt

                    function getBatteryImage() {
                        switch(battNumCells.value) {
                        case 1:  return "/qmlimages/PowerComponentBattery_01cell.svg";
                        case 2:  return "/qmlimages/PowerComponentBattery_02cell.svg"
                        case 3:  return "/qmlimages/PowerComponentBattery_03cell.svg"
                        case 4:  return "/qmlimages/PowerComponentBattery_04cell.svg"
                        case 5:  return "/qmlimages/PowerComponentBattery_05cell.svg"
                        case 6:  return "/qmlimages/PowerComponentBattery_06cell.svg"
                        default: return "/qmlimages/PowerComponentBattery_01cell.svg";
                        }
                    }

                    ColumnLayout {

                        RowLayout {
                            spacing: ScreenTools.defaultFontPixelWidth
                            visible: battSource.rawValue == -1

                            beeCopterLabel { text:  qsTr("Source") }
                            FactComboBox {
                                width:          _textEditWidth
                                fact:           battSource
                                indexModel:     false
                                sizeToContents: true
                            }
                        }

                        GridLayout {
                            id:             batteryGrid
                            columns:        5
                            columnSpacing:  ScreenTools.defaultFontPixelWidth
                            visible:        battSource.rawValue != -1

                            beeCopterLabel { text:  qsTr("Source") }
                            FactComboBox {
                                width:          _textEditWidth
                                fact:           battSource
                                indexModel:     false
                                sizeToContents: true
                            }

                            beeCopterColoredImage {
                                id:                     battImage
                                Layout.rowSpan:         4
                                width:                  height * 0.75
                                height:                 100
                                sourceSize.height:      height
                                fillMode:               Image.PreserveAspectFit
                                smooth:                 true
                                color:                  beeCopterPal.text
                                cache:                  false
                                source:                 getBatteryImage(batteryIndex)
                                visible:                battNumCellsAvailable && battLowVoltAvailable && battHighVoltAvailable
                            }

                            Item {
                                width:              1
                                height:             1
                                Layout.columnSpan:  battImage.visible ? 2 : 3
                            }

                            beeCopterLabel {
                                text:  qsTr("Number of Cells (in Series)")
                                visible: battNumCellsAvailable
                            }
                            FactTextField {
                                width:      _textEditWidth
                                fact:       battNumCells
                                showUnits:  true
                                visible:    battNumCellsAvailable
                            }
                            beeCopterLabel {
                                text:       qsTr("Battery Max:")
                                visible:    battImage.visible
                            }
                            beeCopterLabel {
                                text:       visible ? (battNumCells.value * battHighVolt.value).toFixed(1) + ' V' : ""
                                visible:    battImage.visible
                            }
                            Item {
                                width:              1
                                height:             1
                                Layout.columnSpan:  3
                                visible:            !battImage.visible
                            }

                            beeCopterLabel {
                                text:       qsTr("Empty Voltage (per cell)")
                                visible:    battLowVoltAvailable
                            }
                            FactTextField {
                                width:      _textEditWidth
                                fact:       battLowVolt
                                showUnits:  true
                                visible:    battLowVoltAvailable
                            }
                            beeCopterLabel {
                                text:       qsTr("Battery Min:")
                                visible:    battImage.visible
                            }
                            beeCopterLabel {
                                text:       visible ? (battNumCells.value * battLowVolt.value).toFixed(1) + ' V' : ""
                                visible:    battImage.visible
                            }
                            Item {
                                width:              1
                                height:             1
                                Layout.columnSpan:  3
                                visible:            battLowVoltAvailable && !battImage.visible
                            }

                            beeCopterLabel {
                                text:       qsTr("Full Voltage (per cell)")
                                visible:    battHighVoltAvailable
                            }
                            FactTextField {
                                width:      _textEditWidth
                                fact:       battHighVolt
                                showUnits:  true
                                visible:    battHighVoltAvailable
                            }
                            Item {
                                width:              1
                                height:             1
                                Layout.columnSpan:  battImage.visible ? 2 : 3
                                visible:            battHighVoltAvailable
                            }

                            beeCopterLabel {
                                text:       qsTr("Voltage divider")
                                visible:    battVoltageDividerAvailable
                            }
                            FactTextField {
                                fact:       battVoltageDivider
                                visible:    battVoltageDividerAvailable
                            }
                            beeCopterButton {
                                text:       qsTr("Calculate")
                                visible:    battVoltageDividerAvailable
                                onClicked:  calcVoltageDividerDlgComponent.createObject(mainWindow, { batteryIndex: _batteryIndex }).open()
                            }
                            Item { width: 1; height: 1; Layout.columnSpan: 2; visible: battVoltageDividerAvailable }

                            beeCopterLabel {
                                Layout.columnSpan:  batteryGrid.columns
                                Layout.fillWidth:   true
                                font.pointSize:     ScreenTools.smallFontPointSize
                                wrapMode:           Text.WordWrap
                                text:               qsTr("If the battery voltage reported by the vehicle is largely different than the voltage read externally using a voltmeter you can adjust the voltage multiplier value to correct this. ") +
                                                    qsTr("Click the Calculate button for help with calculating a new value.")
                                visible:            battVoltageDividerAvailable
                            }
                            beeCopterLabel {
                                text:       qsTr("Amps per volt")
                                visible:    battAmpsPerVoltAvailable
                            }
                            FactTextField {
                                fact:       battAmpsPerVolt
                                visible:    battAmpsPerVoltAvailable
                            }
                            beeCopterButton {
                                text:       qsTr("Calculate")
                                visible:    battAmpsPerVoltAvailable
                                onClicked:  calcAmpsPerVoltDlgComponent.createObject(mainWindow, { batteryIndex: _batteryIndex }).open()
                            }
                            Item { width: 1; height: 1; Layout.columnSpan: 2; visible: battAmpsPerVoltAvailable }

                            beeCopterLabel {
                                Layout.columnSpan:  batteryGrid.columns
                                Layout.fillWidth:   true
                                font.pointSize:     ScreenTools.smallFontPointSize
                                wrapMode:           Text.WordWrap
                                text:               qsTr("If the current draw reported by the vehicle is largely different than the current read externally using a current meter you can adjust the amps per volt value to correct this. ") +
                                                    qsTr("Click the Calculate button for help with calculating a new value.")
                                visible:            battAmpsPerVoltAvailable
                            }

                            beeCopterCheckBox {
                                id:                 showAdvanced
                                Layout.columnSpan:  batteryGrid.columns
                                text:               qsTr("Show Advanced Settings")
                                visible:            battVoltLoadDropAvailable
                            }

                            beeCopterLabel {
                                text:       qsTr("Voltage Drop on Full Load (per cell)")
                                visible:    showAdvanced.checked
                            }
                            FactTextField {
                                id:         battDropField
                                fact:       battVoltLoadDrop
                                showUnits:  true
                                visible:    showAdvanced.checked
                            }
                            Item { width: 1; height: 1; Layout.columnSpan: 3; visible: showAdvanced.checked }

                            beeCopterLabel {
                                Layout.columnSpan:  batteryGrid.columns
                                Layout.fillWidth:   true
                                wrapMode:           Text.WordWrap
                                font.pointSize:     ScreenTools.smallFontPointSize
                                text:               qsTr("Batteries show less voltage at high throttle. Enter the difference in Volts between idle throttle and full ") +
                                                    qsTr("throttle, divided by the number of battery cells. Leave at the default if unsure. ") +
                                                    _highlightPrefix + qsTr("If this value is set too high, the battery might be deep discharged and damaged.") + _highlightSuffix
                                visible:            showAdvanced.checked
                            }

                            beeCopterLabel {
                                text:       qsTr("Compensated Minimum Voltage:")
                                visible:    showAdvanced.checked
                            }
                            beeCopterLabel {
                                text:       visible ? ((battNumCells.value * battLowVolt.value) - (battNumCells.value * battVoltLoadDrop.value)).toFixed(1) + qsTr(" V") : ""
                                visible:    showAdvanced.checked
                            }
                            Item { width: 1; height: 1; Layout.columnSpan: 3; visible: showAdvanced.checked }
                        } // Grid
                    }
                } // beeCopterGroupBox - Battery settings
            } // Component - batterySetupComponent

            Component {
                id: calcVoltageDividerDlgComponent

                beeCopterPopupDialog {
                    title:      qsTr("Calculate Voltage Divider")
                    buttons:    Dialog.Close

                    property alias batteryIndex: batParams.batteryIndex

                    property var        _controller:        controller
                    property FactGroup  _batteryFactGroup:  controller.vehicle.getFactGroup("battery" + (batteryIndex - 1))

                    BatteryParams {
                        id:             batParams
                        controller:     _controller
                    }

                    ColumnLayout {
                        spacing: ScreenTools.defaultFontPixelHeight

                        beeCopterLabel {
                            Layout.preferredWidth:  gridLayout.width
                            wrapMode:               Text.WordWrap
                            text:                   qsTr("Measure battery voltage using an external voltmeter and enter the value below. Click Calculate to set the new voltage multiplier.")
                        }

                        GridLayout {
                            id:         gridLayout
                            columns:    2

                            beeCopterLabel { text: qsTr("Measured voltage:") }
                            beeCopterTextField { id: measuredVoltage; numericValuesOnly: true }

                            beeCopterLabel { text: qsTr("Vehicle voltage:") }
                            beeCopterLabel { text: _batteryFactGroup.voltage.valueString }

                            beeCopterLabel { text: qsTr("Voltage divider:") }
                            FactLabel { fact: batParams.battVoltageDivider }
                        }

                        beeCopterButton {
                            text: qsTr("Calculate")

                            onClicked:  {
                                var measuredVoltageValue = parseFloat(measuredVoltage.text)
                                if (measuredVoltageValue === 0 || isNaN(measuredVoltageValue)) {
                                    return
                                }
                                var newVoltageDivider = (measuredVoltageValue * batParams.battVoltageDivider.value) / _batteryFactGroup.voltage.value
                                if (newVoltageDivider > 0) {
                                    batParams.battVoltageDivider.value = newVoltageDivider
                                }
                            }
                        }
                    }
                }
            }

            Component {
                id: calcAmpsPerVoltDlgComponent

                beeCopterPopupDialog {
                    title:      qsTr("Calculate Amps per Volt")
                    buttons:    Dialog.Close

                    property alias batteryIndex: batParams.batteryIndex

                    property var        _controller:        controller
                    property FactGroup  _batteryFactGroup:  controller.vehicle.getFactGroup("battery" + (batteryIndex - 1))

                    BatteryParams {
                        id:             batParams
                        controller:     _controller
                    }

                    ColumnLayout {
                        spacing: ScreenTools.defaultFontPixelHeight

                        beeCopterLabel {
                            Layout.preferredWidth:  gridLayout.width
                            wrapMode:               Text.WordWrap
                            text:                   qsTr("Measure current draw using an external current meter and enter the value below. Click Calculate to set the new amps per volt value.")
                        }

                        GridLayout {
                            id:         gridLayout
                            columns:    2

                            beeCopterLabel { text: qsTr("Measured current:") }
                            beeCopterTextField { id: measuredCurrent; numericValuesOnly: true }

                            beeCopterLabel { text: qsTr("Vehicle current:") }
                            beeCopterLabel { text: _batteryFactGroup.current.valueString }

                            beeCopterLabel { text: qsTr("Amps per volt:") }
                            FactLabel { fact: batParams.battAmpsPerVolt }
                        }

                        beeCopterButton {
                            text: qsTr("Calculate")

                            onClicked:  {
                                var measuredCurrentValue = parseFloat(measuredCurrent.text)
                                if (measuredCurrentValue === 0 || isNaN(measuredCurrentValue)) {
                                    return
                                }
                                var newAmpsPerVolt = (measuredCurrentValue * batParams.battAmpsPerVolt.value) / _batteryFactGroup.current.value
                                if (newAmpsPerVolt != 0) {
                                    batParams.battAmpsPerVolt.value = newAmpsPerVolt
                                }
                            }
                        }
                    }
                }
            }

            Component {
                id: escCalibrationDlgComponent

                beeCopterPopupDialog {
                    id:                     escCalibrationDlg
                    title:                  qsTr("ESC Calibration")
                    buttons:                Dialog.Ok
                    acceptButtonEnabled:    false

                    Connections {
                        target: controller

                        onBatteryConnected:     textLabel.text = qsTr("Performing calibration. This will take a few seconds..")
                        onCalibrationFailed:    { escCalibrationDlg.acceptButtonEnabled = true; textLabel.text = _highlightPrefix + qsTr("ESC Calibration failed. ") + _highlightSuffix + errorMessage }
                        onCalibrationSuccess:   { escCalibrationDlg.acceptButtonEnabled = true; textLabel.text = qsTr("Calibration complete. You can disconnect your battery now if you like.") }
                    }

                    ColumnLayout {
                        beeCopterLabel {
                            id:                     textLabel
                            wrapMode:               Text.WordWrap
                            text:                   _highlightPrefix + qsTr("WARNING: Props must be removed from vehicle prior to performing ESC calibration.") + _highlightSuffix + qsTr(" Connect the battery now and calibration will begin.")
                            Layout.fillWidth:       true
                            Layout.maximumWidth:    mainWindow.width / 2
                        }
                    }
                }
            }
        } // Item
    } // Component
} // SetupPage
