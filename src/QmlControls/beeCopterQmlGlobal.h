#pragma once

#include <QtCore/QLoggingCategory>
#include <QtCore/QPointF>
#include <QtCore/QTimer>
#include <QtPositioning/QGeoCoordinate>
#include <QtQmlIntegration/QtQmlIntegration>

#include "QmlUnitsConversion.h"
#include "beeCopter_version.h"

Q_DECLARE_LOGGING_CATEGORY(GuidedActionsControllerLog)

class ADSBVehicleManager;
class FactGroup;
class LinkManager;
class MissionCommandTree;
class MultiVehicleManager;
class beeCopterCorePlugin;
class beeCopterMapEngineManager;
class beeCopterPalette;
class beeCopterPositionManager;
class SettingsManager;
class VideoManager;
class QmlObjectListModel;

Q_MOC_INCLUDE("ADSBVehicleManager.h")
Q_MOC_INCLUDE("FactGroup.h")
Q_MOC_INCLUDE("LinkManager.h")
Q_MOC_INCLUDE("MissionCommandTree.h")
Q_MOC_INCLUDE("MultiVehicleManager.h")
Q_MOC_INCLUDE("beeCopterCorePlugin.h")
Q_MOC_INCLUDE("beeCopterMapEngineManager.h")
Q_MOC_INCLUDE("beeCopterPalette.h")
Q_MOC_INCLUDE("PositionManager.h")
Q_MOC_INCLUDE("SettingsManager.h")
Q_MOC_INCLUDE("VideoManager.h")

class beeCopterQmlGlobal : public QObject
{
    Q_OBJECT
    QML_NAMED_ELEMENT(beeCopter)
    QML_SINGLETON

public:
    explicit beeCopterQmlGlobal(QObject *parent = nullptr);
    ~beeCopterQmlGlobal();

    enum AltMode {
        AltitudeModeMixed,              // Used by global altitude mode for mission planning
        AltitudeModeRelative,           // MAV_FRAME_GLOBAL_RELATIVE_ALT
        AltitudeModeAbsolute,           // MAV_FRAME_GLOBAL
        AltitudeModeCalcAboveTerrain,   // Absolute altitude above terrain calculated from terrain data
        AltitudeModeTerrainFrame,       // MAV_FRAME_GLOBAL_TERRAIN_ALT
        AltitudeModeNone,               // Being used as distance value unrelated to ground (for example distance to structure)
    };
    Q_ENUM(AltMode)

    Q_PROPERTY(QString              appName                 READ    appName                 CONSTANT)
    Q_PROPERTY(LinkManager*         linkManager             READ    linkManager             CONSTANT)
    Q_PROPERTY(MultiVehicleManager* multiVehicleManager     READ    multiVehicleManager     CONSTANT)
    Q_PROPERTY(beeCopterMapEngineManager* mapEngineManager        READ    mapEngineManager        CONSTANT)
    Q_PROPERTY(beeCopterPositionManager*  beeCopterPositionManger       READ    beeCopterPositionManger       CONSTANT)
    Q_PROPERTY(VideoManager*        videoManager            READ    videoManager            CONSTANT)
    Q_PROPERTY(SettingsManager*     settingsManager         READ    settingsManager         CONSTANT)
    Q_PROPERTY(ADSBVehicleManager*  adsbVehicleManager      READ    adsbVehicleManager      CONSTANT)
    Q_PROPERTY(beeCopterCorePlugin*       corePlugin              READ    corePlugin              CONSTANT)
    Q_PROPERTY(MissionCommandTree*  missionCommandTree      READ    missionCommandTree      CONSTANT)
#ifndef beeCopter_NO_SERIAL_LINK
    Q_PROPERTY(FactGroup*           gpsRtk                  READ    gpsRtkFactGroup         CONSTANT)
#endif
    Q_PROPERTY(beeCopterPalette*          globalPalette           MEMBER  _globalPalette          CONSTANT)   ///< This palette will always return enabled colors
    Q_PROPERTY(QmlUnitsConversion*  unitsConversion         READ    unitsConversion         CONSTANT)
    Q_PROPERTY(bool                 singleFirmwareSupport   READ    singleFirmwareSupport   CONSTANT)
    Q_PROPERTY(bool                 singleVehicleSupport    READ    singleVehicleSupport    CONSTANT)
    Q_PROPERTY(bool                 px4ProFirmwareSupported READ    px4ProFirmwareSupported CONSTANT)
    Q_PROPERTY(int                  apmFirmwareSupported    READ    apmFirmwareSupported    CONSTANT)
    Q_PROPERTY(QGeoCoordinate       flightMapPosition       READ    flightMapPosition       WRITE setFlightMapPosition  NOTIFY flightMapPositionChanged)
    Q_PROPERTY(double               flightMapZoom           READ    flightMapZoom           WRITE setFlightMapZoom      NOTIFY flightMapZoomChanged)
    Q_PROPERTY(double               flightMapInitialZoom    MEMBER  _flightMapInitialZoom   CONSTANT)   ///< Zoom level to use when either gcs or vehicle shows up for first time

    Q_PROPERTY(QString  parameterFileExtension  READ parameterFileExtension CONSTANT)
    Q_PROPERTY(QString  telemetryFileExtension  READ telemetryFileExtension CONSTANT)

    Q_PROPERTY(QString beeCopterVersion       READ beeCopterVersion         CONSTANT)
    Q_PROPERTY(QString beeCopterAppDate       READ beeCopterAppDate         CONSTANT)
    Q_PROPERTY(bool    beeCopterDailyBuild    READ beeCopterDailyBuild      CONSTANT)

    Q_PROPERTY(qreal zOrderTopMost              READ zOrderTopMost              CONSTANT) ///< z order for top most items, toolbar, main window sub view
    Q_PROPERTY(qreal zOrderWidgets              READ zOrderWidgets              CONSTANT) ///< z order value to widgets, for example: zoom controls, hud widgetss
    Q_PROPERTY(qreal zOrderMapItems             READ zOrderMapItems             CONSTANT)
    Q_PROPERTY(qreal zOrderVehicles             READ zOrderVehicles             CONSTANT)
    Q_PROPERTY(qreal zOrderWaypointIndicators   READ zOrderWaypointIndicators   CONSTANT)
    Q_PROPERTY(qreal zOrderTrajectoryLines      READ zOrderTrajectoryLines      CONSTANT)
    Q_PROPERTY(qreal zOrderWaypointLines        READ zOrderWaypointLines        CONSTANT)
    Q_PROPERTY(bool     hasAPMSupport           READ hasAPMSupport              CONSTANT)
    Q_PROPERTY(bool     hasMAVLinkInspector     READ hasMAVLinkInspector        CONSTANT)


    //-------------------------------------------------------------------------
    // Elevation Provider
    Q_PROPERTY(QString  elevationProviderName           READ elevationProviderName              CONSTANT)
    Q_PROPERTY(QString  elevationProviderNotice         READ elevationProviderNotice            CONSTANT)

    Q_INVOKABLE void    saveGlobalSetting       (const QString& key, const QString& value);
    Q_INVOKABLE QString loadGlobalSetting       (const QString& key, const QString& defaultValue);
    Q_INVOKABLE void    saveBoolGlobalSetting   (const QString& key, bool value);
    Q_INVOKABLE bool    loadBoolGlobalSetting   (const QString& key, bool defaultValue);

    Q_INVOKABLE static void deleteAllSettingsNextBoot();
    Q_INVOKABLE static void clearDeleteAllSettingsNextBoot();

    Q_INVOKABLE void    startPX4MockLink            (bool sendStatusText, bool enableCamera);
    Q_INVOKABLE void    startGenericMockLink        (bool sendStatusText, bool enableCamera);
    Q_INVOKABLE void    startAPMArduCopterMockLink  (bool sendStatusText, bool enableCamera);
    Q_INVOKABLE void    startAPMArduPlaneMockLink   (bool sendStatusText, bool enableCamera);
    Q_INVOKABLE void    startAPMArduSubMockLink     (bool sendStatusText, bool enableCamera);
    Q_INVOKABLE void    startAPMArduRoverMockLink   (bool sendStatusText, bool enableCamera);
    Q_INVOKABLE void    stopOneMockLink             (void);

    /// Returns the hierarchical list of available logging category names.
    Q_INVOKABLE static QmlObjectListModel *treeLoggingCategoriesModel();

    /// Returns the flat list of available logging category names.
    Q_INVOKABLE static QmlObjectListModel *flatLoggingCategoriesModel();

    /// Turns on/off logging for the specified category. State is saved in app settings.
    Q_INVOKABLE static void setCategoryLoggingOn(const QString &category, bool enable);

    /// Returns true if logging is turned on for the specified category.
    Q_INVOKABLE static bool categoryLoggingOn(const QString &category);

    Q_INVOKABLE static void disableAllLoggingCategories();

    Q_INVOKABLE bool linesIntersect(QPointF xLine1, QPointF yLine1, QPointF xLine2, QPointF yLine2);

    Q_INVOKABLE QString altitudeModeExtraUnits(AltMode altMode);        ///< String shown in the FactTextField.extraUnits ui
    Q_INVOKABLE QString altitudeModeShortDescription(AltMode altMode);  ///< String shown when a user needs to select an altitude mode

    // Property accessors

    static QString appName();
    LinkManager*            linkManager         ()  { return _linkManager; }
    MultiVehicleManager*    multiVehicleManager ()  { return _multiVehicleManager; }
    beeCopterMapEngineManager*    mapEngineManager    ()  { return _mapEngineManager; }
    beeCopterPositionManager*     beeCopterPositionManger   ()  { return _beeCopterPositionManager; }
    MissionCommandTree*     missionCommandTree  ()  { return _missionCommandTree; }
    VideoManager*           videoManager        ()  { return _videoManager; }
    beeCopterCorePlugin*          corePlugin          ()  { return _corePlugin; }
    SettingsManager*        settingsManager     ()  { return _settingsManager; }
#ifndef beeCopter_NO_SERIAL_LINK
    FactGroup*              gpsRtkFactGroup     ()  { return _gpsRtkFactGroup; }
#endif
    ADSBVehicleManager*     adsbVehicleManager  ()  { return _adsbVehicleManager; }
    QmlUnitsConversion*     unitsConversion     ()  { return &_unitsConversion; }
    static QGeoCoordinate   flightMapPosition   ()  { return _coord; }
    static double           flightMapZoom       ()  { return _zoom; }

    qreal zOrderTopMost             () { return 1000; }
    qreal zOrderWidgets             () { return 100; }
    qreal zOrderMapItems            () { return 50; }
    qreal zOrderWaypointIndicators  () { return 50; }
    qreal zOrderVehicles            () { return 49; }
    qreal zOrderTrajectoryLines     () { return 48; }
    qreal zOrderWaypointLines       () { return 47; }

#if defined(beeCopter_NO_ARDUPILOT_DIALECT)
    bool    hasAPMSupport           () { return false; }
#else
    bool    hasAPMSupport           () { return true; }
#endif

#if defined(beeCopter_DISABLE_MAVLINK_INSPECTOR)
    bool    hasMAVLinkInspector     () { return false; }
#else
    bool    hasMAVLinkInspector     () { return true; }
#endif

    QString elevationProviderName   ();
    QString elevationProviderNotice ();

    bool    singleFirmwareSupport   ();
    bool    singleVehicleSupport    ();
    bool    px4ProFirmwareSupported ();
    bool    apmFirmwareSupported    ();

    void    setFlightMapPosition        (QGeoCoordinate& coordinate);
    void    setFlightMapZoom            (double zoom);

    QString parameterFileExtension  (void) const;
    QString telemetryFileExtension  (void) const;

    static QString beeCopterVersion();
    static QString beeCopterAppDate() { return beeCopter_APP_DATE; }
#ifdef beeCopter_DAILY_BUILD
    static bool beeCopterDailyBuild() { return true; }
#else
    static bool beeCopterDailyBuild() { return false; }
#endif

signals:
    void isMultiplexingEnabledChanged   (bool enabled);
    void mavlinkSystemIDChanged         (int id);
    void flightMapPositionChanged       (QGeoCoordinate flightMapPosition);
    void flightMapZoomChanged           (double flightMapZoom);

private:
    beeCopterMapEngineManager*    _mapEngineManager       = nullptr;
    ADSBVehicleManager*     _adsbVehicleManager     = nullptr;
    beeCopterPositionManager*     _beeCopterPositionManager     = nullptr;
    MissionCommandTree*     _missionCommandTree     = nullptr;
    VideoManager*           _videoManager           = nullptr;
    LinkManager*            _linkManager            = nullptr;
    MultiVehicleManager*    _multiVehicleManager    = nullptr;
    SettingsManager*        _settingsManager        = nullptr;
    beeCopterCorePlugin*          _corePlugin             = nullptr;
    beeCopterPalette*             _globalPalette          = nullptr;
#ifndef beeCopter_NO_SERIAL_LINK
    FactGroup*              _gpsRtkFactGroup        = nullptr;
#endif

    double                  _flightMapInitialZoom   = 17.0;
    QmlUnitsConversion      _unitsConversion;

    QStringList             _altitudeModeEnumString;

    static QGeoCoordinate   _coord;
    static double           _zoom;
    QTimer                  _flightMapPositionSettledTimer;

    static constexpr const char* kQmlGlobalKeyName = "beeCopterQml";

    static constexpr const char* _flightMapPositionSettingsGroup =          "FlightMapPosition";
    static constexpr const char* _flightMapPositionLatitudeSettingsKey =    "Latitude";
    static constexpr const char* _flightMapPositionLongitudeSettingsKey =   "Longitude";
    static constexpr const char* _flightMapZoomSettingsKey =                "FlightMapZoom";
};
