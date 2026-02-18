import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls
import beeCopter.VehicleSetup
import beeCopter.FactControls

Flow {
    spacing: ScreenTools.defaultFontPixelWidth

    property var _joystick: joystickManager.activeJoystick

    beeCopterPalette { id: beeCopterPal }

    Connections {
        target: _joystick

        onRawButtonPressedChanged: (index, pressed) => {
            if (buttonRepeater.itemAt(index)) {
                buttonRepeater.itemAt(index).pressed = pressed
            }
        }
    }

    Repeater {
        id: buttonRepeater
        model: _joystick.buttonCount

        Rectangle {
            implicitWidth: ScreenTools.defaultFontPixelHeight * 1.5
            implicitHeight: width
            border.width: 1
            border.color: beeCopterPal.text
            color: pressed ? beeCopterPal.buttonHighlight : beeCopterPal.button

            property bool pressed

            beeCopterLabel {
                anchors.fill: parent
                color: pressed ? beeCopterPal.buttonHighlightText : beeCopterPal.buttonText
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: modelData
            }
        }
    }
}
