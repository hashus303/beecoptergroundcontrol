import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import beeCopter
import beeCopter.Controls
import beeCopter.FlyView

Item {
    required property var guidedValueSlider

    id:     control
    width:  parent.width
    height: ScreenTools.toolbarHeight

    property var    _activeVehicle:     beeCopter.multiVehicleManager.activeVehicle
    property bool   _communicationLost: _activeVehicle ? _activeVehicle.vehicleLinkManager.communicationLost : false
    property color  _mainStatusBGColor: beeCopterPal.brandingPurple
    property real   _leftRightMargin:   ScreenTools.defaultFontPixelWidth * 0.75
    property var    _guidedController:  globals.guidedControllerFlyView

    function dropMainStatusIndicatorTool() {
        mainStatusIndicator.dropMainStatusIndicator();
    }

    beeCopterPalette { id: beeCopterPal }

    beeCopterFlickable {
        anchors.fill:       parent
        contentWidth:       toolBarLayout.width
        flickableDirection: Flickable.HorizontalFlick

        Row {
            id:         toolBarLayout
            height:     parent.height
            spacing:    0

            Item {
                id:     leftPanel
                width:  leftPanelLayout.implicitWidth
                height: parent.height

                // Gradient background behind Q button and main status indicator
                Rectangle {
                    id:         gradientBackground
                    height:     parent.height
                    width:      mainStatusLayout.width
                    opacity:    beeCopterPal.windowTransparent.a

                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0; color: _mainStatusBGColor }
                        //GradientStop { position: beeCopterButton.x + beeCopterButton.width; color: _mainStatusBGColor }
                        GradientStop { position: 1; color: beeCopterPal.window }
                    }
                }

                // Standard toolbar background to the right of the gradient
                Rectangle {
                    anchors.left:   gradientBackground.right
                    anchors.right:  parent.right
                    height:         parent.height
                    color:          beeCopterPal.windowTransparent
                }

                RowLayout {
                    id:         leftPanelLayout
                    height:     parent.height
                    spacing:    ScreenTools.defaultFontPixelWidth * 2

                    RowLayout {
                        id:         mainStatusLayout
                        height:     parent.height
                        spacing:    0

                        beeCopterToolBarButton {
                            id:                 beeCopterButton
                            Layout.fillHeight:  true
                            icon.source:        "/res/beeCopterLogoFull.svg"
                            logo:               true
                            onClicked:          mainWindow.showToolSelectDialog()
                        }

                        MainStatusIndicator {
                            id:                 mainStatusIndicator
                            Layout.fillHeight:  true
                        }
                    }

                    beeCopterButton {
                        id:         disconnectButton
                        text:       qsTr("Disconnect")
                        onClicked:  _activeVehicle.closeVehicle()
                        visible:    _activeVehicle && _communicationLost
                    }

                    FlightModeIndicator {
                        Layout.fillHeight:  true
                        visible:            _activeVehicle
                    }
                }
            }
            Item {
                id:     centerPanel
                // center panel takes up all remaining space in toolbar between left and right panels
                width:  Math.max(guidedActionConfirm.visible ? guidedActionConfirm.width : 0, control.width - (leftPanel.width + rightPanel.width))
                height: parent.height

                Rectangle {
                    anchors.fill:   parent
                    color:          beeCopterPal.windowTransparent
                }

                GuidedActionConfirm {
                    id:                         guidedActionConfirm
                    height:                     parent.height
                    anchors.horizontalCenter:   parent.horizontalCenter
                    guidedController:           control._guidedController
                    guidedValueSlider:          control.guidedValueSlider
                    messageDisplay:             guidedActionMessageDisplay
                }
            }

            Item {
                id:     rightPanel
                width:  flyViewIndicators.width
                height: parent.height

                Rectangle {
                    anchors.fill:   parent
                    color:          beeCopterPal.windowTransparent
                }

                FlyViewToolBarIndicators {
                    id:     flyViewIndicators
                    height: parent.height
                }
            }
        }
    }

    // The guided action message display is outside of the GuidedActionConfirm control so that it doesn't end up as
    // part of the Flickable
    Rectangle {
        id:                         guidedActionMessageDisplay
        anchors.top:                control.bottom
        anchors.topMargin:          _margins
        x:                          control.mapFromItem(guidedActionConfirm.parent, guidedActionConfirm.x, 0).x + (guidedActionConfirm.width - guidedActionMessageDisplay.width) / 2
        width:                      messageLabel.contentWidth + (_margins * 2)
        height:                     messageLabel.contentHeight + (_margins * 2)
        color:                      beeCopterPal.windowTransparent
        radius:                     ScreenTools.defaultBorderRadius
        visible:                    guidedActionConfirm.visible

        beeCopterLabel {
            id:         messageLabel
            x:          _margins
            y:          _margins
            width:      ScreenTools.defaultFontPixelWidth * 30
            wrapMode:   Text.WordWrap
            text:       guidedActionConfirm.message
        }

        PropertyAnimation {
            id:         messageOpacityAnimation
            target:     guidedActionMessageDisplay
            property:   "opacity"
            from:       1
            to:         0
            duration:   500
        }

        Timer {
            id:             messageFadeTimer
            interval:       4000
            onTriggered:    messageOpacityAnimation.start()
        }
    }

    ParameterDownloadProgress {
        anchors.fill: parent
    }
}
