import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls
import beeCopter.FactControls

SettingsPage {
    property var _linkManager:          beeCopter.linkManager
    property var _autoConnectSettings:  beeCopter.settingsManager.autoConnectSettings

    SettingsGroupLayout {
        heading:        qsTr("AutoConnect")
        visible:        _autoConnectSettings.visible

        Repeater {
            id: autoConnectRepeater

            model: [
                _autoConnectSettings.autoConnectPixhawk,
                _autoConnectSettings.autoConnectSiKRadio,
                _autoConnectSettings.autoConnectLibrePilot,
                _autoConnectSettings.autoConnectUDP,
                _autoConnectSettings.autoConnectZeroConf,
                _autoConnectSettings.autoConnectRTKGPS,
            ]

            property var names: [ qsTr("Pixhawk"), qsTr("SiK Radio"), qsTr("LibrePilot"), qsTr("UDP"), qsTr("Zero-Conf"), qsTr("RTK") ]

            FactCheckBoxSlider {
                Layout.fillWidth:   true
                text:               autoConnectRepeater.names[index]
                fact:               modelData
                visible:            modelData.visible
            }
        }
    }

    SettingsGroupLayout {
        heading: qsTr("NMEA GPS")
        visible: beeCopter.settingsManager.autoConnectSettings.autoConnectNmeaPort.visible && beeCopter.settingsManager.autoConnectSettings.autoConnectNmeaBaud.visible

        LabelledComboBox {
            id: nmeaPortCombo
            label: qsTr("Device")

            model: ListModel {}

            onActivated: (index) => {
                if (index !== -1) {
                    beeCopter.settingsManager.autoConnectSettings.autoConnectNmeaPort.value = comboBox.textAt(index);
                }
            }

            Component.onCompleted: {
                var model = []

                model.push(qsTr("Disabled"))
                model.push(qsTr("UDP Port"))

                if (beeCopter.linkManager.serialPorts.length === 0) {
                    model.push(qsTr("Serial <none available>"))
                } else {
                    for (var i in beeCopter.linkManager.serialPorts) {
                        model.push(beeCopter.linkManager.serialPorts[i])
                    }
                }
                nmeaPortCombo.model = model

                const index = nmeaPortCombo.comboBox.find(beeCopter.settingsManager.autoConnectSettings.autoConnectNmeaPort.valueString);
                nmeaPortCombo.currentIndex = index;
            }
        }

        LabelledComboBox {
            id: nmeaBaudCombo
            visible: (nmeaPortCombo.currentText !== "UDP Port") && (nmeaPortCombo.currentText !== "Disabled")
            label: qsTr("Baudrate")
            model: beeCopter.linkManager.serialBaudRates

            onActivated: (index) => {
                if (index !== -1) {
                    beeCopter.settingsManager.autoConnectSettings.autoConnectNmeaBaud.value = parseInt(comboBox.textAt(index));
                }
            }

            Component.onCompleted: {
                const index = nmeaBaudCombo.comboBox.find(beeCopter.settingsManager.autoConnectSettings.autoConnectNmeaBaud.valueString);
                nmeaBaudCombo.currentIndex = index;
            }
        }

        LabelledFactTextField {
            visible: nmeaPortCombo.currentText === "UDP Port"
            label: qsTr("NMEA stream UDP port")
            fact: beeCopter.settingsManager.autoConnectSettings.nmeaUdpPort
        }
    }

    SettingsGroupLayout {
        heading: qsTr("Links")

        Repeater {
            model: _linkManager.linkConfigurations

            RowLayout {
                Layout.fillWidth:   true
                visible:            !object.dynamic

                beeCopterLabel {
                    Layout.fillWidth:   true
                    text:               object.name
                }
                beeCopterColoredImage {
                    height:                 ScreenTools.minTouchPixels
                    width:                  height
                    sourceSize.height:      height
                    fillMode:               Image.PreserveAspectFit
                    mipmap:                 true
                    smooth:                 true
                    color:                  beeCopterPalEdit.text
                    source:                 "/res/pencil.svg"
                    enabled:                !object.link

                    beeCopterPalette {
                        id: beeCopterPalEdit
                        colorGroupEnabled: parent.enabled
                    }

                    beeCopterMouseArea {
                        fillItem: parent
                        onClicked: {
                            var editingConfig = _linkManager.startConfigurationEditing(object)
                            linkDialogComponent.createObject(mainWindow, { editingConfig: editingConfig, originalConfig: object }).open()
                        }
                    }
                }
                beeCopterColoredImage {
                    height:                 ScreenTools.minTouchPixels
                    width:                  height
                    sourceSize.height:      height
                    fillMode:               Image.PreserveAspectFit
                    mipmap:                 true
                    smooth:                 true
                    color:                  beeCopterPalDelete.text
                    source:                 "/res/TrashDelete.svg"

                    beeCopterPalette {
                        id: beeCopterPalDelete
                        colorGroupEnabled: parent.enabled
                    }

                    beeCopterMouseArea {
                        fillItem:   parent
                        onClicked:  mainWindow.showMessageDialog(
                                        qsTr("Delete Link"),
                                        qsTr("Are you sure you want to delete '%1'?").arg(object.name),
                                        Dialog.Ok | Dialog.Cancel,
                                        function () {
                                            _linkManager.removeConfiguration(object)
                                        })
                    }
                }
                beeCopterButton {
                    text:       object.link ? qsTr("Disconnect") : qsTr("Connect")
                    onClicked: {
                        if (object.link) {
                            object.link.disconnect()
                        } else {
                            _linkManager.createConnectedLink(object)
                        }
                    }
                }
            }
        }

        LabelledButton {
            label:      qsTr("Add New Link")
            buttonText: qsTr("Add")

            onClicked: {
                var editingConfig = _linkManager.createConfiguration(ScreenTools.isSerialAvailable ? LinkConfiguration.TypeSerial : LinkConfiguration.TypeUdp, "")
                linkDialogComponent.createObject(mainWindow, { editingConfig: editingConfig, originalConfig: null }).open()
            }
        }
    }

    Component {
        id: linkDialogComponent

        beeCopterPopupDialog {
            title:                  originalConfig ? qsTr("Edit Link") : qsTr("Add New Link")
            buttons:                Dialog.Save | Dialog.Cancel
            acceptButtonEnabled:    nameField.text !== ""

            property var originalConfig
            property var editingConfig

            onAccepted: {
                linkSettingsLoader.item.saveSettings()
                editingConfig.name = nameField.text
                if (originalConfig) {
                    _linkManager.endConfigurationEditing(originalConfig, editingConfig)
                } else {
                    // If it was edited, it's no longer "dynamic"
                    editingConfig.dynamic = false
                    _linkManager.endCreateConfiguration(editingConfig)
                }
            }

            onRejected: _linkManager.cancelConfigurationEditing(editingConfig)

            ColumnLayout {
                spacing: ScreenTools.defaultFontPixelHeight / 2

                RowLayout {
                    Layout.fillWidth:   true
                    spacing:            ScreenTools.defaultFontPixelWidth

                    beeCopterLabel { text: qsTr("Name") }
                    beeCopterTextField {
                        id:                 nameField
                        Layout.fillWidth:   true
                        text:               editingConfig.name
                        placeholderText:    qsTr("Enter name")
                    }
                }

                beeCopterCheckBoxSlider {
                    Layout.fillWidth:   true
                    text:               qsTr("Automatically Connect on Start")
                    checked:            editingConfig.autoConnect
                    onCheckedChanged:   editingConfig.autoConnect = checked
                }

                beeCopterCheckBoxSlider {
                    Layout.fillWidth:   true
                    text:               qsTr("High Latency")
                    checked:            editingConfig.highLatency
                    onCheckedChanged:   editingConfig.highLatency = checked
                }

                LabelledComboBox {
                    label:                  qsTr("Type")
                    enabled:                originalConfig == null
                    model:                  _linkManager.linkTypeStrings
                    Component.onCompleted:  comboBox.currentIndex = editingConfig.linkType

                    onActivated: (index) => {
                        if (index !== editingConfig.linkType) {
                            // Save current name
                            var name = nameField.text
                            // Create new link configuration
                            editingConfig = _linkManager.createConfiguration(index, name)
                        }
                    }
                }

                Loader {
                    id:     linkSettingsLoader
                    source: editingConfig && editingConfig.settingsURL ? editingConfig.settingsURL : ""
                    asynchronous: true

                    property var subEditConfig:         editingConfig
                    property int _firstColumnWidth:     ScreenTools.defaultFontPixelWidth * 12
                    property int _secondColumnWidth:    ScreenTools.defaultFontPixelWidth * 30
                    property int _rowSpacing:           ScreenTools.defaultFontPixelHeight / 2
                    property int _colSpacing:           ScreenTools.defaultFontPixelWidth / 2

                    onStatusChanged: {
                        if (status === Loader.Error) {
                            console.warn("Failed to load link settings page:", source)
                        }
                    }
                }
            }
        }
    }
}
