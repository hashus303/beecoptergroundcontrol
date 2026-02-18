import QtQuick
import QtQuick.Dialogs
import QtQuick.Layouts
import QtQuick.Controls

import beeCopter
import beeCopter.Controls
import beeCopter.FactControls

beeCopterPopupDialog {
    id:         root
    title:      qsTr("Telemetry Display")
    buttons:    Dialog.Close

    property var instrumentValueData

    beeCopterPalette { id: beeCopterPal;        colorGroupEnabled: parent.enabled }
    beeCopterPalette { id: beeCopterPalDisable; colorGroupEnabled: false }

    Loader {
        sourceComponent: instrumentValueData.fact ? editorComponent : noFactComponent
    }

    Component {
        id: noFactComponent

        beeCopterLabel {
            text: qsTr("Valuec requires a connected vehicle for setup.")
        }
    }

    Component {
        id: editorComponent

        RowLayout {
            spacing: ScreenTools.defaultFontPixelWidth

            ColumnLayout {
                spacing: ScreenTools.defaultFontPixelHeight / 2

                SettingsGroupLayout {
                    heading: qsTr("Telemetry")

                    LabelledComboBox {
                        id:                     factGroupCombo
                        label:                  qsTr("Group")
                        model:                  instrumentValueData.factGroupNames
                        currentIndex:           instrumentValueData.factGroupNames.indexOf(instrumentValueData.factGroupName)
                        onActivated: (index) => {
                            instrumentValueData.setFact(currentText, "")
                            instrumentValueData.icon = ""
                            instrumentValueData.text = instrumentValueData.fact.shortDescription
                        }
                        Connections {
                            target: instrumentValueData
                            onFactGroupNameChanged: factGroupCombo.currentIndex = factGroupCombo.comboBox.find(instrumentValueData.factGroupName)
                        }
                    }

                    LabelledComboBox {
                        id:                     factNamesCombo
                        label:                  qsTr("Value")
                        model:                  instrumentValueData.factValueNames
                        currentIndex:           instrumentValueData.factValueNames.indexOf(instrumentValueData.factName)
                        onActivated: (index) => {
                            instrumentValueData.setFact(instrumentValueData.factGroupName, currentText)
                            instrumentValueData.icon = ""
                            instrumentValueData.text = instrumentValueData.fact.shortDescription
                        }
                        Connections {
                            target: instrumentValueData
                            onFactNameChanged: factNamesCombo.currentIndex = factNamesCombo.comboBox.find(instrumentValueData.factName)
                        }
                    }
                }

                SettingsGroupLayout {
                    heading: qsTr("Label")

                    ColumnLayout {
                        Layout.fillWidth:   true
                        spacing:            ScreenTools.defaultFontPixelHeight / 2

                        RowLayout {
                            Layout.fillWidth:  true

                            beeCopterRadioButton {
                                id:                     iconRadio
                                text:                   qsTr("Icon")
                                Layout.fillWidth:       true
                                Component.onCompleted:  checked = instrumentValueData.icon != ""
                                onClicked: {
                                    instrumentValueData.text = ""
                                    instrumentValueData.icon = instrumentValueData.factValueGrid.iconNames[0]
                                }
                                ButtonGroup.group:      labelTypeGroup
                                ButtonGroup { id: labelTypeGroup }
                            }

                            RowLayout {
                                id:         iconOptionInputs
                                Rectangle {
                                    width:      height
                                    height:     changeIconBtn.height
                                    color:      beeCopterPal.windowShade
                                    opacity:    iconRadio.checked ? 1 : .3

                                    beeCopterColoredImage {
                                        id:                 valueIcon
                                        anchors.centerIn:   parent
                                        height:             ScreenTools.defaultFontPixelHeight
                                        width:              height
                                        source:             "/InstrumentValueIcons/" + (instrumentValueData.icon ? instrumentValueData.icon : instrumentValueData.factValueGrid.iconNames[0])
                                        sourceSize.height:  height
                                        fillMode:           Image.PreserveAspectFit
                                        mipmap:             true
                                        smooth:             true
                                        color:              valueIcon.status === Image.Error ? "red" : beeCopterPal.text
                                    }
                                }
                                beeCopterButton {
                                    id:         changeIconBtn
                                    text:       qsTr("Change")
                                    enabled:    iconRadio.checked
                                    onClicked: {
                                        var updateFunction = function(icon){ instrumentValueData.icon = icon }
                                        iconPickerDialog.createObject(mainWindow, { iconNames: instrumentValueData.factValueGrid.iconNames, icon: instrumentValueData.icon, updateIconFunction: updateFunction }).open()
                                    }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true

                            beeCopterRadioButton {
                                id:                     textRadio
                                text:                   qsTr("Text")
                                Layout.fillWidth:       true
                                ButtonGroup.group:      labelTypeGroup
                                Component.onCompleted:  checked = instrumentValueData.icon == ""
                                onClicked: {
                                    instrumentValueData.icon = ""
                                    instrumentValueData.text = instrumentValueData.fact ? instrumentValueData.fact.shortDescription : qsTr("Label")
                                }
                            }

                            beeCopterTextField {
                                enabled:                textRadio.checked
                                Layout.minimumWidth:    iconOptionInputs.width
                                text:                   textRadio.checked
                                                            ? instrumentValueData.text
                                                            : instrumentValueData.fact ? instrumentValueData.fact.shortDescription : qsTr("Label")
                                onEditingFinished:      instrumentValueData.text = text
                            }
                        }
                    }

                    LabelledComboBox {
                        label:          qsTr("Size")
                        model:          instrumentValueData.factValueGrid.fontSizeNames
                        currentIndex:   instrumentValueData.factValueGrid.fontSize
                        onActivated:    (index) => { instrumentValueData.factValueGrid.fontSize = index }
                    }

                    beeCopterCheckBoxSlider {
                        Layout.fillWidth: true
                        text:       qsTr("Show Units")
                        checked:    instrumentValueData.showUnits
                        onClicked:  instrumentValueData.showUnits = checked
                    }
                }
            }

            SettingsGroupLayout {
                Layout.alignment:   Qt.AlignTop
                heading:            qsTr("Value range")

                ColumnLayout {
                    Layout.fillWidth: true

                    RowLayout {
                        Layout.fillWidth:   true
                        spacing:            ScreenTools.defaultFontPixelWidth * 2

                        beeCopterLabel {
                            Layout.fillWidth:       true
                            text:                   qsTr("Type")
                        }

                        beeCopterComboBox {
                            id:                 rangeTypeCombo
                            model:              instrumentValueData.rangeTypeNames
                            currentIndex:       instrumentValueData.rangeType
                            sizeToContents:     true
                            onActivated: (index) => { instrumentValueData.rangeType = index }
                        }
                    }

                    Loader {
                        id:                     rangeLoader
                        visible:                sourceComponent
                        Layout.columnSpan:      2
                        Layout.alignment:       Qt.AlignHCenter
                        Layout.margins:         ScreenTools.defaultFontPixelWidth
                        Layout.preferredWidth:  item ? item.width : 0
                        Layout.preferredHeight: item ? item.height : 0

                        property var instrumentValueData: root.instrumentValueData

                        function updateSourceComponent() {
                            switch (instrumentValueData.rangeType) {
                            case InstrumentValueData.NoRangeInfo:
                                sourceComponent = undefined
                                break
                            case InstrumentValueData.ColorRange:
                                sourceComponent = colorRangeDialog
                                break
                            case InstrumentValueData.OpacityRange:
                                sourceComponent = opacityRangeDialog
                                break
                            case InstrumentValueData.IconSelectRange:
                                sourceComponent = iconRangeDialog
                                break
                            }
                        }

                        Component.onCompleted: {
                            updateSourceComponent()
                            if (sourceComponent) {
                                height = item.childrenRect.height
                                width = item.childrenRect.width
                            }
                        }

                        Connections {
                            target:             instrumentValueData
                            onRangeTypeChanged: rangeLoader.updateSourceComponent()
                        }
                    }
                }
            }
        }
    }

    Component {
        id: colorRangeDialog

        Item {
            width:  childrenRect.width
            height: childrenRect.height

            function updateRangeValue(index, text) {
                var newValues = instrumentValueData.rangeValues
                newValues[index] = parseFloat(text)
                instrumentValueData.rangeValues = newValues
            }

            function updateColorValue(index, color) {
                var newColors = instrumentValueData.rangeColors
                newColors[index] = color
                instrumentValueData.rangeColors = newColors
            }

            ColorDialog {
                id:             colorPickerDialog
                modality:       Qt.ApplicationModal
                selectedColor:  instrumentValueData.rangeColors.length ? instrumentValueData.rangeColors[colorIndex] : "white"
                onAccepted:     updateColorValue(colorIndex, selectedColor)

                property int colorIndex: 0
            }

            Column {
                id:         mainColumn
                spacing:    ScreenTools.defaultFontPixelHeight / 2

                beeCopterLabel {
                    width:      rowLayout.width
                    text:       qsTr("Specify the color you want to apply based on value ranges. The color will be applied to the icon if available, otherwise to the value itself.")
                    wrapMode:   Text.WordWrap
                }

                Row {
                    id:         rowLayout
                    spacing:    _margins

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing:                _margins

                        Repeater {
                            model: instrumentValueData.rangeValues.length

                            beeCopterColoredImage {
                                width:      ScreenTools.implicitTextFieldHeight
                                height:     width
                                fillMode:   Image.PreserveAspectFit
                                color:      beeCopter.globalPalette.text
                                source:     "/res/TrashDelete.svg"

                                beeCopterMouseArea {
                                    fillItem:   parent
                                    onClicked:  instrumentValueData.removeRangeValue(index)
                                }
                            }
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing:                _margins

                        Repeater {
                            model: instrumentValueData.rangeValues.length

                            beeCopterTextField {
                                text:               instrumentValueData.rangeValues[index]
                                onEditingFinished:  updateRangeValue(index, text)
                            }
                        }
                    }

                    Column {
                        spacing: _margins
                        Repeater {
                            model: instrumentValueData.rangeColors

                            beeCopterCheckBox {
                                height:     ScreenTools.implicitTextFieldHeight
                                checked:    instrumentValueData.isValidColor(instrumentValueData.rangeColors[index])
                                onClicked:  updateColorValue(index, checked ? "green" : instrumentValueData.invalidColor())
                            }
                        }
                    }

                    Column {
                        spacing: _margins
                        Repeater {
                            model: instrumentValueData.rangeColors

                            Rectangle {
                                width:          ScreenTools.implicitTextFieldHeight
                                height:         width
                                border.color:   beeCopterPal.text
                                color:          instrumentValueData.isValidColor(modelData) ? modelData : beeCopterPal.text

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        colorPickerDialog.colorIndex = index
                                        colorPickerDialog.open()
                                    }
                                }
                            }
                        }
                    }
                }

                beeCopterButton {
                    text:       qsTr("Add Row")
                    onClicked:  instrumentValueData.addRangeValue()
                }
            }
        }
    }

    Component {
        id: iconRangeDialog

        Item {
            width:  childrenRect.width
            height: childrenRect.height

            function updateRangeValue(index, text) {
                var newValues = instrumentValueData.rangeValues
                newValues[index] = parseFloat(text)
                instrumentValueData.rangeValues = newValues
            }

            function updateIconValue(index, icon) {
                var newIcons = instrumentValueData.rangeIcons
                newIcons[index] = icon
                instrumentValueData.rangeIcons = newIcons
            }

            Column {
                id:         mainColumn
                spacing:    ScreenTools.defaultFontPixelHeight / 2

                beeCopterLabel {
                    width:      rowLayout.width
                    text:       qsTr("Specify the icon you want to display based on value ranges.")
                    wrapMode:   Text.WordWrap
                }

                Row {
                    id:         rowLayout
                    spacing:    _margins

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing:                _margins

                        Repeater {
                            model: instrumentValueData.rangeValues.length

                            beeCopterColoredImage {
                                width:      ScreenTools.implicitTextFieldHeight
                                height:     width
                                fillMode:   Image.PreserveAspectFit
                                color:      beeCopter.globalPalette.text
                                source:     "/res/TrashDelete.svg"

                                beeCopterMouseArea {
                                    fillItem:   parent
                                    onClicked:  instrumentValueData.removeRangeValue(index)
                                }
                            }
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing:                _margins

                        Repeater {
                            model: instrumentValueData.rangeValues.length

                            beeCopterTextField {
                                text:               instrumentValueData.rangeValues[index]
                                onEditingFinished:  updateRangeValue(index, text)
                            }
                        }
                    }

                    Column {
                        spacing: _margins

                        Repeater {
                            model: instrumentValueData.rangeIcons

                            beeCopterColoredImage {
                                height:             ScreenTools.implicitTextFieldHeight
                                width:              height
                                source:             "/InstrumentValueIcons/" + modelData
                                sourceSize.height:  height
                                fillMode:           Image.PreserveAspectFit
                                mipmap:             true
                                smooth:             true
                                color:              beeCopterPal.text

                                MouseArea {
                                    anchors.fill:   parent
                                    onClicked: {
                                        var updateFunction = function(icon){ updateIconValue(index, icon) }
                                        iconPickerDialog.createObject(mainWindow, { iconNames: instrumentValueData.factValueGrid.iconNames, icon: modelData, updateIconFunction: updateFunction }).open()
                                    }
                                }
                            }
                        }
                    }
                }

                beeCopterButton {
                    text:       qsTr("Add Row")
                    onClicked:  instrumentValueData.addRangeValue()
                }
            }
        }
    }

    Component {
        id: opacityRangeDialog

        Item {
            width:  childrenRect.width
            height: childrenRect.height

            function updateRangeValue(index, text) {
                var newValues = instrumentValueData.rangeValues
                newValues[index] = parseFloat(text)
                instrumentValueData.rangeValues = newValues
            }

            function updateOpacityValue(index, opacity) {
                var newOpacities = instrumentValueData.rangeOpacities
                newOpacities[index] = opacity
                instrumentValueData.rangeOpacities = newOpacities
            }

            Column {
                id:         mainColumn
                spacing:    ScreenTools.defaultFontPixelHeight / 2

                beeCopterLabel {
                    width:      rowLayout.width
                    text:       qsTr("Specify the icon opacity you want based on value ranges.")
                    wrapMode:   Text.WordWrap
                }

                Row {
                    id:         rowLayout
                    spacing:    _margins

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing:                _margins

                        Repeater {
                            model: instrumentValueData.rangeValues.length

                            beeCopterColoredImage {
                                width:      ScreenTools.implicitTextFieldHeight
                                height:     width
                                fillMode:   Image.PreserveAspectFit
                                color:      beeCopter.globalPalette.text
                                source:     "/res/TrashDelete.svg"

                                beeCopterMouseArea {
                                    fillItem:   parent
                                    onClicked:  instrumentValueData.removeRangeValue(index)
                                }
                            }
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing:                _margins

                        Repeater {
                            model: instrumentValueData.rangeValues

                            beeCopterTextField {
                                text:               modelData
                                onEditingFinished:  updateRangeValue(index, text)
                            }
                        }
                    }

                    Column {
                        spacing: _margins

                        Repeater {
                            model: instrumentValueData.rangeOpacities

                            beeCopterTextField {
                                text:               modelData
                                onEditingFinished:  updateOpacityValue(index, text)
                            }
                        }
                    }
                }

                beeCopterButton {
                    text:       qsTr("Add Row")
                    onClicked:  instrumentValueData.addRangeValue()
                }
            }
        }
    }

    Component {
        id: iconPickerDialog

        beeCopterPopupDialog {
            title:      qsTr("Select Icon")
            buttons:    Dialog.Close

            property var     iconNames
            property string  icon
            property var     updateIconFunction

            GridLayout {
                columns:        10
                columnSpacing:  0
                rowSpacing:     0

                Repeater {
                    model: iconNames

                    Rectangle {
                        height: ScreenTools.minTouchPixels
                        width:  height
                        color:  currentSelection ? beeCopterPal.text  : beeCopterPal.window

                        property bool currentSelection: icon == modelData

                        beeCopterColoredImage {
                            anchors.centerIn:   parent
                            height:             parent.height * 0.75
                            width:              height
                            source:             "/InstrumentValueIcons/" + modelData
                            sourceSize.height:  height
                            fillMode:           Image.PreserveAspectFit
                            mipmap:             true
                            smooth:             true
                            color:              currentSelection ? beeCopterPal.window : beeCopterPal.text

                            MouseArea {
                                anchors.fill:   parent
                                onClicked:  {
                                    icon = modelData
                                    updateIconFunction(modelData)
                                    close()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
