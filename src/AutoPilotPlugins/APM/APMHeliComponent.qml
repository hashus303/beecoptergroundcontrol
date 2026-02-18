import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import beeCopter
import beeCopter.FactControls
import beeCopter.Controls

SetupPage {
    id:             safetyPage
    pageComponent:  safetyPageComponent

    Component {
        id: safetyPageComponent

        Flow {
            id:         flowLayout
            width:      availableWidth
            spacing:    _margins

            FactPanelController { id: controller; }

            beeCopterPalette { id: ggcPal; colorGroupEnabled: true }

            property real _margins:     ScreenTools.defaultFontPixelHeight
            property bool _showIcon:    !ScreenTools.isTinyScreen

            property Fact _hSvMan:          controller.getParameterFact(-1, "H_SV_MAN")
            property Fact _hSwType:         controller.getParameterFact(-1, "H_SW_TYPE")
            property Fact _hSwColDir:       controller.getParameterFact(-1, "H_SW_COL_DIR")
            property Fact _hSwLinSvo:       controller.getParameterFact(-1, "H_SW_LIN_SVO")
            property Fact _hFlybarMode:     controller.getParameterFact(-1, "H_FLYBAR_MODE")
            property Fact _hCycMax:         controller.getParameterFact(-1, "H_CYC_MAX")
            property Fact _hColMax:         controller.getParameterFact(-1, "H_COL_MAX")
            property Fact _hColAngMax:      controller.getParameterFact(-1, "H_COL_ANG_MAX")
            property Fact _hColMin:         controller.getParameterFact(-1, "H_COL_MIN")
            property Fact _hColAngMin:      controller.getParameterFact(-1, "H_COL_ANG_MIN")
            property Fact _hColZeroThrst:   controller.getParameterFact(-1, "H_COL_ZERO_THRST")
            property Fact _hColLandMin:     controller.getParameterFact(-1, "H_COL_LAND_MIN")

            property Fact _hRscMode:        controller.getParameterFact(-1, "H_RSC_MODE")
            property Fact _hRscCritical:    controller.getParameterFact(-1, "H_RSC_CRITICAL")
            property Fact _hRscRampTime:    controller.getParameterFact(-1, "H_RSC_RAMP_TIME")
            property Fact _hRscRunupTime:   controller.getParameterFact(-1, "H_RSC_RUNUP_TIME")
            property Fact _hRscCldwnTime:   controller.getParameterFact(-1, "H_RSC_CLDWN_TIME")
            property Fact _hRscSetpoint:    controller.getParameterFact(-1, "H_RSC_SETPOINT")
            property Fact _hRscIdle:        controller.getParameterFact(-1, "H_RSC_IDLE")
            property Fact _hRscThrcrv0:     controller.getParameterFact(-1, "H_RSC_THRCRV_0")
            property Fact _hRscThrcrv25:    controller.getParameterFact(-1, "H_RSC_THRCRV_25")
            property Fact _hRscThrcrv50:    controller.getParameterFact(-1, "H_RSC_THRCRV_50")
            property Fact _hRscThrcrv75:    controller.getParameterFact(-1, "H_RSC_THRCRV_75")
            property Fact _hRscThrcrv100:   controller.getParameterFact(-1, "H_RSC_THRCRV_100")

            property Fact _hRscGovComp:     controller.getParameterFact(-1, "H_RSC_GOV_COMP")
            property Fact _hRscGovDroop:    controller.getParameterFact(-1, "H_RSC_GOV_DROOP")
            property Fact _hRscGovFf:       controller.getParameterFact(-1, "H_RSC_GOV_FF")
            property Fact _hRscGovRange:    controller.getParameterFact(-1, "H_RSC_GOV_RANGE")
            property Fact _hRscGovRpm:      controller.getParameterFact(-1, "H_RSC_GOV_RPM")
            property Fact _hRscGovTorque:   controller.getParameterFact(-1, "H_RSC_GOV_TORQUE")

            property Fact _imStbCol1:      controller.getParameterFact(-1, "IM_STB_COL_1")
            property Fact _imStbCol2:      controller.getParameterFact(-1, "IM_STB_COL_2")
            property Fact _imStbCol3:      controller.getParameterFact(-1, "IM_STB_COL_3")
            property Fact _imStbCol4:      controller.getParameterFact(-1, "IM_STB_COL_4")
            property Fact _hTailType:       controller.getParameterFact(-1, "H_TAIL_TYPE")
            property Fact _hTailSpeed:      controller.getParameterFact(-1, "H_TAIL_SPEED")
            property Fact _hGyrGain:        controller.getParameterFact(-1, "H_GYR_GAIN")
            property Fact _hGyrGainAcro:    controller.getParameterFact(-1, "H_GYR_GAIN_ACRO")
            property Fact _hColYaw:         controller.getParameterFact(-1, "H_COLYAW")

            beeCopterGroupBox {
                title: qsTr("Servo Setup")

                GridLayout {
                    columns: 6

                    beeCopterLabel { text: qsTr("Servo") }
                    beeCopterLabel { text: qsTr("Function") }
                    beeCopterLabel { text: qsTr("Min") }
                    beeCopterLabel { text: qsTr("Max") }
                    beeCopterLabel { text: qsTr("Trim") }
                    beeCopterLabel { text: qsTr("Reversed") }

                    beeCopterLabel { text: qsTr("1") }
                    FactComboBox {
                        fact:               controller.getParameterFact(-1, "SERVO1_FUNCTION")
                        indexModel:         false
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:               controller.getParameterFact(-1, "SERVO1_MIN")
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:               controller.getParameterFact(-1, "SERVO1_MAX")
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:               controller.getParameterFact(-1, "SERVO1_TRIM")
                        Layout.fillWidth:   true
                    }
                    FactCheckBox {
                        fact:               controller.getParameterFact(-1, "SERVO1_REVERSED")
                        Layout.fillWidth:   true
                    }

                    beeCopterLabel { text: qsTr("2") }
                    FactComboBox {
                        fact:               controller.getParameterFact(-1, "SERVO2_FUNCTION")
                        indexModel:         false
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:               controller.getParameterFact(-1, "SERVO2_MIN")
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:               controller.getParameterFact(-1, "SERVO2_MAX")
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:               controller.getParameterFact(-1, "SERVO2_TRIM")
                        Layout.fillWidth:   true
                    }
                    FactCheckBox {
                        fact:               controller.getParameterFact(-1, "SERVO2_REVERSED")
                        Layout.fillWidth:   true
                    }

                    beeCopterLabel { text: qsTr("3") }
                    FactComboBox {
                        fact:               controller.getParameterFact(-1, "SERVO3_FUNCTION")
                        indexModel:         false
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:               controller.getParameterFact(-1, "SERVO3_MIN")
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:               controller.getParameterFact(-1, "SERVO3_MAX")
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:               controller.getParameterFact(-1, "SERVO3_TRIM")
                        Layout.fillWidth:   true
                    }
                    FactCheckBox {
                        fact:               controller.getParameterFact(-1, "SERVO3_REVERSED")
                        Layout.fillWidth:   true
                    }

                    beeCopterLabel { text: qsTr("4") }
                    FactComboBox {
                        fact:               controller.getParameterFact(-1, "SERVO4_FUNCTION")
                        indexModel:         false
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:               controller.getParameterFact(-1, "SERVO4_MIN")
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:               controller.getParameterFact(-1, "SERVO4_MAX")
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:               controller.getParameterFact(-1, "SERVO4_TRIM")
                        Layout.fillWidth:   true
                    }
                    FactCheckBox {
                        fact:               controller.getParameterFact(-1, "SERVO4_REVERSED")
                        Layout.fillWidth:   true
                    }

                    beeCopterLabel { text: qsTr("5") }
                    FactComboBox {
                        fact:               controller.getParameterFact(-1, "SERVO5_FUNCTION")
                        indexModel:         false
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:               controller.getParameterFact(-1, "SERVO5_MIN")
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:               controller.getParameterFact(-1, "SERVO5_MAX")
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:               controller.getParameterFact(-1, "SERVO5_TRIM")
                        Layout.fillWidth:   true
                    }
                    FactCheckBox {
                        fact:               controller.getParameterFact(-1, "SERVO5_REVERSED")
                        Layout.fillWidth:   true
                    }

                    beeCopterLabel { text: qsTr("6") }
                    FactComboBox {
                        fact:               controller.getParameterFact(-1, "SERVO6_FUNCTION")
                        indexModel:         false
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:               controller.getParameterFact(-1, "SERVO6_MIN")
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:               controller.getParameterFact(-1, "SERVO6_MAX")
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:               controller.getParameterFact(-1, "SERVO6_TRIM")
                        Layout.fillWidth:   true
                    }
                    FactCheckBox {
                        fact:               controller.getParameterFact(-1, "SERVO6_REVERSED")
                        Layout.fillWidth:   true
                    }

                    beeCopterLabel { text: qsTr("7") }
                    FactComboBox {
                        fact:               controller.getParameterFact(-1, "SERVO7_FUNCTION")
                        indexModel:         false
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:               controller.getParameterFact(-1, "SERVO7_MIN")
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:               controller.getParameterFact(-1, "SERVO7_MAX")
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:               controller.getParameterFact(-1, "SERVO7_TRIM")
                        Layout.fillWidth:   true
                    }
                    FactCheckBox {
                        fact:               controller.getParameterFact(-1, "SERVO7_REVERSED")
                        Layout.fillWidth:   true
                    }

                    beeCopterLabel { text: qsTr("8") }
                    FactComboBox {
                        fact:               controller.getParameterFact(-1, "SERVO8_FUNCTION")
                        indexModel:         false
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:               controller.getParameterFact(-1, "SERVO8_MIN")
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:               controller.getParameterFact(-1, "SERVO8_MAX")
                        Layout.fillWidth:   true
                    }
                    FactTextField {
                        fact:               controller.getParameterFact(-1, "SERVO8_TRIM")
                        Layout.fillWidth:   true
                    }
                    FactCheckBox {
                        fact:               controller.getParameterFact(-1, "SERVO8_REVERSED")
                        Layout.fillWidth:   true
                    }
                }
            }

            beeCopterGroupBox {
                title: qsTr("Swashplate Setup")

                GridLayout {
                    columns: 2

                    beeCopterLabel { text: _hSvMan.shortDescription }
                    FactComboBox {
                        fact:       _hSvMan
                        indexModel: false
                    }

                    beeCopterLabel { text: _hSwType.shortDescription }
                    FactComboBox {
                        fact:       _hSwType
                        indexModel: false
                    }

                    beeCopterLabel { text: _hSwColDir.shortDescription }
                    FactComboBox {
                        fact:       _hSwColDir
                        indexModel: false
                    }

                    beeCopterLabel { text: _hSwLinSvo.shortDescription }
                    FactComboBox {
                        fact:       _hSwLinSvo
                        indexModel: false
                    }

                    beeCopterLabel { text: _hFlybarMode.shortDescription }
                    FactComboBox {
                        fact:       _hFlybarMode
                        indexModel: false
                    }

                    beeCopterLabel { text: _hCycMax.shortDescription }
                    FactTextField { fact: _hCycMax }

                    beeCopterLabel { text: _hColMax.shortDescription }
                    FactTextField { fact: _hColMax }

                    beeCopterLabel { text: _hColAngMax.shortDescription }
                    FactTextField { fact: _hColAngMax }

                    beeCopterLabel { text: _hColMin.shortDescription }
                    FactTextField { fact: _hColMin }

                    beeCopterLabel { text: _hColAngMin.shortDescription }
                    FactTextField { fact: _hColAngMin }

                    beeCopterLabel { text: _hColZeroThrst.shortDescription }
                    FactTextField { fact: _hColZeroThrst }

                    beeCopterLabel { text: _hColLandMin.shortDescription }
                    FactTextField { fact: _hColLandMin }
                }
            }

            beeCopterGroupBox {
                title: qsTr("Throttle Settings")

                GridLayout {
                    columns: 2

                    beeCopterLabel { text: _hRscMode.shortDescription }
                    FactComboBox {
                        fact:       _hRscMode
                        indexModel: false
                    }

                    beeCopterLabel { text: _hRscCritical.shortDescription }
                    FactTextField { fact: _hRscCritical }

                    beeCopterLabel { text: _hRscRampTime.shortDescription }
                    FactTextField { fact: _hRscRampTime }

                    beeCopterLabel { text: _hRscRunupTime.shortDescription }
                    FactTextField { fact: _hRscRunupTime }

                    beeCopterLabel { text: _hRscCldwnTime.shortDescription }
                    FactTextField { fact: _hRscCldwnTime }

                    beeCopterLabel { text: _hRscSetpoint.shortDescription }
                    FactTextField { fact: _hRscSetpoint }

                    beeCopterLabel { text: _hRscIdle.shortDescription }
                    FactTextField { fact: _hRscIdle }

                    beeCopterLabel { text: _hRscThrcrv0.shortDescription }
                    FactTextField { fact: _hRscThrcrv0 }

                    beeCopterLabel { text: _hRscThrcrv25.shortDescription }
                    FactTextField { fact: _hRscThrcrv25 }

                    beeCopterLabel { text: _hRscThrcrv50.shortDescription }
                    FactTextField { fact: _hRscThrcrv50 }

                    beeCopterLabel { text: _hRscThrcrv75.shortDescription }
                    FactTextField { fact: _hRscThrcrv75 }

                    beeCopterLabel { text: _hRscThrcrv100.shortDescription }
                    FactTextField { fact: _hRscThrcrv100 }
                }
            }

            beeCopterGroupBox {
                title: qsTr("Governor Settings")

                GridLayout {
                    columns: 2

                    beeCopterLabel { text: _hRscGovComp.shortDescription }
                    FactTextField { fact: _hRscGovComp }

                    beeCopterLabel { text: _hRscGovDroop.shortDescription }
                    FactTextField { fact: _hRscGovDroop }

                    beeCopterLabel { text: _hRscGovFf.shortDescription }
                    FactTextField { fact: _hRscGovFf }

                    beeCopterLabel { text: _hRscGovRange.shortDescription }
                    FactTextField { fact: _hRscGovRange }

                    beeCopterLabel { text: _hRscGovRpm.shortDescription }
                    FactTextField { fact: _hRscGovRpm }

                    beeCopterLabel { text: _hRscGovTorque.shortDescription }
                    FactTextField { fact: _hRscGovTorque }
                }
            }

            beeCopterGroupBox {
                title: qsTr("Miscellaneous Settings")

                GridLayout {
                    columns: 2

                    beeCopterLabel { text: qsTr("* Stabilize Collective Curve *") }
                    beeCopterLabel { text: qsTr("") }

                    beeCopterLabel { text: _imStbCol1.shortDescription }
                    FactTextField { fact: _imStbCol1 }

                    beeCopterLabel { text: _imStbCol2.shortDescription }
                    FactTextField { fact: _imStbCol2 }

                    beeCopterLabel { text: _imStbCol3.shortDescription }
                    FactTextField { fact: _imStbCol3 }

                    beeCopterLabel { text: _imStbCol4.shortDescription }
                    FactTextField { fact: _imStbCol4 }

                    beeCopterLabel { text: qsTr("* Tail & Gyros *") }
                    beeCopterLabel { text: qsTr("") }

                    beeCopterLabel { text: _hTailType.shortDescription }
                    FactComboBox {
                        fact:       _hTailType
                        indexModel: false
                    }

                    beeCopterLabel { text: _hTailSpeed.shortDescription }
                    FactTextField { fact: _hTailSpeed }

                    beeCopterLabel { text: _hGyrGain.shortDescription }
                    FactTextField { fact: _hGyrGain }

                    beeCopterLabel { text: _hGyrGainAcro.shortDescription }
                    FactTextField { fact: _hGyrGainAcro }

                    beeCopterLabel { text: _hColYaw.shortDescription }
                    FactTextField { fact: _hColYaw }
                }
            }
        } // Flow
    } // Component
} // SetupView
