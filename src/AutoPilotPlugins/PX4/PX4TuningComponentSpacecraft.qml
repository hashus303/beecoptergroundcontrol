import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls

SetupPage {
    id:             tuningPage
    pageComponent:  pageComponent

    Component {
        id: pageComponent

        PX4TuningComponentSpacecraftAll {
        }
    } // Component - pageComponent
} // SetupPage
