import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls
import beeCopter.FactControls

Item {
    id: root

    property bool listViewLoadCompleted: false

    Item {
        id:             panel
        anchors.fill:   parent

        Rectangle {
            id:              logwindow
            anchors.fill:    parent
            anchors.margins: ScreenTools.defaultFontPixelWidth
            color:           beeCopterPal.window

            Component {
                id: delegateItem
                Rectangle {
                    color:  index % 2 == 0 ? beeCopterPal.window : beeCopterPal.windowShade
                    height: Math.round(ScreenTools.defaultFontPixelHeight * 0.5 + field.height)
                    width:  listView.width

                    beeCopterLabel {
                        id:         field
                        text:       display
                        width:      parent.width
                        wrapMode:   Text.Wrap
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            beeCopterListView {
                id:                     listView
                anchors.top:            parent.top
                anchors.left:           parent.left
                anchors.right:          parent.right
                anchors.bottom:         followTail.top
                anchors.bottomMargin:   ScreenTools.defaultFontPixelWidth
                clip:                   true
                model:                  debugMessageModel
                delegate:               delegateItem

                function scrollToEnd() {
                    if (listViewLoadCompleted) {
                        if (followTail.checked) {
                            listView.positionViewAtEnd();
                        }
                    }
                }

                Component.onCompleted: {
                    listViewLoadCompleted = true
                    listView.scrollToEnd()
                }

                Connections {
                    target:         debugMessageModel
                    function onDataChanged(topLeft, bottomRight, roles) { listView.scrollToEnd() }
                }
            }

            beeCopterFileDialog {
                id:             writeDialog
                folder:         beeCopter.settingsManager.appSettings.logSavePath
                nameFilters:    [qsTr("Log files (*.txt)"), qsTr("All Files (*)")]
                title:          qsTr("Select log save file")
                onAcceptedForSave: (file) => {
                    debugMessageModel.writeMessages(file);
                    visible = false;
                }
            }

            Connections {
                target:          debugMessageModel
                function onWriteStarted() { writeButton.enabled = false }
                function onWriteFinished(success) { writeButton.enabled = true }
            }

            beeCopterButton {
                id:              writeButton
                anchors.bottom:  parent.bottom
                anchors.left:    parent.left
                onClicked:       writeDialog.openForSave()
                text:            qsTr("Save App Log")
            }

            beeCopterLabel {
                id:                     gstLabel
                anchors.left:           writeButton.right
                anchors.leftMargin:     ScreenTools.defaultFontPixelWidth
                anchors.verticalCenter: gstCombo.verticalCenter
                text:                   qsTr("GStreamer Debug Level")
                visible:                beeCopter.settingsManager.appSettings.gstDebugLevel.visible
            }

            FactComboBox {
                id:                 gstCombo
                anchors.left:       gstLabel.right
                anchors.leftMargin: ScreenTools.defaultFontPixelWidth / 2
                anchors.bottom:     parent.bottom
                fact:               beeCopter.settingsManager.appSettings.gstDebugLevel
                visible:            beeCopter.settingsManager.appSettings.gstDebugLevel.visible
                sizeToContents:     true
            }

            beeCopterButton {
                id:                     followTail
                anchors.right:          filterButton.left
                anchors.rightMargin:    ScreenTools.defaultFontPixelWidth
                anchors.bottom:         parent.bottom
                text:                   qsTr("Show Latest")
                checkable:              true
                checked:                true

                onCheckedChanged: {
                    if (checked && listViewLoadCompleted) {
                        listView.positionViewAtEnd();
                    }
                }
            }

            beeCopterButton {
                id:             filterButton
                anchors.bottom: parent.bottom
                anchors.right:  parent.right
                text:           qsTr("Set Logging")
                onClicked:      filtersDialogComponent.createObject(mainWindow).open()
            }
        }
    }

    Component {
        id: filtersDialogComponent

        beeCopterPopupDialog {
            title:      qsTr("Logging")
            buttons:    Dialog.Close

            ColumnLayout {
                width: maxContentAvailableWidth

                SettingsGroupLayout {
                    heading:            qsTr("Search")
                    Layout.fillWidth:   true

                    RowLayout {
                        Layout.fillWidth:   true
                        spacing:            ScreenTools.defaultFontPixelHeight / 2

                        beeCopterTextField {
                            Layout.fillWidth:   true
                            id:                 searchText
                            text:               ""
                            enabled:            true
                        }

                        beeCopterButton {
                            text:       qsTr("Clear")
                            onClicked:  searchText.text = ""
                        }
                    }
                }

                SettingsGroupLayout {
                    heading:            qsTr("Enabled Categories")
                    Layout.fillWidth:   true

                    Flow {
                        Layout.fillWidth:   true
                        spacing:            ScreenTools.defaultFontPixelHeight / 2

                        Repeater {
                            model: beeCopter.flatLoggingCategoriesModel()

                            beeCopterCheckBoxSlider {
                                Layout.fillWidth:       true
                                Layout.maximumHeight:   visible ? implicitHeight : 0
                                text:                   object.fullCategory
                                visible:                object.enabled
                                checked:                object.enabled
                                onClicked:              object.enabled = checked
                            }
                        }

                        beeCopterButton {
                            text:       qsTr("Disable All")
                            onClicked:  beeCopter.disableAllLoggingCategories()
                        }
                    }
                }

                // Shown when not filtered
                Flow {
                    Layout.fillWidth:   true
                    spacing:            ScreenTools.defaultFontPixelHeight / 2
                    visible:            searchText.text === ""

                    Repeater {
                        model: beeCopter.treeLoggingCategoriesModel()

                        ColumnLayout {
                            spacing: ScreenTools.defaultFontPixelHeight / 2

                            RowLayout {
                                spacing:                ScreenTools.defaultFontPixelWidth

                                beeCopterLabel {
                                    Layout.preferredWidth:  ScreenTools.defaultFontPixelWidth
                                    text:                   object.expanded ? qsTr("-") : qsTr("+")
                                    horizontalAlignment:    Text.AlignLeft
                                    visible:                object.children

                                    beeCopterMouseArea {
                                        anchors.fill:   parent
                                        onClicked:      object.expanded = !object.expanded
                                    }
                                }

                                beeCopterCheckBoxSlider {
                                    Layout.fillWidth:   true
                                    text:               object.shortCategory
                                    checked:            object.enabled
                                    onClicked:          object.enabled = checked
                                }
                            }

                            Repeater {
                                model: object.expanded ? object.children : undefined

                                beeCopterCheckBoxSlider {
                                    Layout.fillWidth:   true
                                    text:               "   " + object.shortCategory
                                    checked:            object.enabled
                                    onClicked:          object.enabled = checked
                                }
                            }
                        }
                    }
                }

                // Shown when filtered
                Flow {
                    Layout.fillWidth:   true
                    spacing:            ScreenTools.defaultFontPixelHeight / 2
                    visible:            searchText.text !== ""

                    Repeater {
                        model: beeCopter.flatLoggingCategoriesModel()

                        beeCopterCheckBoxSlider {
                            Layout.fillWidth:       true
                            Layout.maximumHeight:   visible ? implicitHeight : 0
                            text:                   object.fullCategory
                            visible:                text.match(`(${searchText.text})`, "i")
                            checked:                object.enabled
                            onClicked:              object.enabled = checked
                        }
                    }
                }
            }
        }
    }
}
