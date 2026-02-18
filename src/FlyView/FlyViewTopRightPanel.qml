import QtQuick
import QtQuick.Layouts

import beeCopter
import beeCopter.FactControls
import beeCopter.Controls
import beeCopter.FlyView
import beeCopter.FlightMap

Rectangle {
    id:             topRightPanel
    width:          contentWidth
    height:         Math.max(contentHeight, minimumHeight)
    color:          beeCopterPal.toolbarBackground
    radius:         ScreenTools.defaultFontPixelHeight / 2
    visible:        !beeCopter.videoManager.fullScreen && _multipleVehicles && _settingEnableMVPanel
    clip:           true

    property bool _settingEnableMVPanel:    beeCopter.settingsManager.appSettings.enableMultiVehiclePanel.value
    property bool  _multipleVehicles:       beeCopter.multiVehicleManager.vehicles.count > 1
    property var   vehicles:                beeCopter.multiVehicleManager.vehicles
    property var   selectedVehicles:        beeCopter.multiVehicleManager.selectedVehicles
    property real  contentWidth:            Math.max(
                                                multiVehicleList.implicitWidth,
                                                swipeViewContainer.implicitWidth
                                            ) + ScreenTools.defaultFontPixelHeight
    property real  contentHeight:           Math.min(
                                                maximumHeight,
                                                topRightPanelColumnLayout.implicitHeight + topRightPanelColumnLayout.anchors.margins * 2
                                            )
    property real  minimumHeight:           swipeViewContainer.height
    property real  maximumHeight

    beeCopterPalette { id: beeCopterPal }

    DeadMouseArea {
        anchors.fill:       parent
    }

    ColumnLayout {
        id:                 topRightPanelColumnLayout
        anchors.fill:       parent
        anchors.margins:    topRightPanel.color.a ? ScreenTools.defaultFontPixelHeight / 2 : 0
        spacing:            ScreenTools.defaultFontPixelWidth * 0.75 // _layoutMargin

        MultiVehicleList {
            id:                    multiVehicleList
            Layout.fillWidth:      true
            Layout.fillHeight:     true

            Rectangle {
                anchors.fill: parent
                visible:      topRightPanel.height === maximumHeight

                Rectangle {
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    anchors.top:        parent.top
                    anchors.margins:    0
                    height:             1
                    color:              beeCopter.globalPalette.groupBorder
                }

                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.00; color: topRightPanel.color }
                    GradientStop { position: 0.05; color: "transparent" }

                    GradientStop { position: 0.95; color: "transparent" }
                    GradientStop { position: 1.00; color: topRightPanel.color }
                }

                Rectangle {
                    anchors.left:       parent.left
                    anchors.right:      parent.right
                    anchors.bottom:     parent.bottom
                    anchors.margins:    0
                    height:             1
                    color:              beeCopter.globalPalette.groupBorder
                }
            }

        }

        Rectangle {
            id:                     swipeViewContainer
            Layout.fillWidth:       true
            implicitHeight:         swipePages.implicitHeight
            implicitWidth:          swipePages.implicitWidth
            color:                  "transparent"

            beeCopterSwipeView {
                id:                swipePages
                anchors.fill:      parent
                spacing:           ScreenTools.defaultFontPixelHeight
                implicitHeight:    Math.max(buttonsPage.implicitHeight, photoVideoPage.implicitHeight)
                implicitWidth:     Math.max(buttonsPage.implicitWidth, photoVideoPage.implicitWidth)

                MvPanelPage {
                    id:                buttonsPage
                    implicitHeight:    buttonsColumnLayout.implicitHeight + ScreenTools.defaultFontPixelHeight * 2
                    implicitWidth:     buttonsColumnLayout.implicitWidth + ScreenTools.defaultFontPixelHeight * 2

                    ColumnLayout {
                        id:                     buttonsColumnLayout
                        anchors.right:          parent.right
                        anchors.left:           parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing:                ScreenTools.defaultFontPixelHeight / 2
                        implicitHeight:         Math.max(selectionRowLayout.height, actionRowLayout.height) + ScreenTools.defaultFontPixelHeight * 2
                        implicitWidth:          Math.max(selectionRowLayout.width, actionRowLayout.width) + ScreenTools.defaultFontPixelHeight * 4

                        beeCopterLabel {
                            text: {
                                let ids = Array.from({length: selectedVehicles.count}, (_, i) =>
                                    selectedVehicles.get(i).id
                                ).sort((a, b) => a - b)
                                .join(", ")
                                return qsTr("Vehicles Selected: ") + (ids ? ids : "-")
                            }
                            Layout.alignment:   Qt.AlignHCenter
                        }

                        RowLayout {
                            id:                 selectionRowLayout
                            Layout.alignment:   Qt.AlignHCenter

                            beeCopterButton {
                                text:                  qsTr("Select All")
                                enabled:               multiVehicleList.selectedVehicles && multiVehicleList.selectedVehicles.count !== beeCopter.multiVehicleManager.vehicles.count
                                onClicked:             multiVehicleList.selectAll()
                            }

                            beeCopterButton {
                                text:                  qsTr("Deselect All")
                                enabled:               multiVehicleList.selectedVehicles && multiVehicleList.selectedVehicles.count > 0
                                onClicked:             multiVehicleList.deselectAll()
                            }

                        }


                        beeCopterLabel {
                            text:              qsTr("Multi Vehicle Actions")
                            Layout.alignment:  Qt.AlignHCenter
                        }

                        RowLayout {
                            id:                actionRowLayout
                            Layout.alignment:  Qt.AlignHCenter

                            beeCopterButton {
                                text:                  qsTr("Arm")
                                enabled:               multiVehicleList.armAvailable()
                                onClicked:             _guidedController.confirmAction(_guidedController.actionMVArm)
                                Layout.preferredWidth: ScreenTools.defaultFontPixelHeight * 2.75
                                leftPadding:           0
                                rightPadding:          0
                            }

                            beeCopterButton {
                                text:                  qsTr("Disarm")
                                enabled:               multiVehicleList.disarmAvailable()
                                onClicked:             _guidedController.confirmAction(_guidedController.actionMVDisarm)
                                Layout.preferredWidth: ScreenTools.defaultFontPixelHeight * 2.75
                                leftPadding:           0
                                rightPadding:          0
                            }

                            beeCopterButton {
                                text:                  qsTr("Start")
                                enabled:               multiVehicleList.startAvailable()
                                onClicked:             _guidedController.confirmAction(_guidedController.actionMVStartMission)
                                Layout.preferredWidth: ScreenTools.defaultFontPixelHeight * 2.75
                                leftPadding:           0
                                rightPadding:          0
                            }

                            beeCopterButton {
                                text:                  qsTr("Pause")
                                enabled:               multiVehicleList.pauseAvailable()
                                onClicked:             _guidedController.confirmAction(_guidedController.actionMVPause)
                                Layout.preferredWidth: ScreenTools.defaultFontPixelHeight * 2.75
                                leftPadding:           0
                                rightPadding:          0
                            }
                        }
                    }
                } // Page 1

                MvPanelPage {

                    id:                  photoVideoPage
                    implicitHeight:      photoVideoControlLoader.implicitHeight + ScreenTools.defaultFontPixelHeight * 2
                    implicitWidth:       photoVideoControlLoader.implicitWidth + ScreenTools.defaultFontPixelHeight * 2

                    // We use a Loader to load the photoVideoControlComponent only when the active vehicle is not null
                    // This make it easier to implement PhotoVideoControl without having to check for the mavlink camera
                    // to be null all over the place

                    Loader {
                        id:                         photoVideoControlLoader
                        anchors.horizontalCenter:   parent.horizontalCenter
                        sourceComponent:            globals.activeVehicle ? photoVideoControlComponent : undefined

                        property real rightEdgeCenterInset: visible ? parent.width - x : 0

                        Component {
                            id: photoVideoControlComponent

                            PhotoVideoControl {
                            }
                        }
                    }
                } // Page 2
            } // beeCopterSwipeView

            beeCopterPageIndicator {
                id:                       pageIndicator
                count:                    swipePages.count
                currentIndex:             swipePages.currentIndex
                anchors.bottom:           parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins:          ScreenTools.defaultFontPixelHeight / 4

                delegate: Rectangle {
                    height:    ScreenTools.defaultFontPixelHeight  / 2
                    width:     height
                    radius:    width / 2
                    color:     model.index === pageIndicator.currentIndex ? beeCopterPal.text : beeCopterPal.button
                    opacity:   model.index === pageIndicator.currentIndex ? 0.9 : 0.3
                }
            }
        }
    }
}
