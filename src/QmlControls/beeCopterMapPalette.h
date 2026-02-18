#pragma once

#include <QtCore/QObject>
#include <QtGui/QColor>
#include <QtQmlIntegration/QtQmlIntegration>

/*!
 beeCopterMapPalette is a variant of beeCopterPalette which is used to hold colors used for display over
 the map control. Since the coloring of a satellite map differs greatly from the coloring of
 a street map you need to be able to switch between sets of color based on map type.

 Usage:

         1.0

        FlightMap {
            id:             map
            anchors.fill:   parent

            beeCopterMapPalette { id: mapPal: lightColors: map.isSatelliteMap }

            beeCopterLabel {
                text:   "Text over map"
                color:  mapPal.text
            }
        }
**/

class beeCopterMapPalette : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(bool lightColors READ lightColors WRITE setLightColors NOTIFY paletteChanged)

    Q_PROPERTY(QColor text          READ text          NOTIFY paletteChanged)
    Q_PROPERTY(QColor textOutline   READ textOutline   NOTIFY paletteChanged)

public:
    beeCopterMapPalette(QObject* parent = nullptr);

    /// Text color
    QColor text(void)           const { return _text[_lightColors ? 0 : 1]; }
    QColor textOutline(void)    const { return _textOutline[_lightColors ? 0 : 1]; }

    bool lightColors(void) const { return _lightColors; }
    void setLightColors(bool lightColors);

signals:
    void paletteChanged(void);
    void lightColorsChanged(bool lightColors);

private:
    bool _lightColors = false;

    static const int _cColorGroups = 2;

    static QColor _text[_cColorGroups];
    static QColor _textOutline[_cColorGroups];
};
