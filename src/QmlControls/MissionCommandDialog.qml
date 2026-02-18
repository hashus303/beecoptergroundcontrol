import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import beeCopter
import beeCopter.Controls

beeCopterPopupDialog {
    id:         root
    title:      qsTr("Select Mission Command")
    buttons:    Dialog.Cancel

    property var    vehicle
    property var    missionItem
    property var    map
    property bool   flyThroughCommandsAllowed

    ColumnLayout {
        RowLayout {
            spacing: ScreenTools.defaultFontPixelWidth

            beeCopterLabel {
                text: qsTr("Category:")
            }

            beeCopterComboBox {
                id:                     categoryCombo
                Layout.preferredWidth:  30 * ScreenTools.defaultFontPixelWidth
                model:                  beeCopter.missionCommandTree.categoriesForVehicle(vehicle)

                function categorySelected(category) {
                    commandList.model = beeCopter.missionCommandTree.getCommandsForCategory(vehicle, category, flyThroughCommandsAllowed)
                }

                Component.onCompleted: {
                    var category  = missionItem.category
                    currentIndex = find(category)
                    categorySelected(category)
                }

                onActivated: (index) => { categorySelected(textAt(index)) }
            }
        }

        Repeater {
            id:                 commandList
            Layout.fillWidth:   true

            delegate: Rectangle {
                width:  parent.width
                height: commandColumn.height + ScreenTools.defaultFontPixelHeight
                color:  beeCopter.globalPalette.button

                property var    mavCmdInfo: modelData
                property color  textColor:  beeCopter.globalPalette.buttonText

                Column {
                    id:                 commandColumn
                    anchors.margins:    ScreenTools.defaultFontPixelWidth
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    anchors.top:        parent.top

                    beeCopterLabel {
                        text:           mavCmdInfo.friendlyName
                        color:          textColor
                        font.bold:      true
                    }

                    beeCopterLabel {
                        anchors.margins:    ScreenTools.defaultFontPixelWidth
                        anchors.left:       parent.left
                        anchors.right:      parent.right
                        text:               mavCmdInfo.description
                        wrapMode:           Text.WordWrap
                        color:              textColor
                    }
                }

                MouseArea {
                    anchors.fill:   parent
                    onClicked: {
                        missionItem.setMapCenterHintForCommandChange(map.center)
                        missionItem.command = mavCmdInfo.command
                        root.close()
                    }
                }
            }
        }
    }
}
