import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls
import beeCopter.AppSettings

Rectangle {
    id:     settingsView
    color:  beeCopterPal.window
    z:      beeCopter.zOrderTopMost

    readonly property real _defaultTextHeight:  ScreenTools.defaultFontPixelHeight
    readonly property real _defaultTextWidth:   ScreenTools.defaultFontPixelWidth
    readonly property real _horizontalMargin:   _defaultTextWidth / 2
    readonly property real _verticalMargin:     _defaultTextHeight / 2

    property bool _first: true

    property bool _commingFromRIDSettings:  false

    function showSettingsPage(settingsPage) {
        for (var i=0; i<buttonRepeater.count; i++) {
            var loader = buttonRepeater.itemAt(i)
            if (loader && loader.item && loader.item.text === settingsPage) {
                loader.item.clicked()
                break
            }
        }
    }

    // This need to block click event leakage to underlying map.
    DeadMouseArea {
        anchors.fill: parent
    }

    beeCopterPalette { id: beeCopterPal }

    Component.onCompleted: {
        //-- Default Settings
        if (globals.commingFromRIDIndicator) {
            rightPanel.source = "qrc:/qml/beeCopter/AppSettings/RemoteIDSettings.qml"
            globals.commingFromRIDIndicator = false
        } else {
            rightPanel.source =  "qrc:/qml/beeCopter/AppSettings/GeneralSettings.qml"
        }
    }

    SettingsPagesModel { id: settingsPagesModel }

    ButtonGroup { id: buttonGroup }

    beeCopterFlickable {
        id:                 buttonList
        width:              buttonColumn.width
        anchors.topMargin:  _verticalMargin
        anchors.top:        parent.top
        anchors.bottom:     parent.bottom
        anchors.leftMargin: _horizontalMargin
        anchors.left:       parent.left
        contentHeight:      buttonColumn.height + _verticalMargin
        flickableDirection: Flickable.VerticalFlick
        clip:               true

        ColumnLayout {
            id:         buttonColumn
            spacing:    0

            property real _maxButtonWidth: 0

            Component {
                id: dividerComponent

                Item { height: ScreenTools.defaultFontPixelHeight / 2 }
            }

            Component {
                id: buttonComponent

                SettingsButton {
                    text:               modelName
                    icon.source:        modelIconUrl
                    visible:            modelPageVisible()
                    ButtonGroup.group:  buttonGroup

                    onClicked: {
                        if (mainWindow.allowViewSwitch()) {
                            if (rightPanel.source !== modelUrl) {
                                rightPanel.source = modelUrl
                            }
                            checked = true
                        }
                    }

                    Component.onCompleted: {
                        if (globals.commingFromRIDIndicator) {
                            _commingFromRIDSettings = true
                        }
                        if(_first) {
                            _first = false
                            checked = true
                        }
                        if (_commingFromRIDSettings) {
                            checked = false
                            _commingFromRIDSettings = false
                            if (modelUrl == "qrc:/qml/beeCopter/AppSettings/RemoteIDSettings.qml") {
                                checked = true
                            }
                        }
                    }
                }
            }

            Repeater {
                id:     buttonRepeater
                model:  settingsPagesModel

                Loader {
                    Layout.fillWidth: true
                    sourceComponent: _sourceComponent()

                    property var modelName: name
                    property var modelIconUrl: iconUrl
                    property var modelUrl: url
                    property var modelPageVisible: pageVisible

                    function _sourceComponent() {
                        if (name === "Divider") {
                            return dividerComponent
                        } else if (pageVisible()) {
                            return buttonComponent
                        } else {
                            return undefined
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id:                     divider
        anchors.topMargin:      _verticalMargin
        anchors.bottomMargin:   _verticalMargin
        anchors.leftMargin:     _horizontalMargin
        anchors.left:           buttonList.right
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
        width:                  1
        color:                  beeCopterPal.windowShade
    }

    //-- Panel Contents
    Loader {
        id:                     rightPanel
        anchors.leftMargin:     _horizontalMargin
        anchors.rightMargin:    _horizontalMargin
        anchors.topMargin:      _verticalMargin
        anchors.bottomMargin:   _verticalMargin
        anchors.left:           divider.right
        anchors.right:          parent.right
        anchors.top:            parent.top
        anchors.bottom:         parent.bottom
    }
}
