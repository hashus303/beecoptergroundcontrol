import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import beeCopter
import beeCopter.FactControls
import beeCopter.Controls

SettingsPage {

    // Visual properties
    property real _margins:             ScreenTools.defaultFontPixelWidth
    property real _labelWidth:          ScreenTools.defaultFontPixelWidth * 28
    property real _valueWidth:          ScreenTools.defaultFontPixelWidth * 24
    property real _columnSpacing:       ScreenTools.defaultFontPixelHeight * 0.25
    property real _comboFieldWidth:     ScreenTools.defaultFontPixelWidth * 30
    property real _valueFieldWidth:     ScreenTools.defaultFontPixelWidth * 10
    property int  _borderWidth:         3
    // Flags visual properties
    property real   flagsWidth:         ScreenTools.defaultFontPixelWidth * 15
    property real   flagsHeight:        ScreenTools.defaultFontPixelWidth * 7
    property int    radiusFlags:        5

    // Flag to get active vehicle and active RID
    property var  _activeRID:           _activeVehicle && _activeVehicle.remoteIDManager ? _activeVehicle.remoteIDManager : null

    // Healthy connection with RID device
    property bool commsGood:            _activeVehicle && _activeVehicle.remoteIDManager ? _activeVehicle.remoteIDManager.commsGood : false

    // General properties
    property var  _activeVehicle:       beeCopter.multiVehicleManager.activeVehicle
    property var  _offlineVehicle:      beeCopter.multiVehicleManager.offlineEditingVehicle
    property int  _regionOperation:     beeCopter.settingsManager.remoteIDSettings.region.value
    property int  _locationType:        beeCopter.settingsManager.remoteIDSettings.locationType.value
    property int  _classificationType:  beeCopter.settingsManager.remoteIDSettings.classificationType.value
    property var  _remoteIDManager:     _activeVehicle ? _activeVehicle.remoteIDManager : null


    property var  remoteIDSettings:beeCopter.settingsManager.remoteIDSettings
    property Fact regionFact:           remoteIDSettings.region
    property Fact sendOperatorIdFact:   remoteIDSettings.sendOperatorID
    property Fact locationTypeFact:     remoteIDSettings.locationType
    property Fact operatorIDFact:       remoteIDSettings.operatorID
    property bool isEURegion:           regionFact.rawValue === RemoteIDSettings.RegionOperation.EU
    property bool isFAARegion:          regionFact.rawValue === RemoteIDSettings.RegionOperation.FAA
    property real textFieldWidth:       ScreenTools.defaultFontPixelWidth * 24
    property real textLabelWidth:       ScreenTools.defaultFontPixelWidth * 30

    // GPS properties
    property var    gcsPosition:        beeCopter.beeCopterPositionManger.gcsPosition
    property real   gcsHeading:         beeCopter.beeCopterPositionManger.gcsHeading
    property real   gcsHDOP:            beeCopter.beeCopterPositionManger.gcsPositionHorizontalAccuracy
    property string gpsDisabled:        "Disabled"
    property string gpsUdpPort:         "UDP Port"

    beeCopterPalette { id: beeCopterPal }

    // Function to get the corresponding Self ID label depending on the Self ID Type selected
    function getSelfIdLabelText() {
        switch (selfIDComboBox.currentIndex) {
        case 0:
            return beeCopter.settingsManager.remoteIDSettings.selfIDFree.shortDescription
            break
        case 1:
            return beeCopter.settingsManager.remoteIDSettings.selfIDEmergency.shortDescription
            break
        case 2:
            return beeCopter.settingsManager.remoteIDSettings.selfIDExtended.shortDescription
            break
        default:
            return beeCopter.settingsManager.remoteIDSettings.selfIDFree.shortDescription
        }
    }

    // Function to get the corresponding Self ID fact depending on the Self ID Type selected
    function getSelfIDFact() {
        switch (selfIDComboBox.currentIndex) {
        case 0:
            return beeCopter.settingsManager.remoteIDSettings.selfIDFree
            break
        case 1:
            return beeCopter.settingsManager.remoteIDSettings.selfIDEmergency
            break
        case 2:
            return beeCopter.settingsManager.remoteIDSettings.selfIDExtended
            break
        default:
            return beeCopter.settingsManager.remoteIDSettings.selfIDFree
        }
    }


    Item {
        id:                 flagsItem
        width:              parent.width
        height:             flagsColumn.height
        Layout.alignment:   Qt.AlignHCenter

        ColumnLayout {
            id:                         flagsColumn
            anchors.horizontalCenter:   parent.horizontalCenter
            spacing:                    _margins

            // ---------------------------------------- STATUS -----------------------------------------
            // Status flags. Visual representation for the state of all necesary information for remoteID
            // to work propely.
            Rectangle {
                id:                     flagsRectangle
                Layout.preferredHeight: statusGrid.height + (_margins * 2)
                Layout.preferredWidth:  statusGrid.width + (_margins * 2)
                color:                  beeCopterPal.windowShade
                visible:                _activeVehicle
                Layout.fillWidth:       true

                GridLayout {
                    id:                         statusGrid
                    anchors.margins:            _margins
                    anchors.top:                parent.top
                    anchors.horizontalCenter:   parent.horizontalCenter
                    rows:                       1
                    rowSpacing:                 _margins * 3
                    columnSpacing:              _margins * 2

                    Rectangle {
                        id:                     armFlag
                        Layout.preferredHeight: flagsHeight
                        Layout.preferredWidth:  flagsWidth
                        color:                  _activeRID ? (_remoteIDManager.armStatusGood ? beeCopterPal.colorGreen : beeCopterPal.colorRed) : beeCopterPal.colorGrey
                        radius:                 radiusFlags
                        visible:                commsGood

                        beeCopterLabel {
                            anchors.fill:           parent
                            text:                   qsTr("ARM STATUS")
                            wrapMode:               Text.WordWrap
                            horizontalAlignment:    Text.AlignHCenter
                            verticalAlignment:      Text.AlignVCenter
                            font.bold:              true
                        }
                    }

                    Rectangle {
                        id:                     commsFlag
                        Layout.preferredHeight: flagsHeight
                        Layout.preferredWidth:  flagsWidth
                        color:                  _activeRID ? (_remoteIDManager.commsGood ? beeCopterPal.colorGreen : beeCopterPal.colorRed) : beeCopterPal.colorGrey
                        radius:                 radiusFlags

                        beeCopterLabel {
                            anchors.fill:           parent
                            text:                   _activeRID && _remoteIDManager.commsGood ? qsTr("RID COMMS") : qsTr("NOT CONNECTED")
                            wrapMode:               Text.WordWrap
                            horizontalAlignment:    Text.AlignHCenter
                            verticalAlignment:      Text.AlignVCenter
                            font.bold:              true
                        }
                    }

                    Rectangle {
                        id:                     gpsFlag
                        Layout.preferredHeight: flagsHeight
                        Layout.preferredWidth:  flagsWidth
                        color:                  _activeRID ? (_remoteIDManager.gcsGPSGood ? beeCopterPal.colorGreen : beeCopterPal.colorRed) : beeCopterPal.colorGrey
                        radius:                 radiusFlags
                        visible:                commsGood

                        beeCopterLabel {
                            anchors.fill:           parent
                            text:                   qsTr("GCS GPS")
                            wrapMode:               Text.WordWrap
                            horizontalAlignment:    Text.AlignHCenter
                            verticalAlignment:      Text.AlignVCenter
                            font.bold:              true
                        }
                    }

                    Rectangle {
                        id:                     basicIDFlag
                        Layout.preferredHeight: flagsHeight
                        Layout.preferredWidth:  flagsWidth
                        color:                  _activeRID ? (_remoteIDManager.basicIDGood ? beeCopterPal.colorGreen : beeCopterPal.colorRed) : beeCopterPal.colorGrey
                        radius:                 radiusFlags
                        visible:                commsGood

                        beeCopterLabel {
                            anchors.fill:           parent
                            text:                   qsTr("BASIC ID")
                            wrapMode:               Text.WordWrap
                            horizontalAlignment:    Text.AlignHCenter
                            verticalAlignment:      Text.AlignVCenter
                            font.bold:              true
                        }
                    }

                    Rectangle {
                        id:                     operatorIDFlag
                        Layout.preferredHeight: flagsHeight
                        Layout.preferredWidth:  flagsWidth
                        color:                  _activeRID ? (_remoteIDManager.operatorIDGood ? beeCopterPal.colorGreen : beeCopterPal.colorRed) : beeCopterPal.colorGrey
                        radius:                 radiusFlags
                        visible:                commsGood && _activeRID ? (beeCopter.settingsManager.remoteIDSettings.sendOperatorID.value || _regionOperation == RemoteIDSettings.RegionOperation.EU) : false

                        beeCopterLabel {
                            anchors.fill:           parent
                            text:                   qsTr("OPERATOR ID")
                            wrapMode:               Text.WordWrap
                            horizontalAlignment:    Text.AlignHCenter
                            verticalAlignment:      Text.AlignVCenter
                            font.bold:              true
                        }
                    }
                }
            }
        }
    }

    RowLayout {
        spacing: ScreenTools.defaultFontPixelWidth

        Connections {
            target: regionFact
            function onRawValueChanged(value) {
                if (value === RemoteIDSettings.RegionOperation.EU) {
                    sendOperatorIdFact.rawValue = true
                } else if (value === RemoteIDSettings.RegionOperation.FAA) {
                    locationTypeFact.value = RemoteIDSettings.LocationType.LIVE
                }
            }
        }

        ColumnLayout {
            spacing:            ScreenTools.defaultFontPixelHeight / 2
            Layout.alignment:   Qt.AlignTop

            SettingsGroupLayout {
                Layout.fillWidth:   true

                LabelledFactComboBox {
                    label:              fact.shortDescription
                    fact:               beeCopter.settingsManager.remoteIDSettings.region
                    visible:            beeCopter.settingsManager.remoteIDSettings.region.visible
                    Layout.fillWidth:   true
                }
            }
            SettingsGroupLayout {
                outerBorderColor: _activeRID ? (_remoteIDManager.armStatusGood ? defaultBorderColor : beeCopterPal.colorRed) : defaultBorderColor
                visible:            armStatusLabel.labelText !== ""
                LabelledLabel {
                    id :                armStatusLabel
                    label:              qsTr("Arm Status Error")
                    labelText:          _remoteIDManager?_remoteIDManager.armStatusError:"Vehicle Not Connected"
                    visible:            labelText !== ""
                    Layout.fillWidth:   true
                }
            }

            SettingsGroupLayout {
                heading:                qsTr("Basic ID")
                headingDescription:     qsTr("If Basic ID is already set on the RID device, this will be registered as Basic ID 2")
                Layout.fillWidth:       true
                Layout.preferredWidth:  textLabelWidth
                outerBorderColor:       _activeRID ? (_remoteIDManager.basicIDGood ? defaultBorderColor : beeCopterPal.colorRed) : defaultBorderColor


                FactCheckBoxSlider {
                    id:                 sendBasicIDSlider
                    text:               qsTr("Broadcast")
                    fact:               _fact
                    visible:            _fact.visible
                    Layout.fillWidth:   true

                    property Fact _fact: remoteIDSettings.sendBasicID
                }

                LabelledFactComboBox {
                    id:                 basicIDTypeCombo
                    label:              _fact.shortDescription
                    fact:               _fact
                    indexModel:         false
                    visible:            _fact.visible
                    enabled:            sendBasicIDSlider._fact.rawValue
                    Layout.fillWidth:   true

                    property Fact _fact: remoteIDSettings.basicIDType
                }

                LabelledFactComboBox {
                    label:              _fact.shortDescription
                    fact:               _fact
                    indexModel:         false
                    visible:            _fact.visible
                    enabled:            sendBasicIDSlider._fact.rawValue
                    Layout.fillWidth:   true

                    property Fact _fact: remoteIDSettings.basicIDUaType
                }

                LabelledFactTextField {
                    label:                      _fact.shortDescription
                    fact:                       _fact
                    visible:                    _fact.visible
                    enabled:            sendBasicIDSlider._fact.rawValue
                    textField.maximumLength:    20
                    Layout.fillWidth:           true
                    textFieldPreferredWidth:    textFieldWidth

                    property Fact _fact: remoteIDSettings.basicID
                }
            }

            SettingsGroupLayout {
                heading:            qsTr("Operator ID")
                Layout.fillWidth:   true

                FactCheckBoxSlider {
                    text:               qsTr("Broadcast%1").arg(isEURegion ? " (EU Required)" : "")
                    fact:               sendOperatorIdFact
                    visible:            sendOperatorIdFact.visible
                    enabled:            isFAARegion
                    Layout.fillWidth:   true

                    property Fact _fact: remoteIDSettings.sendOperatorID
                }

                LabelledFactComboBox {
                    id:                 regionOperationCombo
                    label:              _fact.shortDescription
                    fact:               _fact
                    indexModel:         false
                    visible:            _fact.visible && (_fact.enumValues.length > 1)
                    Layout.fillWidth:   true

                    property Fact _fact: remoteIDSettings.operatorIDType
                }

                RowLayout {
                    spacing: ScreenTools.defaultFontPixelWidth * 2

                    beeCopterLabel {
                        Layout.fillWidth:   true
                        text:               operatorIDFact.shortDescription + (regionOperationCombo.visible ? "" :  qsTr(" (%1)").arg(regionOperationCombo.comboBox.currentText))
                    }

                    beeCopterTextField {
                        id:                     operatorIDTextField
                        Layout.preferredWidth:  textFieldWidth
                        Layout.fillWidth:       true
                        text:                   operatorIDFact.valueString
                        visible:                operatorIDFact.visible
                        maximumLength:          20                  // Maximum defined by Mavlink definition of OPEN_DRONE_ID_OPERATOR_ID message

                        property bool operatorIDInvalid: ((_regionOperation === RemoteIDSettings.RegionOperation.EU || remoteIDSettings.sendOperatorID.value) &&
                                                            _activeRID && !_remoteIDManager.operatorIDGood)

                        onOperatorIDInvalidChanged: {
                            if (operatorIDInvalid) {
                                operatorIDTextField.showValidationError(qsTr("Invalid Operator ID"), operatorIDFact.valueString, false /* preventViewSwitch */)
                            } else {
                                operatorIDTextField.clearValidationError(false /* preventViewSwitch */)
                            }
                        }

                        onTextChanged: {
                            if (_activeVehicle) {
                                _remoteIDManager.checkOperatorID(text)
                            } else {
                                _offlineVehicle.remoteIDManager.checkOperatorID(text)
                            }
                            operatorIDFact.value = text
                        }

                        onEditingFinished: {
                            if (_activeVehicle) {
                                _remoteIDManager.setOperatorID()
                            } else {
                                _offlineVehicle.remoteIDManager.setOperatorID()
                            }
                        }
                    }
                }
            }

            SettingsGroupLayout {
                heading:                qsTr("Self ID")
                headingDescription:     qsTr("If an emergency is declared, Emergency Text will be broadcast even if Broadcast setting is not enabled.")
                Layout.fillWidth:       true
                Layout.preferredWidth:  textLabelWidth

                FactCheckBoxSlider {
                    id:                 sendSelfIDSlider
                    text:               qsTr("Broadcast")
                    fact:               _fact
                    visible:            _fact.visible
                    Layout.fillWidth:   true

                    property Fact _fact: remoteIDSettings.sendSelfID
                }

                LabelledFactComboBox {
                    id:                 selfIDTypeCombo
                    label:              qsTr("Broadcast Message")
                    fact:               _fact
                    indexModel:         false
                    visible:            _fact.visible
                    enabled:            sendSelfIDSlider._fact.rawValue
                    Layout.fillWidth:   true

                    property Fact _fact: remoteIDSettings.selfIDType
                }

                LabelledFactTextField {
                    label:                      _fact.shortDescription
                    fact:                       _fact
                    visible:                    _fact.visible
                    enabled:                     sendSelfIDSlider._fact.rawValue
                    textField.maximumLength:    23
                    Layout.fillWidth:           true
                    textFieldPreferredWidth:    textFieldWidth

                    property Fact _fact: remoteIDSettings.selfIDFree
                }

                LabelledFactTextField {
                    label:                      _fact.shortDescription
                    fact:                       _fact
                    visible:                    _fact.visible
                    enabled:                    sendSelfIDSlider._fact.rawValue
                    textField.maximumLength:    23
                    Layout.fillWidth:           true
                    textFieldPreferredWidth:    textFieldWidth

                    property Fact _fact: remoteIDSettings.selfIDExtended
                }

                LabelledFactTextField {
                    label:                      _fact.shortDescription
                    fact:                       _fact
                    visible:                    _fact.visible
                    textField.maximumLength:    23
                    Layout.fillWidth:           true
                    textFieldPreferredWidth:    textFieldWidth

                    property Fact _fact: remoteIDSettings.selfIDEmergency
                }
            }
        }

        ColumnLayout {
            spacing:            ScreenTools.defaultFontPixelHeight / 2
            Layout.alignment:   Qt.AlignTop
            SettingsGroupLayout {
                heading:            qsTr("GroundStation Location")
                Layout.fillWidth:   true
                outerBorderColor : _activeRID ? (_remoteIDManager.gcsGPSGood ? defaultBorderColor : beeCopterPal.colorRed) : defaultBorderColor
                LabelledFactComboBox {
                    label:              locationTypeFact.shortDescription
                    fact:               locationTypeFact
                    indexModel:         false
                    Layout.fillWidth:   true
                }

                LabelledFactTextField {
                    label:                      _fact.shortDescription
                    fact:                       _fact
                    textField.maximumLength:    20
                    enabled:                    locationTypeFact.rawValue === RemoteIDSettings.LocationType.FIXED
                    Layout.fillWidth:           true
                    textFieldPreferredWidth:    textFieldWidth

                    property Fact _fact: remoteIDSettings.latitudeFixed
                }

                LabelledFactTextField {
                    label:                      _fact.shortDescription
                    fact:                       _fact
                    textField.maximumLength:    20
                    enabled:                    locationTypeFact.rawValue === RemoteIDSettings.LocationType.FIXED
                    Layout.fillWidth:           true
                    textFieldPreferredWidth:    textFieldWidth

                    property Fact _fact: remoteIDSettings.longitudeFixed
                }

                LabelledFactTextField {
                    label:                      _fact.shortDescription
                    fact:                       _fact
                    textField.maximumLength:    20
                    enabled:                    locationTypeFact.rawValue === RemoteIDSettings.LocationType.FIXED
                    Layout.fillWidth:           true
                    textFieldPreferredWidth:    textFieldWidth

                    property Fact _fact: remoteIDSettings.altitudeFixed
                }

                GridLayout {
                    id:                         gpsGrid
                    visible:                    !ScreenTools.isMobile
                                                && beeCopter.settingsManager.autoConnectSettings.autoConnectNmeaPort.visible
                                                && beeCopter.settingsManager.autoConnectSettings.autoConnectNmeaBaud.visible
                                                && _locationType !== RemoteIDSettings.LocationType.TAKEOFF
                    anchors.margins:            _margins
                    rowSpacing:                 _margins * 3
                    columns:                    2
                    columnSpacing:              _margins * 2
                    Layout.alignment:           Qt.AlignHCenter

                    beeCopterLabel {
                        text: qsTr("NMEA External GPS Device")
                    }
                    beeCopterComboBox {
                        id:                     nmeaPortCombo
                        Layout.preferredWidth:  _comboFieldWidth

                        model:  ListModel {
                        }

                        onActivated: (index) => {
                                         if (index !== -1) {
                                             beeCopter.settingsManager.autoConnectSettings.autoConnectNmeaPort.value = textAt(index);
                                         }
                                     }
                        Component.onCompleted: {
                            model.append({text: gpsDisabled})
                            model.append({text: gpsUdpPort})

                            for (var i in beeCopter.linkManager.serialPorts) {
                                nmeaPortCombo.model.append({text:beeCopter.linkManager.serialPorts[i]})
                            }
                            var index = nmeaPortCombo.find(beeCopter.settingsManager.autoConnectSettings.autoConnectNmeaPort.valueString);
                            nmeaPortCombo.currentIndex = index;
                            if (beeCopter.linkManager.serialPorts.length === 0) {
                                nmeaPortCombo.model.append({text: "Serial <none available>"})
                            }
                        }
                    }

                    beeCopterLabel {
                        visible:          nmeaPortCombo.currentText !== gpsUdpPort && nmeaPortCombo.currentText !== gpsDisabled
                        text:             qsTr("NMEA GPS Baudrate")
                    }
                    beeCopterComboBox {
                        visible:                nmeaPortCombo.currentText !== gpsUdpPort && nmeaPortCombo.currentText !== gpsDisabled
                        id:                     nmeaBaudCombo
                        Layout.preferredWidth:  _comboFieldWidth
                        model:                  [1200, 2400, 4800, 9600, 19200, 38400, 57600, 115200, 230400, 460800, 921600]

                        onActivated: (index) => {
                                         if (index !== -1) {
                                             beeCopter.settingsManager.autoConnectSettings.autoConnectNmeaBaud.value = textAt(index);
                                         }
                                     }
                        Component.onCompleted: {
                            var index = nmeaBaudCombo.find(beeCopter.settingsManager.autoConnectSettings.autoConnectNmeaBaud.valueString);
                            nmeaBaudCombo.currentIndex = index;
                        }
                    }

                    beeCopterLabel {
                        text:       qsTr("NMEA stream UDP port")
                        visible:    nmeaPortCombo.currentText === gpsUdpPort
                    }
                    FactTextField {
                        visible:                nmeaPortCombo.currentText === gpsUdpPort
                        Layout.preferredWidth:  _valueFieldWidth
                        fact:                   beeCopter.settingsManager.autoConnectSettings.nmeaUdpPort
                    }
                }
            }


            SettingsGroupLayout {
                heading:            qsTr("EU Vehicle Info")
                visible:            isEURegion
                Layout.fillWidth:   true

                beeCopterCheckBoxSlider {
                    id:                 euProvideInfoSlider
                    text:               qsTr("Provide Information")
                    checked:            _fact.rawValue === RemoteIDSettings.ClassificationType.EU
                    visible:            _fact.visible
                    Layout.fillWidth:   true
                    onClicked:          _fact.rawValue = !_fact.rawValue

                    property Fact _fact: remoteIDSettings.classificationType
                }

                LabelledFactComboBox {
                    id:                 euCategoryCombo
                    label:              _fact.shortDescription
                    fact:               _fact
                    indexModel:         false
                    visible:            _fact.visible
                    enabled:            euProvideInfoSlider.checked
                    Layout.fillWidth:   true

                    property Fact _fact: remoteIDSettings.categoryEU
                }

                LabelledFactComboBox {
                    label:              _fact.shortDescription
                    fact:               _fact
                    indexModel:         false
                    visible:            _fact.visible
                    enabled:            euCategoryCombo.enabled
                    Layout.fillWidth:   true

                    property Fact _fact: remoteIDSettings.classEU
                }
            }
        }
    }

}
