import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import beeCopter
import beeCopter.FactControls
import beeCopter.Controls

SetupPage {
    id:             syslinkPage
    pageComponent:  pageComponent

    Component {
        id: pageComponent

        Column {
            id:         innerColumn
            width:      availableWidth
            spacing:    ScreenTools.defaultFontPixelHeight * 0.5

            property int textEditWidth:    ScreenTools.defaultFontPixelWidth * 12


            SyslinkComponentController {
                id:         controller
            }

            beeCopterLabel {
                text: qsTr("Radio Settings")
                font.bold:   true
            }

            Rectangle {
                width:  parent.width
                height: radioGrid.height + ScreenTools.defaultFontPixelHeight
                color:  beeCopterPal.windowShade

                GridLayout {
                    id:                 radioGrid
                    anchors.margins:    ScreenTools.defaultFontPixelHeight / 2
                    anchors.left:       parent.left
                    anchors.top:        parent.top
                    columns:            2
                    columnSpacing:      ScreenTools.defaultFontPixelWidth

                    beeCopterLabel {
                        text:               qsTr("Channel")
                    }

                    beeCopterTextField {
                        id:                     channelField
                        width:                  textEditWidth
                        text:                   controller.radioChannel
                        validator:              IntValidator {bottom: 0; top: 125;}
                        inputMethodHints:       Qt.ImhDigitsOnly
                        onEditingFinished: {
                            controller.radioChannel = text
                        }
                    }

                    beeCopterLabel {
                        id:                 channelHelp
                        Layout.columnSpan:  radioGrid.columns
                        Layout.fillWidth:   true
                        font.pointSize:     ScreenTools.smallFontPointSize
                        wrapMode:           Text.WordWrap
                        text:               "Channel can be between 0 and 125"
                    }

                    beeCopterLabel {
                        id:                 addressLabel
                        text:               qsTr("Address")
                    }

                    beeCopterTextField {
                        id:                     addressField
                        width:                  textEditWidth
                        text:                   controller.radioAddress
                        maximumLength:          10
                        validator:              RegExpValidator { regExp: /^[0-9A-Fa-f]*$/ }
                        onEditingFinished: {
                            controller.radioAddress = text
                        }
                    }

                    beeCopterLabel {
                        id:                 addressHelp
                        Layout.columnSpan:  radioGrid.columns
                        Layout.fillWidth:   true
                        font.pointSize:     ScreenTools.smallFontPointSize
                        wrapMode:           Text.WordWrap
                        text:               qsTr("Address in hex. Default is E7E7E7E7E7.")
                    }


                    beeCopterLabel {
                        id:                 rateLabel
                        text:               qsTr("Data Rate")
                    }

                    beeCopterComboBox {
                        id:                     rateField
                        Layout.fillWidth:       true
                        model:                  controller.radioRates
                        currentIndex:           controller.radioRate
                        onActivated: (index) => {
                            controller.radioRate = index
                        }
                    }

                    beeCopterButton {
                        text:                           qsTr("Restore Defaults")
                        width:                          textEditWidth
                        onClicked: {
                            controller.resetDefaults()
                        }
                    }

                } // Grid
            } // Rectangle - Radio Settings


        }
    }
}
