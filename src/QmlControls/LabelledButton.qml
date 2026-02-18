import QtQuick
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls

RowLayout {
    property alias label:                   _label.text
    property alias buttonText:              _button.text
    property real  buttonPreferredWidth:    -1

    signal clicked

    id:         _root
    spacing:    ScreenTools.defaultFontPixelWidth * 2

    beeCopterLabel {
        id:                 _label
        Layout.fillWidth:   true
    }

    beeCopterButton {
        id:                     _button
        Layout.preferredWidth:  buttonPreferredWidth
        onClicked:              _root.clicked()
    }
}
