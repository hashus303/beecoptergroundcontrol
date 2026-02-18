import beeCopter
import beeCopter.FlyView

ToolStripAction {
    id:         action
    text:       qsTr("Gripper")
    iconSource: "/res/Gripper.svg"
    visible:    _gripperAvailable

    property var   _activeVehicle:      beeCopter.multiVehicleManager.activeVehicle
    property bool  _gripperAvailable:   _activeVehicle ? _activeVehicle.hasGripper : false

    dropPanelComponent: Component {
        FlyViewGripperDropPanel {
        }
    }
}
