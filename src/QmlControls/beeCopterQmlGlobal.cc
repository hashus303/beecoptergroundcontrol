#include "beeCopterQmlGlobal.h"

#include "beeCopterApplication.h"
#include "beeCopterCorePlugin.h"
#include "LinkManager.h"
#include "MAVLinkProtocol.h"
#include "FirmwarePluginManager.h"
#include "AppSettings.h"
#include "FlightMapSettings.h"
#include "SettingsManager.h"
#include "PositionManager.h"
#include "beeCopterMapEngineManager.h"
#include "ADSBVehicleManager.h"
#include "MissionCommandTree.h"
#include "VideoManager.h"
#include "MultiVehicleManager.h"
#include "beeCopterLoggingCategory.h"
#ifndef beeCopter_NO_SERIAL_LINK
#include "GPSManager.h"
#include "GPSRtk.h"
#endif
#ifdef QT_DEBUG
#include "MockLink.h"
#endif

#include <QtCore/QSettings>
#include <QtCore/QLineF>

beeCopter_LOGGING_CATEGORY(GuidedActionsControllerLog, "QMLControls.GuidedActionsController")

QGeoCoordinate beeCopterQmlGlobal::_coord = QGeoCoordinate(0.0,0.0);
double beeCopterQmlGlobal::_zoom = 2;

beeCopterQmlGlobal::beeCopterQmlGlobal(QObject *parent)
    : QObject(parent)
    , _mapEngineManager(beeCopterMapEngineManager::instance())
    , _adsbVehicleManager(ADSBVehicleManager::instance())
    , _beeCopterPositionManager(beeCopterPositionManager::instance())
    , _missionCommandTree(MissionCommandTree::instance())
    , _videoManager(VideoManager::instance())
    , _linkManager(LinkManager::instance())
    , _multiVehicleManager(MultiVehicleManager::instance())
    , _settingsManager(SettingsManager::instance())
    , _corePlugin(beeCopterCorePlugin::instance())
    , _globalPalette(new beeCopterPalette(this))
#ifndef beeCopter_NO_SERIAL_LINK
    , _gpsRtkFactGroup(GPSManager::instance()->gpsRtk()->gpsRtkFactGroup())
#endif
{
    // We clear the parent on this object since we run into shutdown problems caused by hybrid qml app. Instead we let it leak on shutdown.
    // setParent(nullptr);

    // Load last coordinates and zoom from config file
    QSettings settings;
    settings.beginGroup(_flightMapPositionSettingsGroup);
    _coord.setLatitude(settings.value(_flightMapPositionLatitudeSettingsKey,    _coord.latitude()).toDouble());
    _coord.setLongitude(settings.value(_flightMapPositionLongitudeSettingsKey,  _coord.longitude()).toDouble());
    _zoom = settings.value(_flightMapZoomSettingsKey, _zoom).toDouble();
    _flightMapPositionSettledTimer.setSingleShot(true);
    _flightMapPositionSettledTimer.setInterval(1000);
    (void) connect(&_flightMapPositionSettledTimer, &QTimer::timeout, this, []() {
        // When they settle, save flightMapPosition and Zoom to the config file
        QSettings settingsInner;
        settingsInner.beginGroup(_flightMapPositionSettingsGroup);
        settingsInner.setValue(_flightMapPositionLatitudeSettingsKey, _coord.latitude());
        settingsInner.setValue(_flightMapPositionLongitudeSettingsKey, _coord.longitude());
        settingsInner.setValue(_flightMapZoomSettingsKey, _zoom);
    });
    connect(this, &beeCopterQmlGlobal::flightMapPositionChanged, this, [this](QGeoCoordinate){
        if (!_flightMapPositionSettledTimer.isActive()) {
            _flightMapPositionSettledTimer.start();
        }
    });
    connect(this, &beeCopterQmlGlobal::flightMapZoomChanged, this, [this](double){
        if (!_flightMapPositionSettledTimer.isActive()) {
            _flightMapPositionSettledTimer.start();
        }
    });
}

beeCopterQmlGlobal::~beeCopterQmlGlobal()
{
}

void beeCopterQmlGlobal::saveGlobalSetting (const QString& key, const QString& value)
{
    QSettings settings;
    settings.beginGroup(kQmlGlobalKeyName);
    settings.setValue(key, value);
}

QString beeCopterQmlGlobal::loadGlobalSetting (const QString& key, const QString& defaultValue)
{
    QSettings settings;
    settings.beginGroup(kQmlGlobalKeyName);
    return settings.value(key, defaultValue).toString();
}

void beeCopterQmlGlobal::saveBoolGlobalSetting (const QString& key, bool value)
{
    QSettings settings;
    settings.beginGroup(kQmlGlobalKeyName);
    settings.setValue(key, value);
}

bool beeCopterQmlGlobal::loadBoolGlobalSetting (const QString& key, bool defaultValue)
{
    QSettings settings;
    settings.beginGroup(kQmlGlobalKeyName);
    return settings.value(key, defaultValue).toBool();
}

void beeCopterQmlGlobal::startPX4MockLink(bool sendStatusText, bool enableCamera)
{
#ifdef QT_DEBUG
    MockLink::startPX4MockLink(sendStatusText, enableCamera);
#else
    Q_UNUSED(sendStatusText);
    Q_UNUSED(enableCamera);
#endif
}

void beeCopterQmlGlobal::startGenericMockLink(bool sendStatusText, bool enableCamera)
{
#ifdef QT_DEBUG
    MockLink::startGenericMockLink(sendStatusText, enableCamera);
#else
    Q_UNUSED(sendStatusText);
    Q_UNUSED(enableCamera);
#endif
}

void beeCopterQmlGlobal::startAPMArduCopterMockLink(bool sendStatusText, bool enableCamera)
{
#ifdef QT_DEBUG
    MockLink::startAPMArduCopterMockLink(sendStatusText, enableCamera);
#else
    Q_UNUSED(sendStatusText);
    Q_UNUSED(enableCamera);
#endif
}

void beeCopterQmlGlobal::startAPMArduPlaneMockLink(bool sendStatusText, bool enableCamera)
{
#ifdef QT_DEBUG
    MockLink::startAPMArduPlaneMockLink(sendStatusText, enableCamera);
#else
    Q_UNUSED(sendStatusText);
    Q_UNUSED(enableCamera);
#endif
}

void beeCopterQmlGlobal::startAPMArduSubMockLink(bool sendStatusText, bool enableCamera)
{
#ifdef QT_DEBUG
    MockLink::startAPMArduSubMockLink(sendStatusText, enableCamera);
#else
    Q_UNUSED(sendStatusText);
    Q_UNUSED(enableCamera);
#endif
}

void beeCopterQmlGlobal::startAPMArduRoverMockLink(bool sendStatusText, bool enableCamera)
{
#ifdef QT_DEBUG
    MockLink::startAPMArduRoverMockLink(sendStatusText, enableCamera);
#else
    Q_UNUSED(sendStatusText);
    Q_UNUSED(enableCamera);
#endif
}

void beeCopterQmlGlobal::stopOneMockLink(void)
{
#ifdef QT_DEBUG
    QList<SharedLinkInterfacePtr> sharedLinks = LinkManager::instance()->links();

    for (int i=0; i<sharedLinks.count(); i++) {
        LinkInterface* link = sharedLinks[i].get();
        MockLink* mockLink = qobject_cast<MockLink*>(link);
        if (mockLink) {
            mockLink->disconnect();
            return;
        }
    }
#endif
}

bool beeCopterQmlGlobal::singleFirmwareSupport(void)
{
    return FirmwarePluginManager::instance()->supportedFirmwareClasses().count() == 1;
}

bool beeCopterQmlGlobal::singleVehicleSupport(void)
{
    if (singleFirmwareSupport()) {
        return FirmwarePluginManager::instance()->supportedVehicleClasses(FirmwarePluginManager::instance()->supportedFirmwareClasses()[0]).count() == 1;
    }

    return false;
}

bool beeCopterQmlGlobal::px4ProFirmwareSupported()
{
    return FirmwarePluginManager::instance()->supportedFirmwareClasses().contains(beeCopterMAVLink::FirmwareClassPX4);
}

bool beeCopterQmlGlobal::apmFirmwareSupported()
{
    return FirmwarePluginManager::instance()->supportedFirmwareClasses().contains(beeCopterMAVLink::FirmwareClassArduPilot);
}

bool beeCopterQmlGlobal::linesIntersect(QPointF line1A, QPointF line1B, QPointF line2A, QPointF line2B)
{
    QPointF intersectPoint;

    auto intersect = QLineF(line1A, line1B).intersects(QLineF(line2A, line2B), &intersectPoint);

    return  intersect == QLineF::BoundedIntersection &&
            intersectPoint != line1A && intersectPoint != line1B;
}

void beeCopterQmlGlobal::setFlightMapPosition(QGeoCoordinate& coordinate)
{
    if (coordinate != flightMapPosition()) {
        _coord.setLatitude(coordinate.latitude());
        _coord.setLongitude(coordinate.longitude());
        emit flightMapPositionChanged(coordinate);
    }
}

void beeCopterQmlGlobal::setFlightMapZoom(double zoom)
{
    if (zoom != flightMapZoom()) {
        _zoom = zoom;
        emit flightMapZoomChanged(zoom);
    }
}

QString beeCopterQmlGlobal::beeCopterVersion(void)
{
    QString versionStr = QCoreApplication::applicationVersion();
    if(QSysInfo::buildAbi().contains("32"))
    {
        versionStr += QStringLiteral(" %1").arg(tr("32 bit"));
    }
    else if(QSysInfo::buildAbi().contains("64"))
    {
        versionStr += QStringLiteral(" %1").arg(tr("64 bit"));
    }
    return versionStr;
}

QString beeCopterQmlGlobal::altitudeModeExtraUnits(AltMode altMode)
{
    switch (altMode) {
    case AltitudeModeNone:
        return QString();
    case AltitudeModeRelative:
        // Showing (Rel) all the time ends up being too noisy
        return QString();
    case AltitudeModeAbsolute:
        return tr("(AMSL)");
    case AltitudeModeCalcAboveTerrain:
        return tr("(TerrC)");
    case AltitudeModeTerrainFrame:
        return tr("(Terr)");
    case AltitudeModeMixed:
        qWarning() << "Internal Error: beeCopterQmlGlobal::altitudeModeExtraUnits called with altMode == AltitudeModeMixed";
        return QString();
    }

    // Should never get here but makes some compilers happy
    return QString();
}

QString beeCopterQmlGlobal::altitudeModeShortDescription(AltMode altMode)
{
    switch (altMode) {
    case AltitudeModeNone:
        return QString();
    case AltitudeModeRelative:
        return tr("Relative");
    case AltitudeModeAbsolute:
        return tr("Absolute");
    case AltitudeModeCalcAboveTerrain:
        return tr("TerrainC");
    case AltitudeModeTerrainFrame:
        return tr("Terrain");
    case AltitudeModeMixed:
        return tr("Waypoint");
    }

    // Should never get here but makes some compilers happy
    return QString();
}

QString beeCopterQmlGlobal::elevationProviderName()
{
    return _settingsManager->flightMapSettings()->elevationMapProvider()->rawValue().toString();
}

QString beeCopterQmlGlobal::elevationProviderNotice()
{
    return _settingsManager->flightMapSettings()->elevationMapProvider()->rawValue().toString();
}

QString beeCopterQmlGlobal::parameterFileExtension() const
{
    return AppSettings::parameterFileExtension;
}

QString beeCopterQmlGlobal::telemetryFileExtension() const
{
    return AppSettings::telemetryFileExtension;
}

QString beeCopterQmlGlobal::appName()
{
    return QCoreApplication::applicationName();
}

void beeCopterQmlGlobal::deleteAllSettingsNextBoot()
{
    beeCopterApplication::deleteAllSettingsNextBoot();
}

void beeCopterQmlGlobal::clearDeleteAllSettingsNextBoot()
{
    beeCopterApplication::clearDeleteAllSettingsNextBoot();
}

QmlObjectListModel *beeCopterQmlGlobal::treeLoggingCategoriesModel()
{
    return beeCopterLoggingCategoryManager::instance()->treeCategoryModel();
}

QmlObjectListModel *beeCopterQmlGlobal::flatLoggingCategoriesModel()
{
    return beeCopterLoggingCategoryManager::instance()->flatCategoryModel();
}

void beeCopterQmlGlobal::setCategoryLoggingOn(const QString &category, bool enable)
{
    beeCopterLoggingCategoryManager::instance()->setCategoryLoggingOn(category, enable);
}

bool beeCopterQmlGlobal::categoryLoggingOn(const QString &category)
{
    return beeCopterLoggingCategoryManager::categoryLoggingOn(category);
}

void beeCopterQmlGlobal::disableAllLoggingCategories()
{
    beeCopterLoggingCategoryManager::instance()->disableAllCategories();
}
