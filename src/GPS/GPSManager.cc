#include "GPSManager.h"
#include "GPSRtk.h"
#include "beeCopterLoggingCategory.h"

#include <QtCore/QApplicationStatic>

beeCopter_LOGGING_CATEGORY(GPSManagerLog, "GPS.GPSManager")

Q_APPLICATION_STATIC(GPSManager, _gpsManager);

GPSManager::GPSManager(QObject *parent)
    : QObject(parent)
    , _gpsRtk(new GPSRtk(this))
{
    // qCDebug(GPSManagerLog) << Q_FUNC_INFO << this;
}

GPSManager::~GPSManager()
{
    // qCDebug(GPSManagerLog) << Q_FUNC_INFO << this;
}

GPSManager *GPSManager::instance()
{
    return _gpsManager();
}
