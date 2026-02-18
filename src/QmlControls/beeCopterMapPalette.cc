#include "beeCopterMapPalette.h"

QColor beeCopterMapPalette::_text         [beeCopterMapPalette::_cColorGroups] = { QColor(255,255,255),     QColor(0,0,0) };
QColor beeCopterMapPalette::_textOutline  [beeCopterMapPalette::_cColorGroups] = { QColor(0,0,0,192),       QColor(255,255,255,192) };

beeCopterMapPalette::beeCopterMapPalette(QObject* parent) :
    QObject(parent)
{

}

void beeCopterMapPalette::setLightColors(bool lightColors)
{
    if ( _lightColors != lightColors) {
        _lightColors = lightColors;
        emit paletteChanged();
    }
}
