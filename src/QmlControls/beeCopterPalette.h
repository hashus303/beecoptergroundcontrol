#pragma once

#include <QtCore/QObject>
#include <QtGui/QColor>
#include <QtCore/QMap>
#include <QtQmlIntegration/QtQmlIntegration>

#define DECLARE_beeCopter_COLOR(name, lightDisabled, lightEnabled, darkDisabled, darkEnabled) \
    { \
        PaletteColorInfo_t colorInfo = { \
            { QColor(lightDisabled), QColor(lightEnabled) }, \
            { QColor(darkDisabled), QColor(darkEnabled) } \
        }; \
        beeCopterCorePlugin::instance()->paletteOverride(#name, colorInfo); \
        _colorInfoMap[Light][ColorGroupEnabled][QStringLiteral(#name)] = colorInfo[Light][ColorGroupEnabled]; \
        _colorInfoMap[Light][ColorGroupDisabled][QStringLiteral(#name)] = colorInfo[Light][ColorGroupDisabled]; \
        _colorInfoMap[Dark][ColorGroupEnabled][QStringLiteral(#name)] = colorInfo[Dark][ColorGroupEnabled]; \
        _colorInfoMap[Dark][ColorGroupDisabled][QStringLiteral(#name)] = colorInfo[Dark][ColorGroupDisabled]; \
        _colors << #name; \
    }

#define DECLARE_beeCopter_NONTHEMED_COLOR(name, disabledColor, enabledColor) \
    { \
        PaletteColorInfo_t colorInfo = { \
            { QColor(disabledColor), QColor(enabledColor) }, \
            { QColor(disabledColor), QColor(enabledColor) } \
        }; \
        beeCopterCorePlugin::instance()->paletteOverride(#name, colorInfo); \
        _colorInfoMap[Light][ColorGroupEnabled][QStringLiteral(#name)] = colorInfo[Light][ColorGroupEnabled]; \
        _colorInfoMap[Light][ColorGroupDisabled][QStringLiteral(#name)] = colorInfo[Light][ColorGroupDisabled]; \
        _colorInfoMap[Dark][ColorGroupEnabled][QStringLiteral(#name)] = colorInfo[Dark][ColorGroupEnabled]; \
        _colorInfoMap[Dark][ColorGroupDisabled][QStringLiteral(#name)] = colorInfo[Dark][ColorGroupDisabled]; \
        _colors << #name; \
    }

#define DECLARE_beeCopter_SINGLE_COLOR(name, color) \
    { \
        PaletteColorInfo_t colorInfo = { \
            { QColor(color), QColor(color) }, \
            { QColor(color), QColor(color) } \
        }; \
        beeCopterCorePlugin::instance()->paletteOverride(#name, colorInfo); \
        _colorInfoMap[Light][ColorGroupEnabled][QStringLiteral(#name)] = colorInfo[Light][ColorGroupEnabled]; \
        _colorInfoMap[Light][ColorGroupDisabled][QStringLiteral(#name)] = colorInfo[Light][ColorGroupDisabled]; \
        _colorInfoMap[Dark][ColorGroupEnabled][QStringLiteral(#name)] = colorInfo[Dark][ColorGroupEnabled]; \
        _colorInfoMap[Dark][ColorGroupDisabled][QStringLiteral(#name)] = colorInfo[Dark][ColorGroupDisabled]; \
        _colors << #name; \
    }

#define DEFINE_beeCopter_COLOR(NAME, SETNAME) \
    Q_PROPERTY(QColor NAME READ NAME WRITE SETNAME NOTIFY paletteChanged) \
    Q_PROPERTY(QStringList NAME ## Colors READ NAME ## Colors NOTIFY paletteChanged) \
    QColor NAME() const { return _colorInfoMap[_theme][_colorGroupEnabled  ? ColorGroupEnabled : ColorGroupDisabled][QStringLiteral(#NAME)]; } \
    QStringList NAME ## Colors() const { \
        QStringList c; \
        c << _colorInfoMap[Light][ColorGroupEnabled][QStringLiteral(#NAME)].name(QColor::HexRgb); \
        c << _colorInfoMap[Light][ColorGroupDisabled][QStringLiteral(#NAME)].name(QColor::HexRgb); \
        c << _colorInfoMap[Dark][ColorGroupEnabled][QStringLiteral(#NAME)].name(QColor::HexRgb); \
        c << _colorInfoMap[Dark][ColorGroupDisabled][QStringLiteral(#NAME)].name(QColor::HexRgb); \
        return c; \
    } \
    void SETNAME(const QColor& color) { _colorInfoMap[_theme][_colorGroupEnabled  ? ColorGroupEnabled : ColorGroupDisabled][QStringLiteral(#NAME)] = color; _signalPaletteChangeToAll(); }

/*!
 beeCopterPalette is used in QML ui to expose color properties for the beeCopter palette. There are two
 separate palettes in beeCopter, light and dark. The light palette is for outdoor use and the dark
 palette is for indoor use. Each palette also has a set of different colors for enabled and
 disabled states.

 Usage:

         1.0

        Rectangle {
            anchors.fill:   parent
            color:          beeCopterPal.window

            beeCopterPalette { id: beeCopterPal: colorGroupEnabled: enabled }
        }
*/

class beeCopterPalette : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    enum ColorGroup {
        ColorGroupDisabled = 0,
        ColorGroupEnabled,
        cMaxColorGroup
    };

    enum Theme {
        Light = 0,
        Dark,
        cMaxTheme
    };
    Q_ENUM(Theme)

    typedef QColor PaletteColorInfo_t[cMaxTheme][cMaxColorGroup];

    Q_PROPERTY(Theme        globalTheme         READ globalTheme        WRITE setGlobalTheme        NOTIFY paletteChanged)
    Q_PROPERTY(bool         colorGroupEnabled   READ colorGroupEnabled  WRITE setColorGroupEnabled  NOTIFY paletteChanged)
    Q_PROPERTY(QStringList  colors              READ colors             CONSTANT)

    DEFINE_beeCopter_COLOR(window,                        setWindow)
    DEFINE_beeCopter_COLOR(windowTransparent,             setWindowTransparent)
    DEFINE_beeCopter_COLOR(windowShadeLight,              setWindowShadeLight)
    DEFINE_beeCopter_COLOR(windowShade,                   setWindowShade)
    DEFINE_beeCopter_COLOR(windowShadeDark,               setWindowShadeDark)
    DEFINE_beeCopter_COLOR(text,                          setText)
    DEFINE_beeCopter_COLOR(windowTransparentText,         setWindowTransparentText)
    DEFINE_beeCopter_COLOR(warningText,                   setWarningText)
    DEFINE_beeCopter_COLOR(button,                        setButton)
    DEFINE_beeCopter_COLOR(buttonBorder,                  setButtonBorder)
    DEFINE_beeCopter_COLOR(buttonText,                    setButtonText)
    DEFINE_beeCopter_COLOR(buttonHighlight,               setButtonHighlight)
    DEFINE_beeCopter_COLOR(buttonHighlightText,           setButtonHighlightText)
    DEFINE_beeCopter_COLOR(primaryButton,                 setPrimaryButton)
    DEFINE_beeCopter_COLOR(primaryButtonText,             setPrimaryButtonText)
    DEFINE_beeCopter_COLOR(textField,                     setTextField)
    DEFINE_beeCopter_COLOR(textFieldText,                 setTextFieldText)
    DEFINE_beeCopter_COLOR(mapButton,                     setMapButton)
    DEFINE_beeCopter_COLOR(mapButtonHighlight,            setMapButtonHighlight)
    DEFINE_beeCopter_COLOR(mapIndicator,                  setMapIndicator)
    DEFINE_beeCopter_COLOR(mapIndicatorChild,             setMapIndicatorChild)
    DEFINE_beeCopter_COLOR(mapWidgetBorderLight,          setMapWidgetBorderLight)
    DEFINE_beeCopter_COLOR(mapWidgetBorderDark,           setMapWidgetBorderDark)
    DEFINE_beeCopter_COLOR(mapMissionTrajectory,          setMapMissionTrajectory)
    DEFINE_beeCopter_COLOR(brandingPurple,                setBrandingPurple)
    DEFINE_beeCopter_COLOR(brandingBlue,                  setBrandingBlue)
    DEFINE_beeCopter_COLOR(colorGreen,                    setColorGreen)
    DEFINE_beeCopter_COLOR(colorYellow,                   setColorYellow)
    DEFINE_beeCopter_COLOR(colorYellowGreen,              setColorYellowGreen)
    DEFINE_beeCopter_COLOR(colorOrange,                   setColorOrange)
    DEFINE_beeCopter_COLOR(colorRed,                      setColorRed)
    DEFINE_beeCopter_COLOR(colorGrey,                     setColorGrey)
    DEFINE_beeCopter_COLOR(colorBlue,                     setColorBlue)
    DEFINE_beeCopter_COLOR(alertBackground,               setAlertBackground)
    DEFINE_beeCopter_COLOR(alertBorder,                   setAlertBorder)
    DEFINE_beeCopter_COLOR(alertText,                     setAlertText)
    DEFINE_beeCopter_COLOR(missionItemEditor,             setMissionItemEditor)
    DEFINE_beeCopter_COLOR(statusFailedText,              setstatusFailedText)
    DEFINE_beeCopter_COLOR(statusPassedText,              setstatusPassedText)
    DEFINE_beeCopter_COLOR(statusPendingText,             setstatusPendingText)
    DEFINE_beeCopter_COLOR(surveyPolygonInterior,         setSurveyPolygonInterior)
    DEFINE_beeCopter_COLOR(surveyPolygonTerrainCollision, setSurveyPolygonTerrainCollision)
    DEFINE_beeCopter_COLOR(toolbarBackground,             setToolbarBackground)
    DEFINE_beeCopter_COLOR(toolStripFGColor,              setToolStripFGColor)
    DEFINE_beeCopter_COLOR(toolStripHoverColor,           setToolStripHoverColor)
    DEFINE_beeCopter_COLOR(groupBorder,                   setGroupBorder)
    DEFINE_beeCopter_COLOR(photoCaptureButtonColor,       setPhotoCaptureButtonColor)
    DEFINE_beeCopter_COLOR(videoCaptureButtonColor,       setVideoCaptureButtonColor)

     beeCopterPalette(QObject* parent = nullptr);
    ~beeCopterPalette();

    QStringList colors                      () const { return _colors; }
    bool        colorGroupEnabled           () const { return _colorGroupEnabled; }
    void        setColorGroupEnabled        (bool enabled);

    static Theme    globalTheme             () { return _theme; }
    static void     setGlobalTheme          (Theme newTheme);

signals:
    void paletteChanged ();

private:
    static void _buildMap                   ();
    static void _signalPaletteChangeToAll   ();
    void        _signalPaletteChanged       ();
    void        _themeChanged               ();

    static Theme                _theme;             ///< There is a single theme for all palettes
    bool                        _colorGroupEnabled; ///< Currently selected ColorGroup. true: enabled, false: disabled
    static QStringList          _colors;

    static QMap<int, QMap<int, QMap<QString, QColor>>> _colorInfoMap;   // theme -> colorGroup -> color name -> color
    static QList<beeCopterPalette*> _paletteObjects;    ///< List of all active beeCopterPalette objects
};
