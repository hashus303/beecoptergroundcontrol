import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.qmlmodels

import beeCopter
import beeCopter.Controls

AnalyzePage {
    id: logDownloadPage
    pageComponent: pageComponent
    pageDescription: qsTr("Log Download allows you to download binary log files from your vehicle. Click Refresh to get list of available logs.")

    Component {
        id: pageComponent

        RowLayout {
            width: availableWidth
            height: availableHeight

            beeCopterFlickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: gridLayout.width
                contentHeight: gridLayout.height

                GridLayout {
                    id: gridLayout
                    rows: LogDownloadController.model.count + 1
                    columns: 5
                    flow: GridLayout.TopToBottom
                    columnSpacing: ScreenTools.defaultFontPixelWidth
                    rowSpacing: 0

                    beeCopterCheckBox {
                        id: headerCheckBox
                        enabled: false
                    }

                    Repeater {
                        model: LogDownloadController.model

                        beeCopterCheckBox {
                            Binding on checkState {
                                value: object.selected ? Qt.Checked : Qt.Unchecked
                            }

                            onClicked: object.selected = checked
                        }
                    }

                    beeCopterLabel { text: qsTr("Id") }

                    Repeater {
                        model: LogDownloadController.model

                        beeCopterLabel { text: object.id }
                    }

                    beeCopterLabel { text: qsTr("Date") }

                    Repeater {
                        model: LogDownloadController.model

                        beeCopterLabel {
                            text: {
                                if (!object.received) {
                                    return ""
                                }

                                if (object.time.getUTCFullYear() < 2010) {
                                    return qsTr("Date Unknown")
                                }

                                return object.time.toLocaleString(undefined)
                            }
                        }
                    }

                    beeCopterLabel { text: qsTr("Size") }

                    Repeater {
                        model: LogDownloadController.model

                        beeCopterLabel { text: object.sizeStr }
                    }

                    beeCopterLabel { text: qsTr("Status") }

                    Repeater {
                        model: LogDownloadController.model

                        beeCopterLabel { text: object.status }
                    }
                }
            }

            ColumnLayout {
                spacing: ScreenTools.defaultFontPixelWidth
                Layout.alignment: Qt.AlignTop
                Layout.fillWidth: false

                beeCopterButton {
                    Layout.fillWidth: true
                    enabled: !LogDownloadController.requestingList && !LogDownloadController.downloadingLogs
                    text: qsTr("Refresh")

                    onClicked: {
                        if (!beeCopter.multiVehicleManager.activeVehicle || beeCopter.multiVehicleManager.activeVehicle.isOfflineEditingVehicle) {
                            mainWindow.showMessageDialog(qsTr("Log Refresh"), qsTr("You must be connected to a vehicle in order to download logs."))
                            return
                        }

                        LogDownloadController.refresh()
                    }
                }

                beeCopterButton {
                    Layout.fillWidth: true
                    enabled: !LogDownloadController.requestingList && !LogDownloadController.downloadingLogs
                    text: qsTr("Download")

                    onClicked: {
                        var logsSelected = false
                        for (var i = 0; i < LogDownloadController.model.count; i++) {
                            if (LogDownloadController.model.get(i).selected) {
                                logsSelected = true
                                break
                            }
                        }

                        if (!logsSelected) {
                            mainWindow.showMessageDialog(qsTr("Log Download"), qsTr("You must select at least one log file to download."))
                            return
                        }

                        if (ScreenTools.isMobile) {
                            LogDownloadController.download()
                            return
                        }

                        fileDialog.title = qsTr("Select save directory")
                        fileDialog.folder = beeCopter.settingsManager.appSettings.logSavePath
                        fileDialog.selectFolder = true
                        fileDialog.openForLoad()
                    }

                    beeCopterFileDialog {
                        id: fileDialog
                        onAcceptedForLoad: (file) => {
                            LogDownloadController.download(file)
                            close()
                        }
                    }
                }

                beeCopterButton {
                    Layout.fillWidth: true
                    enabled: !LogDownloadController.requestingList && !LogDownloadController.downloadingLogs && (LogDownloadController.model.count > 0)
                    text: qsTr("Erase All")
                    onClicked: mainWindow.showMessageDialog(
                        qsTr("Delete All Log Files"),
                        qsTr("All log files will be erased permanently. Is this really what you want?"),
                        Dialog.Yes | Dialog.No,
                        function() { LogDownloadController.eraseAll() }
                    )
                }

                beeCopterButton {
                    Layout.fillWidth: true
                    text: qsTr("Cancel")
                    enabled: LogDownloadController.requestingList || LogDownloadController.downloadingLogs
                    onClicked: LogDownloadController.cancel()
                }
            }
        }
    }
}
