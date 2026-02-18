import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls

AbstractButton   {
    id:         control
    checkable:  true
    padding:    0

    property bool _showBorder:      beeCopterPal.globalTheme === beeCopterPalette.Light
    property int  _sliderInset:     2
    property bool _showHighlight:   enabled && (pressed || checked)

    beeCopterPalette { id: beeCopterPal; colorGroupEnabled: control.enabled }

    contentItem: Item {
        implicitWidth:  (label.visible ? label.contentWidth + ScreenTools.defaultFontPixelWidth : 0) + indicator.width
        implicitHeight: label.contentHeight

        beeCopterLabel {
            id:             label
            anchors.left:   parent.left
            text:           visible ? control.text : "X"
            visible:        control.text !== ""
        }

        Rectangle {
            id:                     indicator
            anchors.right:          parent.right
            anchors.verticalCenter: parent.verticalCenter
            height:                 ScreenTools.defaultFontPixelHeight
            width:                  height * 2
            radius:                 height / 2
            color:                  checked ? beeCopterPal.buttonHighlight : beeCopterPal.button
            border.width:           _showBorder ? 1 : 0
            border.color:           beeCopterPal.buttonBorder

            Rectangle {
                anchors.fill:   parent
                color:          beeCopterPal.buttonHighlight
                opacity:        _showHighlight ? 1 : control.enabled && control.hovered ? .2 : 0
                radius:         parent.radius
            }

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                x:                      checked ? indicator.width - width - _sliderInset : _sliderInset
                height:                 parent.height - (_sliderInset * 2)
                width:                  height
                radius:                 height / 2
                color:                  beeCopterPal.buttonText
            }
        }
    }
}
