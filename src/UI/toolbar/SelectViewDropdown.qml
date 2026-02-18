import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls

ToolIndicatorPage {
    id: root

    property real _toolButtonHeight: ScreenTools.defaultFontPixelHeight * 3

    contentComponent: Component {
        GridLayout {
            columns: 2
            columnSpacing: ScreenTools.defaultFontPixelWidth
            rowSpacing: columnSpacing

            SubMenuButton {
                implicitHeight: root._toolButtonHeight
                Layout.fillWidth: true
                text: qsTr("Fly")
                imageResource: "/res/FlyingPaperPlane.svg"
                onClicked: {
                    if (mainWindow.allowViewSwitch()) {
                        mainWindow.closeIndicatorDrawer()
                        mainWindow.showFlyView()
                    }
                }
            }

            SubMenuButton {
                implicitHeight: root._toolButtonHeight
                Layout.fillWidth: true
                text: qsTr("Plan")
                imageResource: "/qmlimages/Plan.svg"
                onClicked: {
                    if (mainWindow.allowViewSwitch()) {
                        mainWindow.closeIndicatorDrawer()
                        mainWindow.showPlanView()
                    }
                }
            }

            SubMenuButton {
                implicitHeight: root._toolButtonHeight
                Layout.fillWidth: true
                text: qsTr("Analyze")
                imageResource: "/qmlimages/Analyze.svg"
                visible: beeCopter.corePlugin.showAdvancedUI
                onClicked: {
                    if (mainWindow.allowViewSwitch()) {
                        mainWindow.closeIndicatorDrawer()
                        mainWindow.showAnalyzeTool()
                    }
                }
            }

            SubMenuButton {
                id: setupButton
                implicitHeight: root._toolButtonHeight
                Layout.fillWidth: true
                text: qsTr("Configure")
                imageResource: "/res/GearWithPaperPlane.svg"
                onClicked: {
                    if (mainWindow.allowViewSwitch()) {
                        mainWindow.closeIndicatorDrawer()
                        mainWindow.showVehicleConfig()
                    }
                }
            }

            SubMenuButton {
                id: settingsButton
                implicitHeight: root._toolButtonHeight
                Layout.fillWidth: true
                text: qsTr("Settings")
                imageResource: "/res/beeCopterLogoWhite.svg"
                visible: !beeCopter.corePlugin.options.combineSettingsAndSetup
                onClicked: {
                    if (mainWindow.allowViewSwitch()) {
                        mainWindow.closeIndicatorDrawer()
                        mainWindow.showSettingsTool()
                    }
                }
            }

            SubMenuButton {
                id: closeButton
                implicitHeight: root._toolButtonHeight
                Layout.fillWidth: true
                text: qsTr("Close")
                imageResource: "/res/OpenDoor.svg"
                onClicked: {
                    if (mainWindow.allowViewSwitch()) {
                        mainWindow.finishCloseProcess()
                    }
                }
            }

            ColumnLayout {
                id: versionColumnLayout
                Layout.fillWidth: true
                Layout.columnSpan: 2
                spacing: 0

                beeCopterLabel {
                    id: versionLabel
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: qsTr("%1 Version").arg(beeCopter.appName)
                    font.pointSize: ScreenTools.smallFontPointSize
                    wrapMode: beeCopterLabel.WordWrap
                }

                beeCopterLabel {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: beeCopter.beeCopterVersion
                    font.pointSize: ScreenTools.smallFontPointSize
                    wrapMode: beeCopterLabel.WrapAnywhere
                }

                beeCopterLabel {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: beeCopter.beeCopterAppDate
                    font.pointSize: ScreenTools.smallFontPointSize
                    wrapMode: beeCopterLabel.WrapAnywhere
                    visible: beeCopter.beeCopterDailyBuild

                    beeCopterMouseArea {
                        anchors.topMargin: -(parent.y - versionLabel.y)
                        anchors.fill: parent

                        onClicked: (mouse) => {
                            if (mouse.modifiers & Qt.ControlModifier) {
                                beeCopter.corePlugin.showTouchAreas = !beeCopter.corePlugin.showTouchAreas
                                showTouchAreasNotification.open()
                            } else if (ScreenTools.isMobile || mouse.modifiers & Qt.ShiftModifier) {
                                mainWindow.closeIndicatorDrawer()
                                if (!beeCopter.corePlugin.showAdvancedUI) {
                                    advancedModeOnConfirmation.open()
                                } else {
                                    advancedModeOffConfirmation.open()
                                }
                            }
                        }

                        // This allows you to change this on mobile
                        onPressAndHold: {
                            beeCopter.corePlugin.showTouchAreas = !beeCopter.corePlugin.showTouchAreas
                            showTouchAreasNotification.open()
                        }
                    }
                }
            }
        }
    }
}
