import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls

// We implement our own TabButton to get around the fact that QtQuick.Controls TabBar does not
// support hiding tabs. This version supports hiding tabs by setting the visible property
// on the beeCopterTabButton instances.
Button {
    id: control
    Layout.fillWidth: true
    topPadding: _verticalPadding
    bottomPadding: _verticalPadding
    leftPadding: _horizontalPadding
    rightPadding: _horizontalPadding
    focusPolicy: Qt.ClickFocus
    checkable: true

    property bool primary: false ///< primary button for a group of buttons
    property real pointSize: ScreenTools.defaultFontPointSize ///< Point size for button text
    property bool showBorder: beeCopterPal.globalTheme === beeCopterPalette.Light
    property real backRadius: ScreenTools.defaultBorderRadius
    property real heightFactor: 0.5

    property bool _showHighlight: enabled && (pressed | checked)
    property int _horizontalPadding: ScreenTools.defaultFontPixelWidth
    property int _verticalPadding: Math.round(ScreenTools.defaultFontPixelHeight * heightFactor)
    property bool _showIcon: control.icon.source != ""

    beeCopterPalette { id: beeCopterPal; colorGroupEnabled: enabled }

    background: Rectangle {
        id: backRect
        implicitWidth: ScreenTools.implicitButtonWidth
        implicitHeight: ScreenTools.implicitButtonHeight
        //radius: backRadius
        border.width: showBorder ? 1 : 0
        border.color: beeCopterPal.buttonBorder
        color: _showHighlight ? beeCopterPal.buttonHighlight : beeCopterPal.button
    }

    contentItem: Item {
        implicitWidth: _showIcon ? icon.width : text.implicitWidth
        implicitHeight: _showIcon ? icon.height : text.implicitHeight
        baselineOffset: text.y + text.baselineOffset

        beeCopterColoredImage {
            id: icon
            anchors.centerIn: parent
            source: control.icon.source
            height: source === "" ? 0 : ScreenTools.defaultFontPixelHeight
            width: height
            color: _showHighlight ? beeCopterPal.buttonHighlightText : beeCopterPal.buttonText
            fillMode: Image.PreserveAspectFit
            sourceSize.height: height
            visible: _showIcon
        }

        Text {
            id: text
            anchors.centerIn: parent
            antialiasing: true
            text: control.text
            font.pointSize: control.pointSize
            font.family: ScreenTools.normalFontFamily
            color: _showHighlight ? beeCopterPal.buttonHighlightText : beeCopterPal.buttonText
            visible: !_showIcon
        }
    }
}
