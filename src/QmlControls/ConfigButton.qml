import beeCopter
import beeCopter.Controls

SettingsButton {
    icon.color: setupComplete ? textColor : "red"

    property bool setupComplete: true
}
