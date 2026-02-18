import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls

TextArea {
    id:                     messageText
    Layout.preferredWidth:  ScreenTools.defaultFontPixelWidth * 50
    height:                 contentHeight
    readOnly:               true
    textFormat:             TextEdit.RichText
    color:                  beeCopterPal.text
    placeholderText:        qsTr("No Messages")
    placeholderTextColor:   beeCopterPal.text
    padding:                0
    wrapMode:               TextEdit.Wrap

    property bool noMessages: messageText.length === 0

    property var _fact: null

    function formatMessage(message) {
        message = message.replace(new RegExp("<#E>", "g"), "color: " + beeCopterPal.warningText + "; font: " + (ScreenTools.defaultFontPointSize.toFixed(0) - 1) + "pt monospace;");
        message = message.replace(new RegExp("<#I>", "g"), "color: " + beeCopterPal.warningText + "; font: " + (ScreenTools.defaultFontPointSize.toFixed(0) - 1) + "pt monospace;");
        message = message.replace(new RegExp("<#N>", "g"), "color: " + beeCopterPal.text + "; font: " + (ScreenTools.defaultFontPointSize.toFixed(0) - 1) + "pt monospace;");
        return message;
    }

    Component.onCompleted: {
        messageText.text = formatMessage(_activeVehicle.formattedMessages)
        if (_activeVehicle) {
            _activeVehicle.resetAllMessages()
        }
    }

    Connections {
        target: _activeVehicle
        function onNewFormattedMessage(formattedMessage) { messageText.insert(0, formatMessage(formattedMessage)) }
    }

    FactPanelController {
        id: controller
    }

    onLinkActivated: (link) => {
        if (link.startsWith('param://')) {
            var paramName = link.substr(8);
            _fact = controller.getParameterFact(-1, paramName, true)
            if (_fact != null) {
                paramEditorDialogComponent.createObject(mainWindow).open()
            }
        } else {
            Qt.openUrlExternally(link);
        }
    }

    Component {
        id: paramEditorDialogComponent

        ParameterEditorDialog {
            title:          qsTr("Edit Parameter")
            fact:           messageText._fact
            destroyOnClose: true
        }
    }

    Rectangle {
        anchors.right:   parent.right
        anchors.top:     parent.top
        width:                      ScreenTools.defaultFontPixelHeight * 1.25
        height:                     width
        radius:                     width / 2
        color:                      beeCopter.globalPalette.button
        border.color:               beeCopter.globalPalette.buttonText
        visible:                    !noMessages

        beeCopterColoredImage {
            anchors.margins:    ScreenTools.defaultFontPixelHeight * 0.25
            anchors.centerIn:   parent
            anchors.fill:       parent
            sourceSize.height:  height
            source:             "/res/TrashDelete.svg"
            fillMode:           Image.PreserveAspectFit
            mipmap:             true
            smooth:             true
            color:              beeCopterPal.text
        }

        beeCopterMouseArea {
            fillItem: parent
            onClicked: {
                _activeVehicle.clearMessages()
                mainWindow.closeIndicatorDrawer()
            }
        }
    }
}
