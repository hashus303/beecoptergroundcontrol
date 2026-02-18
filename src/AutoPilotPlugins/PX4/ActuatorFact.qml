import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import beeCopter
import beeCopter.Controls
import beeCopter.FactControls

Loader {
	property var fact
	id:                     loader

	Component {
		id: factComboBox
		FactComboBox {
			fact:           loader.fact
			indexModel:     false
			sizeToContents: true
		}
	}
	Component {
		id: factCheckbox
		FactCheckBox {
			fact:           loader.fact
		}
	}

	Component {
		id: factTextField
		FactTextField {
			fact:           loader.fact
			width:          ScreenTools.defaultFontPixelWidth * 8
			showUnits:      false
		}
	}
	Component {
		id: factReadOnly
		beeCopterLabel {
			text:           loader.fact.valueString
		}
	}
	Component {
		id: notAvailable
		beeCopterLabel {
			text:           qsTr("(Param not available)")
		}
	}
	sourceComponent: fact ?
		(fact.enumStrings.length > 0 ? factComboBox :
			(fact.readOnly ? factReadOnly : (fact.typeIsBool ? factCheckbox : factTextField))
		) : notAvailable
}
