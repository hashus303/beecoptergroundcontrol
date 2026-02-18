import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls

AnalyzePage {
    id:                 geoTagPage
    pageComponent:      pageComponent
    pageDescription:    qsTr("Tag images from a survey mission with GPS coordinates from your flight log.")

    readonly property real _margin: ScreenTools.defaultFontPixelWidth

    beeCopterPalette { id: beeCopterPal; colorGroupEnabled: true }

    Component {
        id: pageComponent

        ColumnLayout {
            spacing:    _margin * 2
            width:      availableWidth

            // Status Card
            Rectangle {
                Layout.fillWidth:       true
                Layout.preferredHeight: statusColumn.height + _margin * 2
                color:                  beeCopterPal.windowShade
                radius:                 ScreenTools.defaultFontPixelWidth / 2
                visible:                geoController.inProgress || geoController.errorMessage || geoController.taggedCount > 0

                ColumnLayout {
                    id:                 statusColumn
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    anchors.top:        parent.top
                    anchors.margins:    _margin
                    spacing:            _margin

                    RowLayout {
                        Layout.fillWidth:   true
                        spacing:            _margin
                        visible:            geoController.inProgress

                        BusyIndicator {
                            Layout.preferredWidth:  ScreenTools.defaultFontPixelHeight * 2
                            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 2
                            running:                geoController.inProgress
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: _margin / 2

                            beeCopterLabel {
                                text:               qsTr("Geotagging in progress...")
                                font.bold:          true
                            }

                            ProgressBar {
                                Layout.fillWidth:   true
                                from:               0
                                to:                 100
                                value:              geoController.progress
                            }
                        }
                    }

                    beeCopterLabel {
                        Layout.fillWidth:       true
                        text:                   geoController.errorMessage
                        color:                  beeCopterPal.colorRed
                        font.bold:              true
                        wrapMode:               Text.WordWrap
                        horizontalAlignment:    Text.AlignHCenter
                        visible:                geoController.errorMessage && !geoController.inProgress
                    }

                    beeCopterLabel {
                        Layout.fillWidth:       true
                        text: {
                            if (geoController.taggedCount > 0 && !geoController.inProgress) {
                                let msg = qsTr("Successfully tagged %1 images").arg(geoController.taggedCount)
                                let details = []
                                if (geoController.skippedCount > 0) {
                                    details.push(qsTr("%1 skipped").arg(geoController.skippedCount))
                                }
                                if (geoController.failedCount > 0) {
                                    details.push(qsTr("%1 failed").arg(geoController.failedCount))
                                }
                                if (details.length > 0) {
                                    msg += " (" + details.join(", ") + ")"
                                }
                                return msg
                            }
                            return ""
                        }
                        color:                  geoController.failedCount > 0 ? beeCopterPal.colorOrange : beeCopterPal.colorGreen
                        font.bold:              true
                        horizontalAlignment:    Text.AlignHCenter
                        visible:                geoController.taggedCount > 0 && !geoController.inProgress
                    }
                }
            }

            // Step 1: Log File
            Rectangle {
                Layout.fillWidth:       true
                Layout.preferredHeight: step1Column.height + _margin * 2
                color:                  beeCopterPal.windowShade
                radius:                 ScreenTools.defaultFontPixelWidth / 2

                ColumnLayout {
                    id:                 step1Column
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    anchors.top:        parent.top
                    anchors.margins:    _margin
                    spacing:            _margin

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: _margin

                        Rectangle {
                            Layout.preferredWidth:  ScreenTools.defaultFontPixelHeight * 1.5
                            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.5
                            radius:                 height / 2
                            color:                  geoController.logFile ? beeCopterPal.colorGreen : beeCopterPal.button

                            beeCopterLabel {
                                anchors.centerIn:   parent
                                text:               geoController.logFile ? "\u2713" : "1"
                                color:              geoController.logFile ? "white" : beeCopterPal.buttonText
                                font.bold:          true
                            }
                        }

                        beeCopterLabel {
                            text:       qsTr("Select Flight Log")
                            font.bold:  true
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: _margin

                        beeCopterButton {
                            text:               qsTr("Browse...")
                            enabled:            !geoController.inProgress
                            onClicked:          openLogFile.openForLoad()

                            beeCopterFileDialog {
                                id:             openLogFile
                                title:          qsTr("Select Flight Log")
                                nameFilters:    [qsTr("Flight logs (*.ulg *.bin)"), qsTr("ULog (*.ulg)"), qsTr("DataFlash (*.bin)"), qsTr("All Files (*)")]
                                defaultSuffix:  "ulg"
                                onAcceptedForLoad: (file) => {
                                    geoController.logFile = file
                                    close()
                                }
                            }
                        }

                        beeCopterLabel {
                            Layout.fillWidth:   true
                            text:               geoController.logFile ? geoController.logFile : qsTr("No file selected")
                            elide:              Text.ElideMiddle
                            opacity:            geoController.logFile ? 1.0 : 0.5
                        }
                    }
                }
            }

            // Step 2: Image Directory
            Rectangle {
                Layout.fillWidth:       true
                Layout.preferredHeight: step2Column.height + _margin * 2
                color:                  beeCopterPal.windowShade
                radius:                 ScreenTools.defaultFontPixelWidth / 2

                ColumnLayout {
                    id:                 step2Column
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    anchors.top:        parent.top
                    anchors.margins:    _margin
                    spacing:            _margin

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: _margin

                        Rectangle {
                            Layout.preferredWidth:  ScreenTools.defaultFontPixelHeight * 1.5
                            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.5
                            radius:                 height / 2
                            color:                  geoController.imageDirectory ? beeCopterPal.colorGreen : beeCopterPal.button

                            beeCopterLabel {
                                anchors.centerIn:   parent
                                text:               geoController.imageDirectory ? "\u2713" : "2"
                                color:              geoController.imageDirectory ? "white" : beeCopterPal.buttonText
                                font.bold:          true
                            }
                        }

                        beeCopterLabel {
                            text:       qsTr("Select Image Folder")
                            font.bold:  true
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: _margin

                        beeCopterButton {
                            text:               qsTr("Browse...")
                            enabled:            !geoController.inProgress
                            onClicked:          selectImageDir.openForLoad()

                            beeCopterFileDialog {
                                id:             selectImageDir
                                title:          qsTr("Select Image Folder")
                                selectFolder:   true
                                onAcceptedForLoad: (file) => {
                                    geoController.imageDirectory = file
                                    close()
                                }
                            }
                        }

                        beeCopterLabel {
                            Layout.fillWidth:   true
                            text:               geoController.imageDirectory ? geoController.imageDirectory : qsTr("No folder selected")
                            elide:              Text.ElideMiddle
                            opacity:            geoController.imageDirectory ? 1.0 : 0.5
                        }
                    }
                }
            }

            // Step 3: Save Directory (Optional)
            Rectangle {
                Layout.fillWidth:       true
                Layout.preferredHeight: step3Column.height + _margin * 2
                color:                  beeCopterPal.windowShade
                radius:                 ScreenTools.defaultFontPixelWidth / 2

                ColumnLayout {
                    id:                 step3Column
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    anchors.top:        parent.top
                    anchors.margins:    _margin
                    spacing:            _margin

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: _margin

                        Rectangle {
                            Layout.preferredWidth:  ScreenTools.defaultFontPixelHeight * 1.5
                            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.5
                            radius:                 height / 2
                            color:                  beeCopterPal.button

                            beeCopterLabel {
                                anchors.centerIn:   parent
                                text:               "3"
                                color:              beeCopterPal.buttonText
                                font.bold:          true
                            }
                        }

                        beeCopterLabel {
                            text:       qsTr("Output Folder (Optional)")
                            font.bold:  true
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: _margin

                        beeCopterButton {
                            text:               qsTr("Browse...")
                            enabled:            !geoController.inProgress
                            onClicked:          selectDestDir.openForLoad()

                            beeCopterFileDialog {
                                id:             selectDestDir
                                title:          qsTr("Select Output Folder")
                                selectFolder:   true
                                onAcceptedForLoad: (file) => {
                                    geoController.saveDirectory = file
                                    close()
                                }
                            }
                        }

                        beeCopterLabel {
                            Layout.fillWidth:   true
                            text: {
                                if (geoController.saveDirectory) {
                                    return geoController.saveDirectory
                                } else if (geoController.imageDirectory) {
                                    return geoController.imageDirectory + "/TAGGED"
                                }
                                return qsTr("Default: /TAGGED subfolder")
                            }
                            elide:              Text.ElideMiddle
                            opacity:            geoController.saveDirectory ? 1.0 : 0.5
                        }
                    }
                }
            }

            // Advanced Options
            Rectangle {
                Layout.fillWidth:       true
                Layout.preferredHeight: advancedColumn.height + _margin * 2
                color:                  beeCopterPal.windowShade
                radius:                 ScreenTools.defaultFontPixelWidth / 2

                ColumnLayout {
                    id:                 advancedColumn
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    anchors.top:        parent.top
                    anchors.margins:    _margin
                    spacing:            _margin

                    beeCopterLabel {
                        text:       qsTr("Advanced Options")
                        font.bold:  true
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: _margin

                        beeCopterLabel {
                            text: qsTr("Time Offset (seconds):")
                        }

                        beeCopterTextField {
                            id:                     timeOffsetField
                            Layout.preferredWidth:  ScreenTools.defaultFontPixelWidth * 10
                            text:                   geoController.timeOffsetSecs.toFixed(1)
                            enabled:                !geoController.inProgress
                            inputMethodHints:       Qt.ImhFormattedNumbersOnly
                            validator:              DoubleValidator { bottom: -3600; top: 3600; decimals: 1 }
                            onEditingFinished:      geoController.timeOffsetSecs = parseFloat(text) || 0
                        }

                        beeCopterLabel {
                            Layout.fillWidth:   true
                            text:               qsTr("Adjust if camera clock differs from flight log")
                            opacity:            0.7
                            font.pointSize:     ScreenTools.smallFontPointSize
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: _margin

                        beeCopterCheckBox {
                            id:         previewCheckbox
                            text:       qsTr("Preview mode (don't write files)")
                            checked:    geoController.previewMode
                            enabled:    !geoController.inProgress
                            onClicked:  geoController.previewMode = checked
                        }

                        beeCopterLabel {
                            Layout.fillWidth:   true
                            text:               qsTr("Verify time offset before committing")
                            opacity:            0.7
                            font.pointSize:     ScreenTools.smallFontPointSize
                        }
                    }
                }
            }

            // Action Button
            beeCopterButton {
                Layout.alignment:       Qt.AlignHCenter
                Layout.preferredWidth:  ScreenTools.defaultFontPixelWidth * 20
                text: {
                    if (geoController.inProgress) {
                        return qsTr("Cancel")
                    } else if (geoController.previewMode) {
                        return qsTr("Preview")
                    } else {
                        return qsTr("Start Tagging")
                    }
                }
                enabled:                (geoController.logFile && geoController.imageDirectory) || geoController.inProgress
                onClicked: {
                    if (geoController.inProgress) {
                        geoController.cancelTagging()
                    } else {
                        geoController.startTagging()
                    }
                }
            }

            // Image List
            Rectangle {
                Layout.fillWidth:       true
                Layout.fillHeight:      true
                Layout.minimumHeight:   ScreenTools.defaultFontPixelHeight * 10
                color:                  beeCopterPal.windowShade
                radius:                 ScreenTools.defaultFontPixelWidth / 2
                visible:                geoController.imageModel.count > 0

                ColumnLayout {
                    anchors.fill:       parent
                    anchors.margins:    _margin
                    spacing:            _margin / 2

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: _margin

                        beeCopterLabel {
                            text:       qsTr("Images (%1)").arg(geoController.imageModel.count)
                            font.bold:  true
                        }

                        Item { Layout.fillWidth: true }

                        // Legend
                        Row {
                            spacing: _margin

                            Row {
                                spacing: _margin / 4
                                Rectangle { width: 10; height: 10; radius: 2; color: beeCopterPal.text; opacity: 0.5 }
                                beeCopterLabel { text: qsTr("Pending"); font.pointSize: ScreenTools.smallFontPointSize }
                            }
                            Row {
                                spacing: _margin / 4
                                Rectangle { width: 10; height: 10; radius: 2; color: beeCopterPal.colorBlue }
                                beeCopterLabel { text: qsTr("Processing"); font.pointSize: ScreenTools.smallFontPointSize }
                            }
                            Row {
                                spacing: _margin / 4
                                Rectangle { width: 10; height: 10; radius: 2; color: beeCopterPal.colorGreen }
                                beeCopterLabel { text: qsTr("Tagged"); font.pointSize: ScreenTools.smallFontPointSize }
                            }
                            Row {
                                spacing: _margin / 4
                                Rectangle { width: 10; height: 10; radius: 2; color: beeCopterPal.colorOrange }
                                beeCopterLabel { text: qsTr("Skipped"); font.pointSize: ScreenTools.smallFontPointSize }
                            }
                            Row {
                                spacing: _margin / 4
                                Rectangle { width: 10; height: 10; radius: 2; color: beeCopterPal.colorRed }
                                beeCopterLabel { text: qsTr("Failed"); font.pointSize: ScreenTools.smallFontPointSize }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth:   true
                        height:             1
                        color:              beeCopterPal.text
                        opacity:            0.2
                    }

                    beeCopterListView {
                        id:                 imageListView
                        Layout.fillWidth:   true
                        Layout.fillHeight:  true
                        model:              geoController.imageModel

                        delegate: Rectangle {
                            width:      imageListView.width
                            height:     ScreenTools.defaultFontPixelHeight * 2
                            color:      index % 2 === 0 ? "transparent" : beeCopterPal.window
                            radius:     ScreenTools.defaultFontPixelWidth / 4

                            RowLayout {
                                anchors.fill:       parent
                                anchors.leftMargin: _margin / 2
                                anchors.rightMargin: _margin / 2
                                spacing:            _margin

                                // Status indicator
                                Rectangle {
                                    Layout.preferredWidth:  ScreenTools.defaultFontPixelHeight * 0.8
                                    Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 0.8
                                    radius:                 ScreenTools.defaultFontPixelWidth / 4
                                    color: {
                                        switch (model.status) {
                                        case 0: return beeCopterPal.text    // Pending
                                        case 1: return beeCopterPal.colorBlue   // Processing
                                        case 2: return beeCopterPal.colorGreen  // Tagged
                                        case 3: return beeCopterPal.colorOrange // Skipped
                                        case 4: return beeCopterPal.colorRed    // Failed
                                        default: return beeCopterPal.text
                                        }
                                    }
                                    opacity: model.status === 0 ? 0.5 : 1.0

                                    // Processing animation
                                    SequentialAnimation on opacity {
                                        running: model.status === 1
                                        loops: Animation.Infinite
                                        NumberAnimation { to: 0.3; duration: 500 }
                                        NumberAnimation { to: 1.0; duration: 500 }
                                    }
                                }

                                // File name
                                beeCopterLabel {
                                    Layout.fillWidth:   true
                                    text:               model.fileName
                                    elide:              Text.ElideMiddle
                                }

                                // Coordinate (if tagged)
                                beeCopterLabel {
                                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 20
                                    text: {
                                        if (model.coordinate && model.coordinate.isValid) {
                                            return model.coordinate.latitude.toFixed(6) + ", " + model.coordinate.longitude.toFixed(6)
                                        }
                                        return ""
                                    }
                                    font.pointSize:     ScreenTools.smallFontPointSize
                                    opacity:            0.7
                                    visible:            model.status === 2
                                }

                                // Status text or error
                                beeCopterLabel {
                                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 12
                                    text:               model.errorMessage ? model.errorMessage : model.statusString
                                    font.pointSize:     ScreenTools.smallFontPointSize
                                    color:              model.status === 4 ? beeCopterPal.colorRed : (model.status === 3 ? beeCopterPal.colorOrange : beeCopterPal.text)
                                    elide:              Text.ElideRight
                                    horizontalAlignment: Text.AlignRight
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
