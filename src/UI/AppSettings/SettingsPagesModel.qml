import QtQml.Models

import beeCopter
import beeCopter.Controls

ListModel {
    ListElement {
        name: qsTr("General")
        url: "qrc:/qml/beeCopter/AppSettings/GeneralSettings.qml"
        iconUrl: "qrc:/res/beeCopterLogoWhite.svg"
        pageVisible: function() { return true }
    }

    ListElement {
        name: qsTr("Fly View")
        url: "qrc:/qml/beeCopter/AppSettings/FlyViewSettings.qml"
        iconUrl: "qrc:/qmlimages/PaperPlane.svg"
        pageVisible: function() { return true }
    }

    ListElement {
        name: qsTr("3D View")
        url: "qrc:/qml/beeCopter/Viewer3D/Viewer3DSettings.qml"
        iconUrl: "qrc:/qml/beeCopter/Viewer3D/City3DMapIcon.svg"
        pageVisible: function() { return beeCopter.settingsManager.viewer3DSettings.visible }
    }

    ListElement {
        name: qsTr("Plan View")
        url: "qrc:/qml/beeCopter/AppSettings/PlanViewSettings.qml"
        iconUrl: "qrc:/qmlimages/Plan.svg"
        pageVisible: function() { return true }
    }

    ListElement {
        name: qsTr("Video")
        url: "qrc:/qml/beeCopter/AppSettings/VideoSettings.qml"
        iconUrl: "qrc:/InstrumentValueIcons/camera.svg"
        pageVisible: function() { return beeCopter.settingsManager.videoSettings.visible }
    }

    ListElement {
        name: "Divider"
    }

    ListElement {
        name: qsTr("ADSB Server")
        url: "qrc:/qml/beeCopter/AppSettings/ADSBServerSettings.qml"
        iconUrl: "qrc:/InstrumentValueIcons/airplane.svg"
        pageVisible: function() { return true }
    }

    ListElement {
        name: qsTr("Comm Links")
        url: "qrc:/qml/beeCopter/AppSettings/LinkSettings.qml"
        iconUrl: "qrc:/InstrumentValueIcons/usb.svg"
        pageVisible: function() { return true }
    }

    ListElement {
        name: qsTr("Logging")
        url: "qrc:/qml/beeCopter/Controls/AppLogging.qml"
        iconUrl: "qrc:/InstrumentValueIcons/conversation.svg"
        pageVisible: function() { return true }
    }

    ListElement {
        name: qsTr("Maps")
        url: "qrc:/qml/beeCopter/AppSettings/MapSettings.qml"
        iconUrl: "qrc:/InstrumentValueIcons/globe.svg"
        pageVisible: function() { return true }
    }

    ListElement {
        name: qsTr("NTRIP/RTK")
        url: "qrc:/qml/beeCopter/AppSettings/NTRIPSettings.qml"
        iconUrl: "qrc:/InstrumentValueIcons/globe.svg"
        pageVisible: function() {
            return beeCopter.settingsManager &&
                   beeCopter.settingsManager.ntripSettings !== undefined
        }
    }

    ListElement {
        name: qsTr("PX4 Log Transfer")
        url: "qrc:/qml/beeCopter/AppSettings/PX4LogTransferSettings.qml"
        iconUrl: "qrc:/InstrumentValueIcons/inbox-download.svg"
        pageVisible: function() {
            var activeVehicle = beeCopter.multiVehicleManager.activeVehicle
            return beeCopter.corePlugin.options.showPX4LogTransferOptions &&
                        beeCopter.px4ProFirmwareSupported &&
                        (activeVehicle ? activeVehicle.px4Firmware : true)
        }
    }

    ListElement {
        name: qsTr("Remote ID")
        url: "qrc:/qml/beeCopter/AppSettings/RemoteIDSettings.qml"
        iconUrl: "qrc:/qmlimages/RidIconManNoID.svg"
        pageVisible: function() { return true }
    }

    ListElement {
        name: qsTr("Telemetry")
        url: "qrc:/qml/beeCopter/AppSettings/TelemetrySettings.qml"
        iconUrl: "qrc:/InstrumentValueIcons/drone.svg"
        pageVisible: function() { return true }
    }

    ListElement {
        name: "Divider"
    }

    ListElement {
        name: qsTr("Help")
        url: "qrc:/qml/beeCopter/AppSettings/HelpSettings.qml"
        iconUrl: "qrc:/InstrumentValueIcons/question.svg"
        pageVisible: function() { return true }
    }

    ListElement {
        name: "Divider"
    }

    ListElement {
        name: qsTr("Mock Link")
        url: "qrc:/qml/beeCopter/AppSettings/MockLink.qml"
        iconUrl: "qrc:/InstrumentValueIcons/drone.svg"
        pageVisible: function() { return ScreenTools.isDebug }
    }

    ListElement {
        name: qsTr("Debug")
        url: "qrc:/qml/beeCopter/AppSettings/DebugWindow.qml"
        iconUrl: "qrc:/InstrumentValueIcons/bug.svg"
        pageVisible: function() { return ScreenTools.isDebug }
    }

    ListElement {
        name: qsTr("Palette Test")
        url: "qrc:/qml/beeCopter/AppSettings/QmlTest.qml"
        iconUrl: "qrc:/InstrumentValueIcons/photo.svg"
        pageVisible: function() { return ScreenTools.isDebug }
    }
}
