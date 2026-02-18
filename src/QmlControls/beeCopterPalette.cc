#include "beeCopterPalette.h"
#include "beeCopterCorePlugin.h"

#include <QtCore/QDebug>

QList<beeCopterPalette*>   beeCopterPalette::_paletteObjects;

beeCopterPalette::Theme beeCopterPalette::_theme = beeCopterPalette::Dark;

QMap<int, QMap<int, QMap<QString, QColor>>> beeCopterPalette::_colorInfoMap;

QStringList beeCopterPalette::_colors;

beeCopterPalette::beeCopterPalette(QObject* parent) :
    QObject(parent),
    _colorGroupEnabled(true)
{
    if (_colorInfoMap.isEmpty()) {
        _buildMap();
    }

    // We have to keep track of all beeCopterPalette objects in the system so we can signal theme change to all of them
    _paletteObjects += this;
}

beeCopterPalette::~beeCopterPalette()
{
    bool fSuccess = _paletteObjects.removeOne(this);
    if (!fSuccess) {
        qWarning() << "Internal error";
    }
}

void beeCopterPalette::_buildMap()
{
    //                                      Light                 Dark
    //                                      Disabled   Enabled    Disabled   Enabled
    DECLARE_beeCopter_COLOR(window,               "#ffffff", "#ffffff", "#222222", "#222222")
    DECLARE_beeCopter_COLOR(windowTransparent,    "#ccffffff", "#ccffffff", "#cc222222", "#cc222222")
    DECLARE_beeCopter_COLOR(windowShadeLight,     "#909090", "#828282", "#707070", "#626262")
    DECLARE_beeCopter_COLOR(windowShade,          "#d9d9d9", "#d9d9d9", "#333333", "#333333")
    DECLARE_beeCopter_COLOR(windowShadeDark,      "#bdbdbd", "#bdbdbd", "#282828", "#282828")
    DECLARE_beeCopter_COLOR(text,                 "#9d9d9d", "#333333", "#707070", "#ffffff")
    DECLARE_beeCopter_COLOR(windowTransparentText,"#9d9d9d", "#000000", "#707070", "#ffffff")
    DECLARE_beeCopter_COLOR(warningText,          "#cc0808", "#cc0808", "#f85761", "#f85761")
    DECLARE_beeCopter_COLOR(button,               "#ffffff", "#ffffff", "#707070", "#626270")
    DECLARE_beeCopter_COLOR(buttonBorder,         "#9d9d9d", "#3A9BDC", "#707070", "#adadb8")
    DECLARE_beeCopter_COLOR(buttonText,           "#9d9d9d", "#333333", "#A6A6A6", "#ffffff")
    DECLARE_beeCopter_COLOR(buttonHighlight,      "#e4e4e4", "#3A9BDC", "#3a3a3a", "#3A9BDC")
    DECLARE_beeCopter_COLOR(buttonHighlightText,  "#2c2c2c", "#ffffff", "#2c2c2c", "#ffffff")
    DECLARE_beeCopter_COLOR(primaryButton,        "#585858", "#8cb3be", "#585858", "#8cb3be")
    DECLARE_beeCopter_COLOR(primaryButtonText,    "#2c2c2c", "#333333", "#2c2c2c", "#000000")
    DECLARE_beeCopter_COLOR(textField,            "#ffffff", "#ffffff", "#707070", "#ffffff")
    DECLARE_beeCopter_COLOR(textFieldText,        "#808080", "#333333", "#000000", "#000000")
    DECLARE_beeCopter_COLOR(mapButton,            "#585858", "#333333", "#585858", "#000000")
    DECLARE_beeCopter_COLOR(mapButtonHighlight,   "#585858", "#be781c", "#585858", "#be781c")
    DECLARE_beeCopter_COLOR(mapIndicator,         "#585858", "#be781c", "#585858", "#be781c")
    DECLARE_beeCopter_COLOR(mapIndicatorChild,    "#585858", "#766043", "#585858", "#766043")
    DECLARE_beeCopter_COLOR(colorGreen,           "#008f2d", "#008f2d", "#00e04b", "#00e04b")
    DECLARE_beeCopter_COLOR(colorYellow,          "#a2a200", "#a2a200", "#ffff00", "#ffff00")
    DECLARE_beeCopter_COLOR(colorYellowGreen,     "#799f26", "#799f26", "#9dbe2f", "#9dbe2f")
    DECLARE_beeCopter_COLOR(colorOrange,          "#bf7539", "#bf7539", "#de8500", "#de8500")
    DECLARE_beeCopter_COLOR(colorRed,             "#b52b2b", "#b52b2b", "#f32836", "#f32836")
    DECLARE_beeCopter_COLOR(colorGrey,            "#808080", "#808080", "#bfbfbf", "#bfbfbf")
    DECLARE_beeCopter_COLOR(colorBlue,            "#1a72ff", "#1a72ff", "#536dff", "#536dff")
    DECLARE_beeCopter_COLOR(alertBackground,      "#eecc44", "#eecc44", "#eecc44", "#eecc44")
    DECLARE_beeCopter_COLOR(alertBorder,          "#808080", "#808080", "#808080", "#808080")
    DECLARE_beeCopter_COLOR(alertText,            "#000000", "#000000", "#000000", "#000000")
    DECLARE_beeCopter_COLOR(missionItemEditor,    "#585858", "#dbfef8", "#585858", "#585d83")
    DECLARE_beeCopter_COLOR(toolStripHoverColor,  "#585858", "#9D9D9D", "#585858", "#585d83")
    DECLARE_beeCopter_COLOR(statusFailedText,     "#9d9d9d", "#000000", "#707070", "#ffffff")
    DECLARE_beeCopter_COLOR(statusPassedText,     "#9d9d9d", "#000000", "#707070", "#ffffff")
    DECLARE_beeCopter_COLOR(statusPendingText,    "#9d9d9d", "#000000", "#707070", "#ffffff")
    DECLARE_beeCopter_COLOR(toolbarBackground,    "#00ffffff", "#00ffffff", "#00222222", "#00222222")
    DECLARE_beeCopter_COLOR(groupBorder,          "#bbbbbb", "#3A9BDC", "#707070", "#707070")

    // Colors not affecting by theming
    //                                                      Disabled     Enabled
    DECLARE_beeCopter_NONTHEMED_COLOR(brandingPurple,             "#4A2C6D", "#4A2C6D")
    DECLARE_beeCopter_NONTHEMED_COLOR(brandingBlue,               "#48D6FF", "#6045c5")
    DECLARE_beeCopter_NONTHEMED_COLOR(toolStripFGColor,           "#707070", "#ffffff")
    DECLARE_beeCopter_NONTHEMED_COLOR(photoCaptureButtonColor,    "#707070", "#ffffff")
    DECLARE_beeCopter_NONTHEMED_COLOR(videoCaptureButtonColor,    "#f89a9e", "#f32836")

    // Colors not affecting by theming or enable/disable
    DECLARE_beeCopter_SINGLE_COLOR(mapWidgetBorderLight,          "#ffffff")
    DECLARE_beeCopter_SINGLE_COLOR(mapWidgetBorderDark,           "#000000")
    DECLARE_beeCopter_SINGLE_COLOR(mapMissionTrajectory,          "#be781c")
    DECLARE_beeCopter_SINGLE_COLOR(surveyPolygonInterior,         "green")
    DECLARE_beeCopter_SINGLE_COLOR(surveyPolygonTerrainCollision, "red")

}

void beeCopterPalette::setColorGroupEnabled(bool enabled)
{
    _colorGroupEnabled = enabled;
    emit paletteChanged();
}

void beeCopterPalette::setGlobalTheme(Theme newTheme)
{
    // Mobile build does not have themes
    if (_theme != newTheme) {
        _theme = newTheme;
        _signalPaletteChangeToAll();
    }
}

void beeCopterPalette::_signalPaletteChangeToAll()
{
    // Notify all objects of the new theme
    for (beeCopterPalette *palette : std::as_const(_paletteObjects)) {
        palette->_signalPaletteChanged();
    }
}

void beeCopterPalette::_signalPaletteChanged()
{
    emit paletteChanged();
}
