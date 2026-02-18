import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import beeCopter
import beeCopter.FactControls
import beeCopter.Controls

SetupPage {
    id:             flightModePage
    pageComponent:  flightModePageComponent

    readonly property string _modeChannelParam: controller.modeChannelParam
    readonly property string _modeParamPrefix:  controller.modeParamPrefix
    readonly property var    _pwmStrings:       [ "PWM 0 - 1230", "PWM 1231 - 1360", "PWM 1361 - 1490", "PWM 1491 - 1620", "PWM 1621 - 1749", "PWM 1750 +"]

    property real   _margins:                   ScreenTools.defaultFontPixelHeight
    property Fact   _nullFact
    property bool   _fltmodeChExists:           controller.parameterExists(-1, _modeChannelParam)
    property Fact   _fltmodeCh:                 _fltmodeChExists ? controller.getParameterFact(-1, _modeChannelParam) : _nullFact
    property bool   _ch7OptAvailable:           controller.parameterExists(-1, "CH7_OPT")
    property int    _rcOptionStart:             _ch7OptAvailable ? 7 : 6
    property int    _rcOptionStop:              _ch7OptAvailable ? 12 : 16
    property bool   _customSimpleMode:          controller.simpleMode === APMFlightModesComponentController.SimpleModeCustom

    beeCopterPalette { id: beeCopterPal; colorGroupEnabled: true }

    APMFlightModesComponentController {
        id:         controller
    }

    Component {
        id: flightModePageComponent

        Flow {
            id:         flowLayout
            width:      availableWidth
            spacing:     _margins

            Column {
                spacing: _margins

                beeCopterLabel {
                    id:             flightModeLabel
                    text:           qsTr("Flight Mode Settings") + (_fltmodeChExists ? "" : qsTr(" (Channel 5)"))
                    font.bold:      true
                }

                Rectangle {
                    id:     flightModeSettings
                    width:  flightModeColumn.width + (_margins * 2)
                    height: flightModeColumn.height + ScreenTools.defaultFontPixelHeight
                    color:  beeCopterPal.windowShade

                    Column {
                        id:                 flightModeColumn
                        anchors.margins:    ScreenTools.defaultFontPixelWidth
                        anchors.left:       parent.left
                        anchors.top:        parent.top
                        spacing:            ScreenTools.defaultFontPixelHeight

                        Row {
                            spacing:    _margins
                            visible:    _fltmodeChExists

                            beeCopterLabel {
                                id:                 modeChannelLabel
                                anchors.baseline:   modeChannelCombo.baseline
                                text:               qsTr("Flight mode channel:")
                            }

                            beeCopterComboBox {
                                id:             modeChannelCombo
                                width:          ScreenTools.defaultFontPixelWidth * 15
                                model:          [ qsTr("Not assigned"), qsTr("Channel 1"), qsTr("Channel 2"),
                                    qsTr("Channel 3"),    qsTr("Channel 4"), qsTr("Channel 5"),
                                    qsTr("Channel 6"),    qsTr("Channel 7"), qsTr("Channel 8") ]

                                currentIndex:   _fltmodeCh.value
                                onActivated: (index) => { _fltmodeCh.value = index }
                            }
                        }

                        GridLayout {
                            rows:   _customSimpleMode ? 7 : 6
                            flow:   GridLayout.TopToBottom

                            beeCopterLabel { text: ""; visible: _customSimpleMode }
                            Repeater {
                                model:  6

                                beeCopterLabel {
                                    text:   qsTr("Flight Mode ") + index
                                    color:  controller.activeFlightMode == index ? "yellow" : beeCopterPal.text

                                    property int index: modelData + 1
                                }
                            }

                            beeCopterLabel { text: ""; visible: _customSimpleMode }
                            Repeater {
                                model:  6

                                FactComboBox {
                                    Layout.preferredWidth:  ScreenTools.defaultFontPixelWidth * 15
                                    fact:                   controller.getParameterFact(-1, _modeParamPrefix + index)
                                    indexModel:             false

                                    property int index: modelData + 1
                                }
                            }

                            beeCopterLabel {
                                text:           qsTr("Simple")
                                font.pointSize: ScreenTools.smallFontPointSize
                                visible:        _customSimpleMode
                            }
                            Repeater {
                                model:  controller.simpleModeEnabled
                                beeCopterCheckBox {
                                    Layout.alignment:   Qt.AlignHCenter
                                    visible:            _customSimpleMode
                                    checked:            modelData
                                    onClicked:          controller.setSimpleMode(index, checked)
                                }
                            }

                            beeCopterLabel {
                                text:           qsTr("Super-Simple")
                                font.pointSize: ScreenTools.smallFontPointSize
                                visible:        _customSimpleMode
                            }
                            Repeater {
                                model:  controller.superSimpleModeEnabled
                                beeCopterCheckBox {
                                    Layout.alignment:   Qt.AlignHCenter
                                    visible:            _customSimpleMode
                                    checked:            modelData
                                    onClicked:          controller.setSuperSimpleMode(index, checked)
                                }
                            }

                            beeCopterLabel { text: ""; visible: _customSimpleMode }
                            Repeater {
                                model:  6

                                beeCopterLabel { text: _pwmStrings[modelData] }
                            }
                        }

                        RowLayout {
                            spacing: _margins
                            visible: controller.simpleModesSupported

                            beeCopterLabel { text: qsTr("Simple Mode") }

                            beeCopterComboBox {
                                model:          controller.simpleModeNames
                                currentIndex:   controller.simpleMode
                                onActivated: (index) => { controller.simpleMode = index }
                            }
                        }
                    } // Column - Flight Modes
                } // Rectangle - Flight Modes
            } // Column - Flight Modes

            Column {
                spacing: _margins

                beeCopterLabel {
                    id:                 channelOptionsLabel
                    text:               qsTr("Switch Options")
                    font.bold:          true
                }

                Rectangle {
                    id:     channelOptionsSettings
                    width:  channelOptColumn.width + (_margins * 2)
                    height: channelOptColumn.height + ScreenTools.defaultFontPixelHeight
                    color:  beeCopterPal.windowShade

                    Column {
                        id:                 channelOptColumn
                        anchors.margins:    ScreenTools.defaultFontPixelWidth
                        anchors.left:       parent.left
                        anchors.top:        parent.top
                        spacing:            ScreenTools.defaultFontPixelHeight

                        Repeater {
                            model: _rcOptionStop - _rcOptionStart + 1

                            Row {
                                spacing: ScreenTools.defaultFontPixelWidth

                                property int index: modelData + _rcOptionStart
                                property Fact nullFact: Fact { }

                                beeCopterLabel {
                                    anchors.baseline:   optCombo.baseline
                                    text:               qsTr("Channel option %1 :").arg(index)
                                    color:              controller.channelOptionEnabled[modelData + (_ch7OptAvailable ? 1 : 0)] ? "yellow" : beeCopterPal.text
                                }

                                FactComboBox {
                                    id:         optCombo
                                    width:      ScreenTools.defaultFontPixelWidth * 15
                                    fact:       controller.getParameterFact(-1, "r.RC" + index + "_OPTION")
                                    indexModel: false
                                }
                            }
                        } // Repeater -- Channel options
                    } // Column - Channel options
                } // Rectangle - Channel options
            } // Column - Channel options
        } // Flow
    } // Component - flightModePageComponent
} // SetupPage
