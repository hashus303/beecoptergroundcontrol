import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls
import beeCopter.FactControls

// Editor for Fixed Wing Landing Pattern complex mission item
Rectangle {
    id:         _root
    height:     visible ? ((editorColumn.visible ? editorColumn.height : editorColumnNeedLandingPoint.height) + (_margin * 2)) : 0
    width:      availableWidth
    color:      beeCopterPal.windowShadeDark
    radius:     _radius

    // The following properties must be available up the hierarchy chain
    //property real   availableWidth    ///< Width for control
    //property var    missionItem       ///< Mission Item for editor

    property var    _masterControler:           masterController
    property var    _missionController:         _masterControler.missionController
    property var    _missionVehicle:            _masterControler.controllerVehicle
    property real   _margin:                    ScreenTools.defaultFontPixelWidth / 2
    property real   _spacer:                    ScreenTools.defaultFontPixelWidth / 2
    property string _setToVehicleHeadingStr:    qsTr("Set to vehicle heading")
    property string _setToVehicleLocationStr:   qsTr("Set to vehicle location")
    property int    _altitudeMode:              missionItem.altitudesAreRelative ? beeCopter.AltitudeModeRelative : beeCopter.AltitudeModeAbsolute


    Column {
        id:                 editorColumn
        anchors.margins:    _margin
        anchors.left:       parent.left
        anchors.right:      parent.right
        spacing:            _margin
        visible:            !editorColumnNeedLandingPoint.visible

        SectionHeader {
            id:             finalApproachSection
            anchors.left:   parent.left
            anchors.right:  parent.right
            text:           qsTr("Final approach")
        }

        Column {
            anchors.left:       parent.left
            anchors.right:      parent.right
            spacing:            _margin
            visible:            finalApproachSection.checked

            Item { width: 1; height: _spacer }

            FactCheckBox {
                text:       qsTr("Use loiter to altitude")
                fact:       missionItem.useLoiterToAlt
            }

            GridLayout {
                anchors.left:    parent.left
                anchors.right:   parent.right
                columns:         2

                beeCopterLabel { text: qsTr("Altitude") }

                AltitudeFactTextField {
                    Layout.fillWidth:   true
                    fact:               missionItem.finalApproachAltitude
                    altitudeMode:       _altitudeMode
                }

                FactCheckBox {
                    id:         flightSpeedCheckbox
                    text:       qsTr("Flight Speed")
                    fact:       missionItem.useDoChangeSpeed
                }

                FactTextField {
                    Layout.fillWidth:   true
                    fact:               missionItem.finalApproachSpeed
                    enabled:            flightSpeedCheckbox.checked
                }

                beeCopterLabel {
                    text:       qsTr("Radius")
                    visible:    missionItem.useLoiterToAlt.rawValue
                }

                FactTextField {
                    Layout.fillWidth:   true
                    fact:               missionItem.loiterRadius
                    visible:            missionItem.useLoiterToAlt.rawValue
                }
            }

            Item { width: 1; height: _spacer }

            FactCheckBox {
                text:       qsTr("Loiter clockwise")
                fact:       missionItem.loiterClockwise
                visible:    missionItem.useLoiterToAlt.rawValue
            }

            beeCopterButton {
                text:       _setToVehicleHeadingStr
                visible:    globals.activeVehicle
                onClicked:  missionItem.landingHeading.rawValue = globals.activeVehicle.heading.rawValue
            }
        }

        SectionHeader {
            id:             landingPointSection
            anchors.left:   parent.left
            anchors.right:  parent.right
            text:           qsTr("Landing point")
        }

        Column {
            anchors.left:       parent.left
            anchors.right:      parent.right
            spacing:            _margin
            visible:            landingPointSection.checked

            Item { width: 1; height: _spacer }

            GridLayout {
                anchors.left:    parent.left
                anchors.right:   parent.right
                columns:         2

                beeCopterLabel { text: qsTr("Heading") }

                FactTextField {
                    Layout.fillWidth:   true
                    fact:               missionItem.landingHeading
                }

                beeCopterLabel { text: qsTr("Altitude") }

                AltitudeFactTextField {
                    Layout.fillWidth:   true
                    fact:               missionItem.landingAltitude
                    altitudeMode:       _altitudeMode
                }

                beeCopterRadioButton {
                    id:                 specifyLandingDistance
                    text:               qsTr("Distance")
                    checked:            missionItem.valueSetIsDistance.rawValue
                    onClicked:          missionItem.valueSetIsDistance.rawValue = checked
                    Layout.fillWidth:   true
                }

                FactTextField {
                    fact:               missionItem.landingDistance
                    enabled:            specifyLandingDistance.checked
                    Layout.fillWidth:   true
                }

                beeCopterRadioButton {
                    id:                 specifyGlideSlope
                    text:               qsTr("Glide Slope")
                    checked:            !missionItem.valueSetIsDistance.rawValue
                    onClicked:          missionItem.valueSetIsDistance.rawValue = !checked
                    Layout.fillWidth:   true
                }

                FactTextField {
                    fact:               missionItem.glideSlope
                    enabled:            specifyGlideSlope.checked
                    Layout.fillWidth:   true
                }

                beeCopterButton {
                    text:               _setToVehicleLocationStr
                    visible:            globals.activeVehicle
                    Layout.columnSpan:  2
                    onClicked:          missionItem.landingCoordinate = globals.activeVehicle.coordinate
                }
            }
        }

        Item { width: 1; height: _spacer }

        beeCopterCheckBox {
            anchors.right:  parent.right
            text:           qsTr("Altitudes relative to launch")
            checked:        missionItem.altitudesAreRelative
            visible:        beeCopter.corePlugin.options.showMissionAbsoluteAltitude || !missionItem.altitudesAreRelative
            onClicked:      missionItem.altitudesAreRelative = checked
        }

        SectionHeader {
            id:             cameraSection
            anchors.left:   parent.left
            anchors.right:  parent.right
            text:           qsTr("Camera")
        }

        Column {
            anchors.left:       parent.left
            anchors.right:      parent.right
            spacing:            _margin
            visible:            cameraSection.checked

            Item { width: 1; height: _spacer }

            FactCheckBox {
                text:       _stopTakingPhotos.shortDescription
                fact:       _stopTakingPhotos

                property Fact _stopTakingPhotos: missionItem.stopTakingPhotos
            }

            FactCheckBox {
                text:       _stopTakingVideo.shortDescription
                fact:       _stopTakingVideo

                property Fact _stopTakingVideo: missionItem.stopTakingVideo
            }
        }

        Column {
            anchors.left:       parent.left
            anchors.right:      parent.right
            spacing:            0

            beeCopterLabel {
                anchors.left:           parent.left
                anchors.right:          parent.right
                wrapMode:               Text.WordWrap
                color:                  beeCopterPal.warningText
                font.pointSize:         ScreenTools.smallFontPointSize
                text:                   qsTr("* Approximate glide slope altitudes.")
            }

            beeCopterLabel {
                anchors.left:           parent.left
                anchors.right:          parent.right
                wrapMode:               Text.WordWrap
                color:                  beeCopterPal.warningText
                font.pointSize:         ScreenTools.smallFontPointSize
                text:                   qsTr("* Actual flight path will vary.")
            }

            beeCopterLabel {
                anchors.left:           parent.left
                anchors.right:          parent.right
                wrapMode:               Text.WordWrap
                color:                  beeCopterPal.warningText
                font.pointSize:         ScreenTools.smallFontPointSize
                text:                   qsTr("* Avoid tailwind on landing.")
            }
        }
    }

    Column {
        id:                 editorColumnNeedLandingPoint
        anchors.margins:    _margin
        anchors.top:        parent.top
        anchors.left:       parent.left
        anchors.right:      parent.right
        visible:            !missionItem.landingCoordSet || missionItem.wizardMode
        spacing:            ScreenTools.defaultFontPixelHeight

        Column {
            id:             landingCoordColumn
            anchors.left:   parent.left
            anchors.right:  parent.right
            spacing:        ScreenTools.defaultFontPixelHeight
            visible:        !missionItem.landingCoordSet

            beeCopterLabel {
                anchors.left:           parent.left
                anchors.right:          parent.right
                wrapMode:               Text.WordWrap
                horizontalAlignment:    Text.AlignHCenter
                text:                   qsTr("Click in map to set landing point.")
            }

            beeCopterLabel {
                anchors.left:           parent.left
                anchors.right:          parent.right
                horizontalAlignment:    Text.AlignHCenter
                text:                   qsTr("- or -")
                visible:                globals.activeVehicle
            }

            beeCopterButton {
                anchors.horizontalCenter:   parent.horizontalCenter
                text:                       _setToVehicleLocationStr
                visible:                    globals.activeVehicle

                onClicked: {
                    missionItem.landingCoordinate = globals.activeVehicle.coordinate
                    missionItem.landingHeading.rawValue = globals.activeVehicle.heading.rawValue
                    missionItem.setLandingHeadingToTakeoffHeading()
                }
            }
        }

        ColumnLayout {
            anchors.left:   parent.left
            anchors.right:  parent.right
            spacing:        ScreenTools.defaultFontPixelHeight / 2
            visible:        !landingCoordColumn.visible

            onVisibleChanged: {
                if (visible) {
                    console.log(missionItem.landingDistance.rawValue)
                }
            }

            beeCopterLabel {
                Layout.fillWidth:   true
                wrapMode:           Text.WordWrap
                text:               qsTr("Drag the loiter point to adjust landing direction for wind and obstacles.")
            }

            FactCheckBox {
                text:       qsTr("Loiter clockwise")
                fact:       missionItem.loiterClockwise
                visible:    missionItem.useLoiterToAlt.rawValue
            }

            beeCopterButton {
                text:               qsTr("Done")
                Layout.fillWidth:   true
                onClicked: {
                    missionItem.wizardMode = false
                    missionItem.landingDragAngleOnly = false
                }
            }
        }
    }
}
