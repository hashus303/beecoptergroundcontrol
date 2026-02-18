import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls

Rectangle {
    id: _root
    anchors.fill:       parent
    anchors.margins:    ScreenTools.defaultFontPixelWidth
    color:              "white"

    beeCopterPalette { id: beeCopterPal }

    property var enabledPalette:    beeCopterPalette { colorGroupEnabled: true }
    property var disabledPalette:   beeCopterPalette { colorGroupEnabled: false }

    function exportPaletteColors(pal) {
        var objToExport = {}
        for(var clrName in pal) {
            if(pal[clrName].r !== undefined) {
                objToExport[clrName] = pal[clrName].toString();
            }
        }
        return objToExport;
    }

    function fillPalette(pal, colorsObj) {
        for(var clrName in colorsObj) {
            pal[clrName] = colorsObj[clrName];
        }
    }

    function exportTheme() {
        var themeObj = {"light": {}, "dark":{}}
        var oldTheme = beeCopterPal.globalTheme;

        beeCopterPal.globalTheme = beeCopterPalette.Light
        beeCopterPal.colorGroupEnabled = true
        themeObj.light["enabled"] = exportPaletteColors(beeCopterPal);
        beeCopterPal.colorGroupEnabled = false
        themeObj.light["disabled"] = exportPaletteColors(beeCopterPal);
        beeCopterPal.globalTheme = beeCopterPalette.Dark
        beeCopterPal.colorGroupEnabled = true
        themeObj.dark["enabled"] = exportPaletteColors(beeCopterPal);
        beeCopterPal.colorGroupEnabled = false
        themeObj.dark["disabled"] = exportPaletteColors(beeCopterPal);

        beeCopterPal.globalTheme = oldTheme;
        beeCopterPal.colorGroupEnabled = true;

        var jsonString = JSON.stringify(themeObj, null, 4);

        themeImportExportEdit.text = jsonString
    }

    function exportThemeCPP() {
        var palToExport = ""
        for(var i = 0; i < beeCopterPal.colors.length; i++) {
            var cs = beeCopterPal.colors[i]
            var csc = cs + 'Colors'
            palToExport += 'DECLARE_beeCopter_COLOR(' + cs + ', \"' + beeCopterPal[csc][1] + '\", \"' + beeCopterPal[csc][0] + '\", \"' + beeCopterPal[csc][3] + '\", \"' + beeCopterPal[csc][2] + '\")\n'
        }
        themeImportExportEdit.text = palToExport
    }

    function exportThemePlugin() {
        var palToExport = ""
        for(var i = 0; i < beeCopterPal.colors.length; i++) {
            var cs = beeCopterPal.colors[i]
            var csc = cs + 'Colors'
            if(i > 0) {
                palToExport += '\nelse '
            }
            palToExport +=
            'if (colorName == QStringLiteral(\"' + cs + '\")) {\n' +
            '    colorInfo[beeCopterPalette::Dark][beeCopterPalette::ColorGroupEnabled]   = QColor(\"' + beeCopterPal[csc][2] + '\");\n' +
            '    colorInfo[beeCopterPalette::Dark][beeCopterPalette::ColorGroupDisabled]  = QColor(\"' + beeCopterPal[csc][3] + '\");\n' +
            '    colorInfo[beeCopterPalette::Light][beeCopterPalette::ColorGroupEnabled]  = QColor(\"' + beeCopterPal[csc][0] + '\");\n' +
            '    colorInfo[beeCopterPalette::Light][beeCopterPalette::ColorGroupDisabled] = QColor(\"' + beeCopterPal[csc][1] + '\");\n' +
            '}'
        }
        themeImportExportEdit.text = palToExport
    }

    function importTheme(jsonStr) {
        var jsonObj = JSON.parse(jsonStr)
        var themeObj = {"light": {}, "dark":{}}
        var oldTheme = beeCopterPal.globalTheme;

        beeCopterPal.globalTheme = beeCopterPalette.Light
        beeCopterPal.colorGroupEnabled = true
        fillPalette(beeCopterPal, jsonObj.light.enabled)
        beeCopterPal.colorGroupEnabled = false
        fillPalette(beeCopterPal, jsonObj.light.disabled);
        beeCopterPal.globalTheme = beeCopterPalette.Dark
        beeCopterPal.colorGroupEnabled = true
        fillPalette(beeCopterPal, jsonObj.dark.enabled);
        beeCopterPal.colorGroupEnabled = false
        fillPalette(beeCopterPal, jsonObj.dark.disabled);

        beeCopterPal.globalTheme = oldTheme;
        beeCopterPal.colorGroupEnabled = true;

        paletteImportExportPopup.close()
    }

    //-------------------------------------------------------------------------
    //-- Export/Import
    Popup {
        id:             paletteImportExportPopup
        width:          impCol.width  + (ScreenTools.defaultFontPixelWidth  * 4)
        height:         impCol.height + (ScreenTools.defaultFontPixelHeight * 2)
        modal:          true
        focus:          true
        parent:         Overlay.overlay
        closePolicy:    Popup.CloseOnEscape | Popup.CloseOnPressOutside
        x:              Math.round((mainWindow.width  - width)  * 0.5)
        y:              Math.round((mainWindow.height - height) * 0.5)
        onVisibleChanged: {
            if(visible) {
                exportTheme()
                _jsonButton.checked = true
            }
        }
        background: Rectangle {
            anchors.fill:   parent
            color:          beeCopterPal.window
            radius:         ScreenTools.defaultFontPixelHeight * 0.5
            border.width:   1
            border.color:   beeCopterPal.text
        }
        Column {
            id:             impCol
            spacing:        ScreenTools.defaultFontPixelHeight
            anchors.centerIn: parent
            Row {
                id:         exportFormats
                spacing:    ScreenTools.defaultFontPixelWidth  * 2
                anchors.horizontalCenter: parent.horizontalCenter
                beeCopterRadioButton {
                    id:     _jsonButton
                    text:   "Json"
                    onClicked: exportTheme()
                }
                beeCopterRadioButton {
                    text: "beeCopter"
                    onClicked: exportThemeCPP()
                }
                beeCopterRadioButton {
                    text: "Custom Plugin"
                    onClicked: exportThemePlugin()
                }
            }
            Rectangle {
                width:              flick.width  + (ScreenTools.defaultFontPixelWidth  * 2)
                height:             flick.height + (ScreenTools.defaultFontPixelHeight * 2)
                color:              "white"
                anchors.margins:    10
                Flickable {
                    id:             flick
                    clip:           true
                    width:          mainWindow.width  * 0.666
                    height:         mainWindow.height * 0.666
                    contentWidth:   themeImportExportEdit.paintedWidth
                    contentHeight:  themeImportExportEdit.paintedHeight
                    anchors.centerIn: parent
                    flickableDirection: Flickable.VerticalFlick

                    function ensureVisible(r)
                    {
                       if (contentX >= r.x)
                           contentX = r.x;
                       else if (contentX+width <= r.x+r.width)
                           contentX = r.x+r.width-width;
                       if (contentY >= r.y)
                           contentY = r.y;
                       else if (contentY+height <= r.y+r.height)
                           contentY = r.y+r.height-height;
                    }

                    TextEdit {
                       id:          themeImportExportEdit
                       width:       flick.width
                       focus:       true
                       font.family: ScreenTools.fixedFontFamily
                       font.pointSize: ScreenTools.defaultFontPointSize
                       onCursorRectangleChanged: flick.ensureVisible(cursorRectangle)
                    }
                }
            }
            Row {
                spacing:    ScreenTools.defaultFontPixelWidth  * 2
                anchors.horizontalCenter: parent.horizontalCenter
                beeCopterButton {
                    id:         importButton
                    text:       "Import (Json Only)"
                    enabled:    themeImportExportEdit.text[0] === "{" && _jsonButton.checked
                    onClicked: {
                        importTheme(themeImportExportEdit.text);
                    }
                }
                beeCopterButton {
                    text:       "Close"
                    onClicked: {
                        paletteImportExportPopup.close()
                    }
                }
            }
        }
    }

    //-------------------------------------------------------------------------
    //-- Header
    Rectangle {
        id:         _header
        width:      parent.width
        height:     themeChoice.height * 2
        color:      beeCopterPal.window
        anchors.top: parent.top
        Row {
            id:         themeChoice
            spacing:    20
            anchors.centerIn: parent
            beeCopterLabel {
                text:   qsTr("Window Color")
                anchors.verticalCenter: parent.verticalCenter
            }
            beeCopterButton {
                text:   qsTr("Import/Export")
                anchors.verticalCenter: parent.verticalCenter
                onClicked: paletteImportExportPopup.open()
            }
            Row {
                spacing:         20
                anchors.verticalCenter: parent.verticalCenter
                beeCopterRadioButton {
                    text:       qsTr("Light")
                    checked:    beeCopterPal.globalTheme === beeCopterPalette.Light
                    onClicked: {
                        beeCopterPal.globalTheme = beeCopterPalette.Light
                    }
                }
                beeCopterRadioButton {
                    text:       qsTr("Dark")
                    checked:    beeCopterPal.globalTheme === beeCopterPalette.Dark
                    onClicked: {
                        beeCopterPal.globalTheme = beeCopterPalette.Dark
                    }
                }
            }
        }
    }
    //-------------------------------------------------------------------------
    //-- Main Contents
    beeCopterFlickable {
        anchors.top:            _header.bottom
        anchors.bottom:         parent.bottom
        width:                  parent.width
        contentWidth:           _rootCol.width
        contentHeight:          _rootCol.height
        clip:                   true
        Column {
            id:         _rootCol
            Row {
                spacing: 30
                // Edit theme GroupBox
                GroupBox {
                    title: "Preview and edit theme"
                Column {
                    id: editRoot
                    spacing: 5
                    property size cellSize: "90x25"

                    // Header row
                    Row {
                        Text {
                            width: editRoot.cellSize.width * 2
                            height: editRoot.cellSize.height
                            text: ""
                        }
                        Text {
                            width: editRoot.cellSize.width; height: editRoot.cellSize.height
                            color: "black"
                            horizontalAlignment: Text.AlignLeft
                            text: qsTr("Enabled")
                        }
                        Text {
                            width: editRoot.cellSize.width; height: editRoot.cellSize.height
                            color: "black"
                            horizontalAlignment: Text.AlignHCenter
                            text: qsTr("Value")
                        }
                        Text {
                            width: editRoot.cellSize.width; height: editRoot.cellSize.height
                            color: "black"
                            horizontalAlignment: Text.AlignHCenter
                            text: qsTr("Disabled")
                        }
                        Text {
                            width: editRoot.cellSize.width; height: editRoot.cellSize.height
                            color: "black"
                            horizontalAlignment: Text.AlignHCenter
                            text: qsTr("Value")
                        }
                    }

                    // Populate the model with all color names in the global palette
                    Component.onCompleted: {
                        for(var colorNameStr in enabledPalette) {
                            if(enabledPalette[colorNameStr].r !== undefined) {
                                paletteColorList.append({ colorName: colorNameStr });
                            }
                        }
                    }

                    ListModel {
                        id: paletteColorList
                    }

                    // Reproduce all the models
                    Repeater {
                        model: paletteColorList
                        delegate: Row {
                            spacing: 5
                            Text {
                                width: editRoot.cellSize.width * 2
                                height: editRoot.cellSize.height
                                horizontalAlignment: Text.AlignRight
                                verticalAlignment: Text.AlignVCenter
                                color: "black"
                                text: colorName
                            }
                            ClickableColor {
                                id: enabledColorPicker
                                color: enabledPalette[colorName]
                                onColorSelected: enabledPalette[colorName] = color
                            }
                            TextField {
                                id: enabledTextField
                                width: editRoot.cellSize.width; height: editRoot.cellSize.height
                                inputMask: "\\#>HHHHHHhh;"
                                horizontalAlignment: Text.AlignLeft
                                text: enabledPalette[colorName]
                                onEditingFinished: enabledPalette[colorName] = text
                            }
                            ClickableColor {
                                id: disabledColorPicker
                                color: disabledPalette[colorName]
                                onColorSelected: disabledPalette[colorName] = color
                            }
                            TextField {
                                width: editRoot.cellSize.width; height: editRoot.cellSize.height
                                inputMask: enabledTextField.inputMask
                                horizontalAlignment: Text.AlignLeft
                                text: disabledPalette[colorName]
                                onEditingFinished: disabledPalette[colorName] = text
                            }
                        }
                    }
                } // Column
                } // GroupBox { title: "Preview and edit theme"

                // beeCopter controls preview
                GroupBox { title: "Controls preview"
                Column {
                    id: ctlPrevColumn
                    property real _colWidth: ScreenTools.defaultFontPointSize * 18
                    property real _height: _colWidth*0.15
                    property color _bkColor: beeCopterPal.window
                    spacing: 10
                    width: previewGrid.width
                    Grid {
                        id: previewGrid
                        columns: 3
                        spacing: 10

                        // Header row
                        Text {
                            width: ctlPrevColumn._colWidth
                            height: ctlPrevColumn._height
                            color: "black"
                            horizontalAlignment: Text.AlignHCenter
                            text: qsTr("beeCopter name")
                        }
                        Text {
                            width: ctlPrevColumn._colWidth
                            height: ctlPrevColumn._height
                            color: "black"
                            horizontalAlignment: Text.AlignHCenter
                            text: qsTr("Enabled")
                        }
                        Text {
                            width: ctlPrevColumn._colWidth
                            height: ctlPrevColumn._height
                            color: "black"
                            horizontalAlignment: Text.AlignHCenter
                            text: qsTr("Disabled")
                        }

                        // beeCopterLabel
                        Loader {
                            sourceComponent: ctlRowHeader
                            property string text: "beeCopterLabel"
                        }
                        Rectangle {
                            width: ctlPrevColumn._colWidth
                            height: ctlPrevColumn._height
                            color: ctlPrevColumn._bkColor
                            beeCopterLabel {
                                anchors.fill: parent
                                anchors.margins: 5
                                text: qsTr("Label")
                            }
                        }
                        Rectangle {
                            width: ctlPrevColumn._colWidth
                            height: ctlPrevColumn._height
                            color: ctlPrevColumn._bkColor
                            beeCopterLabel {
                                anchors.fill: parent
                                anchors.margins: 5
                                text: qsTr("Label")
                                enabled: false
                            }
                        }

                        // beeCopterButton
                        Loader {
                            sourceComponent: ctlRowHeader
                            property string text: "beeCopterButton"
                        }
                        beeCopterButton {
                            width: ctlPrevColumn._colWidth
                            height: ctlPrevColumn._height
                            text: qsTr("Button")
                        }
                        beeCopterButton {
                            width: ctlPrevColumn._colWidth
                            height: ctlPrevColumn._height
                            text: qsTr("Button")
                            enabled: false
                        }

                        // beeCopterButton - primary
                        Loader {
                            sourceComponent: ctlRowHeader
                            property string text: "beeCopterButton(primary)"
                        }
                        beeCopterButton {
                            width: ctlPrevColumn._colWidth
                            height: ctlPrevColumn._height
                            primary: true
                            text: qsTr("Button")
                        }
                        beeCopterButton {
                            width:  ctlPrevColumn._colWidth
                            height: ctlPrevColumn._height
                            text:   qsTr("Button")
                            primary: true
                            enabled: false
                        }

                        // ToolStripHoverButton
                        Loader {
                            sourceComponent: ctlRowHeader
                            property string text: "ToolStripHoverButton"
                        }
                        ToolStripHoverButton {
                            width:  ctlPrevColumn._colWidth
                            height: ctlPrevColumn._height * 2
                            text:   qsTr("Hover Button")
                            radius: ScreenTools.defaultFontPointSize
                            imageSource: "/qmlimages/Gears.svg"
                        }
                        ToolStripHoverButton {
                            width:  ctlPrevColumn._colWidth
                            height: ctlPrevColumn._height * 2
                            text:   qsTr("Hover Button")
                            radius: ScreenTools.defaultFontPointSize
                            imageSource: "/qmlimages/Gears.svg"
                            enabled: false
                        }

                        // beeCopterButton - menu
                        Loader {
                            sourceComponent: ctlRowHeader
                            property string text: "beeCopterButton(menu)"
                        }
                        Menu {
                            id: buttonMenu
                            beeCopterMenuItem {
                                text: qsTr("Item 1")
                            }
                            beeCopterMenuItem {
                                text: qsTr("Item 2")
                            }
                            beeCopterMenuItem {
                                text: qsTr("Item 3")
                            }
                        }
                        beeCopterButton {
                            width: ctlPrevColumn._colWidth
                            height: ctlPrevColumn._height
                            text: qsTr("Button")
                            onClicked: buttonMenu.popup()
                        }
                        beeCopterButton {
                            width: ctlPrevColumn._colWidth
                            height: ctlPrevColumn._height
                            text: qsTr("Button")
                            enabled: false
                            onClicked: buttonMenu.popup()
                        }

                        // beeCopterRadioButton
                        Loader {
                            sourceComponent: ctlRowHeader
                            property string text: "beeCopterRadioButton"
                        }
                        Rectangle {
                            width: ctlPrevColumn._colWidth
                            height: ctlPrevColumn._height
                            color: ctlPrevColumn._bkColor
                            beeCopterRadioButton {
                                anchors.fill: parent
                                anchors.margins: 5
                                text: qsTr("Radio")
                            }
                        }
                        Rectangle {
                            width: ctlPrevColumn._colWidth
                            height: ctlPrevColumn._height
                            color: ctlPrevColumn._bkColor
                            beeCopterRadioButton {
                                anchors.fill: parent
                                anchors.margins: 5
                                text: qsTr("Radio")
                                enabled: false
                            }
                        }

                        // beeCopterCheckBox
                        Loader {
                            sourceComponent: ctlRowHeader
                            property string text: "beeCopterCheckBox"
                        }
                        Rectangle {
                            width: ctlPrevColumn._colWidth
                            height: ctlPrevColumn._height
                            color: ctlPrevColumn._bkColor
                            beeCopterCheckBox {
                                anchors.fill: parent
                                anchors.margins: 5
                                text: qsTr("Check Box")
                            }
                        }
                        Rectangle {
                            width: ctlPrevColumn._colWidth
                            height: ctlPrevColumn._height
                            color: ctlPrevColumn._bkColor
                            beeCopterCheckBox {
                                anchors.fill: parent
                                anchors.margins: 5
                                text: qsTr("Check Box")
                                enabled: false
                            }
                        }

                        // beeCopterCheckBoxSlider
                        Loader {
                            sourceComponent: ctlRowHeader
                            property string text: "beeCopterCheckBoxSlider"
                        }
                        Rectangle {
                            width: ctlPrevColumn._colWidth
                            height: ctlPrevColumn._height
                            color: ctlPrevColumn._bkColor
                            beeCopterCheckBoxSlider {
                                anchors.fill: parent
                                anchors.margins: 5
                                text: qsTr("Check Box Slider")
                            }
                        }
                        Rectangle {
                            width: ctlPrevColumn._colWidth
                            height: ctlPrevColumn._height
                            color: ctlPrevColumn._bkColor
                            beeCopterCheckBoxSlider {
                                anchors.fill: parent
                                anchors.margins: 5
                                text: qsTr("Check Box Slider")
                                enabled: false
                            }
                        }

                        // beeCopterTextField
                        Loader {
                            sourceComponent: ctlRowHeader
                            property string text: "beeCopterTextField"
                        }
                        beeCopterTextField {
                            width: ctlPrevColumn._colWidth
                            height: ctlPrevColumn._height
                            text: "beeCopterTextField"
                        }
                        beeCopterTextField {
                            width: ctlPrevColumn._colWidth
                            height: ctlPrevColumn._height
                            text: "beeCopterTextField"
                            enabled: false
                        }

                        // beeCopterComboBox
                        Loader {
                            sourceComponent: ctlRowHeader
                            property string text: "beeCopterComboBox"
                        }
                        beeCopterComboBox {
                            width: ctlPrevColumn._colWidth
                            height: ctlPrevColumn._height
                            model: [ qsTr("Item 1"), qsTr("Item 2"), qsTr("Item 3") ]
                        }
                        beeCopterComboBox {
                            width: ctlPrevColumn._colWidth
                            height: ctlPrevColumn._height
                            model: [ qsTr("Item 1"), qsTr("Item 2"), qsTr("Item 3") ]
                            enabled: false
                        }

                        // SubMenuButton
                        Loader {
                            sourceComponent: ctlRowHeader
                            property string text: "SubMenuButton"
                        }
                        SubMenuButton {
                            width: ctlPrevColumn._colWidth
                            height: ctlPrevColumn._colWidth/3
                            text: qsTr("SUB MENU")
                        }
                        SubMenuButton {
                            width: ctlPrevColumn._colWidth
                            height: ctlPrevColumn._colWidth/3
                            text: qsTr("SUB MENU")
                            enabled: false
                        }
                    }
                    Rectangle {
                        width:  previewGrid.width
                        height: 60
                        radius: 3
                        color:  beeCopterPal.alertBackground
                        border.color: beeCopterPal.alertBorder
                        border.width: 1
                        anchors.horizontalCenter: parent.horizontalCenter
                        Label {
                            text: "Alert Message"
                            color: beeCopterPal.alertText
                            anchors.centerIn: parent
                        }
                    }
                } // Column
                } // GroupBox { title: "Controls preview"
            }

            Item{
                height: 10;
                width:  1;
            }

            Row {
                spacing: 10
                anchors.horizontalCenter: parent.horizontalCenter
                Loader {
                    property color backgroundColor: beeCopterPal.window
                    sourceComponent: arbBox
                }
                Loader {
                    property color backgroundColor: beeCopterPal.windowShade
                    sourceComponent: arbBox
                }
                Loader {
                    property color backgroundColor: beeCopterPal.windowShadeDark
                    sourceComponent: arbBox
                }
            }

            Item{
                height: 20;
                width:  1;
            }

            // SettingsGroupLayout Test
            GroupBox {
                title: "SettingsGroupLayout Test"
                anchors.horizontalCenter: parent.horizontalCenter

                background: Rectangle {
                    color: beeCopterPal.window
                    border.color: beeCopterPal.text
                    border.width: 1
                }

                Column {
                    spacing: ScreenTools.defaultFontPixelHeight

                    // Controls for testing properties
                    Row {
                        spacing: ScreenTools.defaultFontPixelWidth * 2

                        beeCopterCheckBox {
                            id: showBorderCheck
                            text: "showBorder"
                            checked: true
                        }

                        beeCopterCheckBox {
                            id: showDividersCheck
                            text: "showDividers"
                            checked: true
                        }

                        beeCopterCheckBox {
                            id: showHeadingCheck
                            text: "Show Heading"
                            checked: true
                        }

                        beeCopterCheckBox {
                            id: showDescriptionCheck
                            text: "Show Description"
                            checked: true
                        }
                    }

                    Row {
                        spacing: ScreenTools.defaultFontPixelWidth * 2

                        beeCopterLabel { text: "Visibility toggles:"; font.bold: true }

                        beeCopterCheckBox {
                            id: item1Visible
                            text: "Item 1"
                            checked: true
                        }

                        beeCopterCheckBox {
                            id: item2Visible
                            text: "Item 2"
                            checked: true
                        }

                        beeCopterCheckBox {
                            id: item3Visible
                            text: "Item 3"
                            checked: true
                        }

                        beeCopterCheckBox {
                            id: item4Visible
                            text: "Item 4"
                            checked: true
                        }
                    }

                    Row {
                        spacing: ScreenTools.defaultFontPixelWidth * 2

                        beeCopterLabel { text: "Repeater toggles:"; font.bold: true }

                        beeCopterCheckBox {
                            id: repeaterShowDividers
                            text: "Dividers"
                            checked: true
                        }

                        beeCopterCheckBox {
                            id: repeater1Visible
                            text: "Rep 1"
                            checked: true
                        }

                        beeCopterCheckBox {
                            id: repeater2Visible
                            text: "Rep 2"
                            checked: true
                        }

                        beeCopterCheckBox {
                            id: repeater3Visible
                            text: "Rep 3"
                            checked: true
                        }

                        beeCopterCheckBox {
                            id: repeater4Visible
                            text: "Rep 4"
                            checked: true
                        }

                        beeCopterCheckBox {
                            id: repeater5Visible
                            text: "Rep 5"
                            checked: true
                        }
                    }

                    // Test SettingsGroupLayout with various content
                    SettingsGroupLayout {
                        width: ScreenTools.defaultFontPixelWidth * 60
                        heading: showHeadingCheck.checked ? "Test Settings Group" : ""
                        headingDescription: showDescriptionCheck.checked ? "This is a description of the settings group that explains what these settings are for." : ""
                        showBorder: showBorderCheck.checked
                        showDividers: showDividersCheck.checked

                        RowLayout {
                            Layout.fillWidth: true
                            visible: item1Visible.checked

                            beeCopterLabel {
                                text: "Setting 1:"
                                Layout.fillWidth: true
                            }
                            beeCopterTextField {
                                text: "Value 1"
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 15
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            visible: item2Visible.checked

                            beeCopterLabel {
                                text: "Setting 2:"
                                Layout.fillWidth: true
                            }
                            beeCopterComboBox {
                                model: ["Option 1", "Option 2", "Option 3"]
                                Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 15
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            visible: item3Visible.checked

                            beeCopterCheckBox {
                                text: "Enable feature"
                                Layout.fillWidth: true
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            visible: item4Visible.checked

                            beeCopterLabel {
                                text: "Setting 4:"
                                Layout.fillWidth: true
                            }
                            beeCopterButton {
                                text: "Configure"
                            }
                        }
                    }

                    // Nested SettingsGroupLayout test
                    beeCopterLabel {
                        text: "Nested SettingsGroupLayout:"
                        font.bold: true
                    }

                    SettingsGroupLayout {
                        width: ScreenTools.defaultFontPixelWidth * 60
                        heading: "Outer Group"
                        showBorder: true
                        showDividers: true

                        RowLayout {
                            Layout.fillWidth: true
                            beeCopterLabel { text: "Outer setting"; Layout.fillWidth: true }
                            beeCopterTextField { text: "Value" }
                        }

                        SettingsGroupLayout {
                            Layout.fillWidth: true
                            heading: "Inner Group"
                            headingDescription: "Nested group inside outer group"
                            showBorder: true
                            showDividers: false

                            beeCopterCheckBox {
                                text: "Inner checkbox 1"
                                Layout.fillWidth: true
                            }

                            beeCopterCheckBox {
                                text: "Inner checkbox 2"
                                Layout.fillWidth: true
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            beeCopterLabel { text: "Another outer setting"; Layout.fillWidth: true }
                            beeCopterComboBox { model: ["A", "B", "C"] }
                        }
                    }

                    // Test with Repeater
                    beeCopterLabel {
                        text: "SettingsGroupLayout with Repeater:"
                        font.bold: true
                    }

                    SettingsGroupLayout {
                        width: ScreenTools.defaultFontPixelWidth * 60
                        heading: "Repeater Test"
                        showBorder: true
                        showDividers: repeaterShowDividers.checked

                        Repeater {
                            model: 5
                            delegate: RowLayout {
                                Layout.fillWidth: true
                                visible: {
                                    switch(index) {
                                        case 0: return repeater1Visible.checked
                                        case 1: return repeater2Visible.checked
                                        case 2: return repeater3Visible.checked
                                        case 3: return repeater4Visible.checked
                                        case 4: return repeater5Visible.checked
                                        default: return true
                                    }
                                }
                                beeCopterLabel {
                                    text: "Repeated Item " + (index + 1) + ":"
                                    Layout.fillWidth: true
                                }
                                beeCopterTextField {
                                    text: "Value " + (index + 1)
                                    Layout.preferredWidth: ScreenTools.defaultFontPixelWidth * 15
                                }
                            }
                        }
                    }
                }
            }

        }

    }

    Component {
        id: ctlRowHeader
        Rectangle {
            width:  ctlPrevColumn._colWidth
            height: ctlPrevColumn._height
            color:  "white"
            Text {
                color:  "black"
                text:   parent.parent.text
                anchors.fill: parent
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    Component {
        id: arbBox
        Rectangle {
            width:  arbGrid.width  * 1.5
            height: arbGrid.height * 1.5
            color:  backgroundColor
            border.color: beeCopterPal.text
            border.width: 1
            anchors.horizontalCenter: parent.horizontalCenter
            GridLayout {
                id: arbGrid
                columns: 4
                rowSpacing: 10
                anchors.centerIn: parent
                beeCopterColoredImage {
                    color:                      beeCopterPal.colorGreen
                    width:                      ScreenTools.defaultFontPixelWidth * 2
                    height:                     width
                    sourceSize.height:          width
                    mipmap:                     true
                    fillMode:                   Image.PreserveAspectFit
                    source:                     "/qmlimages/Gears.svg"
                }
                Label { text: "colorGreen"; color: beeCopterPal.colorGreen; }
                beeCopterColoredImage {
                    color:                      beeCopterPal.colorOrange
                    width:                      ScreenTools.defaultFontPixelWidth * 2
                    height:                     width
                    sourceSize.height:          width
                    mipmap:                     true
                    fillMode:                   Image.PreserveAspectFit
                    source:                     "/qmlimages/Gears.svg"
                }
                Label { text: "colorOrange"; color: beeCopterPal.colorOrange; }
                beeCopterColoredImage {
                    color:                      beeCopterPal.colorRed
                    width:                      ScreenTools.defaultFontPixelWidth * 2
                    height:                     width
                    sourceSize.height:          width
                    mipmap:                     true
                    fillMode:                   Image.PreserveAspectFit
                    source:                     "/qmlimages/Gears.svg"
                }
                Label { text: "colorRed"; color: beeCopterPal.colorRed; }
                beeCopterColoredImage {
                    color:                      beeCopterPal.colorGrey
                    width:                      ScreenTools.defaultFontPixelWidth * 2
                    height:                     width
                    sourceSize.height:          width
                    mipmap:                     true
                    fillMode:                   Image.PreserveAspectFit
                    source:                     "/qmlimages/Gears.svg"
                }
                Label { text: "colorGrey"; color: beeCopterPal.colorGrey;  }
                beeCopterColoredImage {
                    color:                      beeCopterPal.colorBlue
                    width:                      ScreenTools.defaultFontPixelWidth * 2
                    height:                     width
                    sourceSize.height:          width
                    mipmap:                     true
                    fillMode:                   Image.PreserveAspectFit
                    source:                     "/qmlimages/Gears.svg"
                }
                Label { text: "colorBlue"; color: beeCopterPal.colorBlue; }
            }
        }
    }
}
