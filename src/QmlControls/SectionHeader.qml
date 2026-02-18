import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls

CheckBox {
    id:             control
    focusPolicy:    Qt.ClickFocus
    checked:        true
    leftPadding:    0

    property var            color:          beeCopterPal.text
    property bool           showSpacer:     true
    property ButtonGroup    buttonGroup:    null

    property real _sectionSpacer: ScreenTools.defaultFontPixelWidth / 2  // spacing between section headings

    onButtonGroupChanged: {
        if (buttonGroup) {
            buttonGroup.addButton(control)
        }
    }

    beeCopterPalette { id: beeCopterPal; colorGroupEnabled: enabled }

    contentItem: ColumnLayout {
        Item {
            Layout.preferredHeight: control._sectionSpacer
            width:                  1
            visible:                control.showSpacer
        }

        beeCopterLabel {
            text:               control.text
            color:              control.color
            Layout.fillWidth:   true

            beeCopterColoredImage {
                anchors.right:          parent.right
                anchors.verticalCenter: parent.verticalCenter
                width:                  parent.height / 2
                height:                 width
                source:                 "/qmlimages/arrow-down.png"
                color:                  beeCopterPal.text
                visible:                !control.checked
            }
        }

        Rectangle {
            Layout.fillWidth:   true
            height:             1
            color:              beeCopterPal.text
        }
    }

    indicator: Item {}
}
