import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls
import beeCopter.FactControls

ToolIndicatorPage {
    id:         control
    showExpand: true

    property var    linkConfigs:            beeCopter.linkManager.linkConfigurations
    property bool   noLinks:                true
    property var    editingConfig:          null
    property var    autoConnectSettings:    beeCopter.settingsManager.autoConnectSettings

    Component.onCompleted: {
        for (var i = 0; i < linkConfigs.count; i++) {
            var linkConfig = linkConfigs.get(i)
            if (!linkConfig.dynamic && !linkConfig.isAutoConnect) {
                noLinks = false
                break
            }
        }
    }

    contentComponent: Component {
        SettingsGroupLayout {
            heading: qsTr("Select Link to Connect")

            beeCopterLabel {
                text:       qsTr("No Links Configured")
                visible:    noLinks
            }

            Repeater {
                model: linkConfigs

                delegate: beeCopterButton {
                    Layout.fillWidth:   true
                    text:               object.name + (object.link ? " (" + qsTr("Connected") + ")" : "")
                    visible:            !object.dynamic
                    enabled:            !object.link
                    autoExclusive:      true

                    onClicked: {
                        beeCopter.linkManager.createConnectedLink(object)
                        mainWindow.closeIndicatorDrawer()
                    }
                }
            }
        }
    }

    expandedComponent: Component {
        ColumnLayout {
            spacing: ScreenTools.defaultFontPixelHeight / 2

            SettingsGroupLayout {
                LabelledButton {
                    label:      qsTr("Communication Links")
                    buttonText: qsTr("Configure")

                    onClicked: {
                        mainWindow.showSettingsTool(qsTr("Comm Links"))
                        mainWindow.closeIndicatorDrawer()
                    }
                }
            }

            SettingsGroupLayout {
                heading:        qsTr("AutoConnect")
                visible:        autoConnectSettings.visible

                Repeater {
                    id: autoConnectRepeater

                    model: [
                        autoConnectSettings.autoConnectPixhawk,
                        autoConnectSettings.autoConnectSiKRadio,
                        autoConnectSettings.autoConnectLibrePilot,
                        autoConnectSettings.autoConnectUDP,
                        autoConnectSettings.autoConnectZeroConf,
                        autoConnectSettings.autoConnectRTKGPS,
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
        }
    }
}
