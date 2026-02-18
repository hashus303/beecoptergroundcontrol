#include "DeviceInfo.h"
#include "beeCopterLoggingCategory.h"

#include <QtCore/QApplicationStatic>

beeCopter_LOGGING_CATEGORY(beeCopterDeviceInfoLog, "Utilities.beeCopterDeviceInfo")

namespace beeCopterDeviceInfo
{

////////////////////////////////////////////////////////////////////

Q_APPLICATION_STATIC(beeCopterAmbientTemperature, s_ambientTemperature);

beeCopterAmbientTemperature* beeCopterAmbientTemperature::instance()
{
    return s_ambientTemperature();
}

beeCopterAmbientTemperature::beeCopterAmbientTemperature(QObject* parent)
    : QObject(parent)
    , _ambientTemperature(new QAmbientTemperatureSensor(this))
    , _ambientTemperatureFilter(std::make_shared<beeCopterAmbientTemperatureFilter>())
{
    connect(_ambientTemperature, &QAmbientTemperatureSensor::sensorError, this, [](int error) {
        qCWarning(beeCopterDeviceInfoLog) << Q_FUNC_INFO << "QAmbientTemperature error:" << error;
    });

    if (!init()) {
        qCWarning(beeCopterDeviceInfoLog) << Q_FUNC_INFO << "Error Initializing Ambient Temperature Sensor";
    }

    qCDebug(beeCopterDeviceInfoLog) << Q_FUNC_INFO << this;
}

beeCopterAmbientTemperature::~beeCopterAmbientTemperature()
{
    qCDebug(beeCopterDeviceInfoLog) << Q_FUNC_INFO << this;
}

bool beeCopterAmbientTemperature::init()
{
    _ambientTemperature->addFilter(_ambientTemperatureFilter.get());

    const bool connected = _ambientTemperature->connectToBackend();
    if(!connected) {
        qCWarning(beeCopterDeviceInfoLog) << Q_FUNC_INFO << "Failed to connect to ambient temperature backend";
        return false;
    } else {
        qCDebug(beeCopterDeviceInfoLog) << Q_FUNC_INFO << "Connected to ambient temperature backend:" << _ambientTemperature->identifier();
    }

    if (_ambientTemperature->isFeatureSupported(QSensor::SkipDuplicates)) {
        _ambientTemperature->setSkipDuplicates(true);
    }

    const qrangelist dataRates = _ambientTemperature->availableDataRates();
    if (!dataRates.isEmpty()) {
        qCDebug(beeCopterDeviceInfoLog) << Q_FUNC_INFO << "Available Data Rates:" << dataRates;
        // _ambientTemperature->setDataRate(dataRates.first().first);
        qCDebug(beeCopterDeviceInfoLog) << Q_FUNC_INFO << "Selected Data Rate:" << _ambientTemperature->dataRate();
    }

    const qoutputrangelist outputRanges = _ambientTemperature->outputRanges();
    if (!outputRanges.isEmpty()) {
        // qCDebug(beeCopterDeviceInfoLog) << Q_FUNC_INFO << "Output Ranges:" << outputRanges;
        // _ambientTemperature->setOutputRange(outputRanges.first().first);
        const int outputRangeIndex = _ambientTemperature->outputRange();
        if (outputRangeIndex < outputRanges.size()) {
            const qoutputrange outputRange = outputRanges.at(_ambientTemperature->outputRange());
            qCDebug(beeCopterDeviceInfoLog) << Q_FUNC_INFO << "Selected Output Range:" << outputRange.minimum << outputRange.maximum << outputRange.accuracy;
        }
    }

    _readingChangedConnection = connect(_ambientTemperature, &QAmbientTemperatureSensor::readingChanged, this, [this]() {
        QAmbientTemperatureReading* reading = _ambientTemperature->reading();
        if (!reading) {
            return;
        }

        _temperatureC = reading->temperature();

        emit temperatureUpdated(_temperatureC);
    });

    // _ambientTemperature->setActive(true);
    const bool started = _ambientTemperature->start();
    if (!started) {
        qCWarning(beeCopterDeviceInfoLog) << Q_FUNC_INFO << "Failed to start ambient temperature";
        return false;
    }

    return true;
}

void beeCopterAmbientTemperature::quit()
{
    // _ambientTemperature->setActive(false);
    _ambientTemperature->stop();
    _ambientTemperature->disconnect(_readingChangedConnection);
}

beeCopterAmbientTemperatureFilter::beeCopterAmbientTemperatureFilter()
    : QAmbientTemperatureFilter()
{
    qCDebug(beeCopterDeviceInfoLog) << Q_FUNC_INFO << this;
}

beeCopterAmbientTemperatureFilter::~beeCopterAmbientTemperatureFilter()
{
    qCDebug(beeCopterDeviceInfoLog) << Q_FUNC_INFO << this;
}

bool beeCopterAmbientTemperatureFilter::filter(QAmbientTemperatureReading *reading)
{
    if (!reading) {
        return false;
    }

    const qreal temperature = reading->temperature();
    return ((temperature >= s_minValidTemperatureC) && (temperature <= s_maxValidTemperatureC));
}

////////////////////////////////////////////////////////////////////

Q_APPLICATION_STATIC(beeCopterPressure, s_pressure);

beeCopterPressure* beeCopterPressure::instance()
{
    return s_pressure();
}

beeCopterPressure::beeCopterPressure(QObject* parent)
    : QObject(parent)
    , _pressure(new QPressureSensor(this))
    , _pressureFilter(std::make_shared<beeCopterPressureFilter>())
{
    connect(_pressure, &QPressureSensor::sensorError, this, [](int error) {
        qCWarning(beeCopterDeviceInfoLog) << Q_FUNC_INFO << "QPressure error:" << error;
    });

    if (!init()) {
        qCWarning(beeCopterDeviceInfoLog) << Q_FUNC_INFO << "Error Initializing Pressure Sensor";
    }

    qCDebug(beeCopterDeviceInfoLog) << Q_FUNC_INFO << this;
}

beeCopterPressure::~beeCopterPressure()
{
    qCDebug(beeCopterDeviceInfoLog) << Q_FUNC_INFO << this;
}

bool beeCopterPressure::init()
{
    _pressure->addFilter(_pressureFilter.get());

    const bool connected = _pressure->connectToBackend();
    if(!connected) {
        qCWarning(beeCopterDeviceInfoLog) << Q_FUNC_INFO << "Failed to connect to pressure backend";
        return false;
    } else {
        qCDebug(beeCopterDeviceInfoLog) << Q_FUNC_INFO << "Connected to pressure backend:" << _pressure->identifier();
    }

    if (_pressure->isFeatureSupported(QSensor::SkipDuplicates)) {
        _pressure->setSkipDuplicates(true);
    }

    const qrangelist dataRates = _pressure->availableDataRates();
    if (!dataRates.isEmpty()) {
        qCDebug(beeCopterDeviceInfoLog) << Q_FUNC_INFO << "Available Data Rates:" << dataRates;
        // _pressure->setDataRate(dataRates.first().first);
        qCDebug(beeCopterDeviceInfoLog) << Q_FUNC_INFO << "Selected Data Rate:" << _pressure->dataRate();
    }

    const qoutputrangelist outputRanges = _pressure->outputRanges();
    if (!outputRanges.isEmpty()) {
        // qCDebug(beeCopterDeviceInfoLog) << Q_FUNC_INFO << "Output Ranges:" << outputRanges;
        // _pressure->setOutputRange(outputRanges.first().first);
        const int outputRangeIndex = _pressure->outputRange();
        if (outputRangeIndex < outputRanges.size()) {
            const qoutputrange outputRange = outputRanges.at(_pressure->outputRange());
            qCDebug(beeCopterDeviceInfoLog) << Q_FUNC_INFO << "Selected Output Range:" << outputRange.minimum << outputRange.maximum << outputRange.accuracy;
        }
    }

    _readingChangedConnection = connect(_pressure, &QPressureSensor::readingChanged, this, [this]() {
        QPressureReading* reading = _pressure->reading();
        if (!reading) {
            return;
        }

        _temperatureC = reading->temperature();
        _pressurePa = reading->pressure();
        emit pressureUpdated(_pressurePa, _temperatureC);
    });

    // _pressure->setActive(true);
    const bool started = _pressure->start();
    if (!started) {
        qCWarning(beeCopterDeviceInfoLog) << Q_FUNC_INFO << "Failed to start pressure";
        return false;
    }

    return true;
}

void beeCopterPressure::quit()
{
    // _pressure->setActive(false);
    _pressure->stop();
    _pressure->disconnect(_readingChangedConnection);
}

beeCopterPressureFilter::beeCopterPressureFilter()
    : QPressureFilter()
{
    qCDebug(beeCopterDeviceInfoLog) << Q_FUNC_INFO << this;
}

beeCopterPressureFilter::~beeCopterPressureFilter()
{
    qCDebug(beeCopterDeviceInfoLog) << Q_FUNC_INFO << this;
}

bool beeCopterPressureFilter::filter(QPressureReading *reading)
{
    if (!reading) {
        return false;
    }

    const qreal temperature = reading->temperature();
    if ((temperature < s_minValidTemperatureC) || (temperature > s_maxValidTemperatureC)) {
        return false;
    }

    const qreal pressure = reading->pressure();
    if ((pressure < s_minValidPressurePa) || (pressure > s_maxValidPressurePa)) {
        return false;
    }

    return true;
}

////////////////////////////////////////////////////////////////////

Q_APPLICATION_STATIC(beeCopterCompass, s_compass);

beeCopterCompass* beeCopterCompass::instance()
{
    return s_compass();
}

beeCopterCompass::beeCopterCompass(QObject* parent)
    : QObject(parent)
    , _compass(new QCompass(this))
    , _compassFilter(std::make_shared<beeCopterCompassFilter>())
{
    // qCDebug(beeCopterDeviceInfoLog) << Q_FUNC_INFO << this;

    (void) connect(_compass, &QCompass::sensorError, this, [](int error) {
        qCWarning(beeCopterDeviceInfoLog) << Q_FUNC_INFO << "Compass error:" << error;
    });

    if (!init()) {
        qCWarning(beeCopterDeviceInfoLog) << Q_FUNC_INFO << "Error Initializing Compass Sensor";
    }
}

beeCopterCompass::~beeCopterCompass()
{
    // qCDebug(beeCopterDeviceInfoLog) << Q_FUNC_INFO << this;
}

bool beeCopterCompass::init()
{
    _compass->addFilter(_compassFilter.get());

    const bool connected = _compass->connectToBackend();
    if (!connected) {
        qCWarning(beeCopterDeviceInfoLog) << Q_FUNC_INFO << "Failed to connect to compass backend";
        return false;
    } else {
        qCDebug(beeCopterDeviceInfoLog) << Q_FUNC_INFO << "Connected to compass backend:" << _compass->identifier();
    }

    if (_compass->isFeatureSupported(QSensor::SkipDuplicates)) {
        _compass->setSkipDuplicates(true);
    }

    const qrangelist dataRates = _compass->availableDataRates();
    if (!dataRates.isEmpty()) {
        qCDebug(beeCopterDeviceInfoLog) << Q_FUNC_INFO << "Available Data Rates:" << dataRates;
        // _compass->setDataRate(dataRates.first().first);
        qCDebug(beeCopterDeviceInfoLog) << Q_FUNC_INFO << "Selected Data Rate:" << _compass->dataRate();
    }

    const qoutputrangelist outputRanges = _compass->outputRanges();
    if (!outputRanges.isEmpty()) {
        // qCDebug(beeCopterDeviceInfoLog) << Q_FUNC_INFO << "Output Ranges:" << outputRanges;
        // _compass->setOutputRange(outputRanges.first().first);
        const int outputRangeIndex = _compass->outputRange();
        if (outputRangeIndex < outputRanges.size()) {
            const qoutputrange outputRange = outputRanges.at(_compass->outputRange());
            qCDebug(beeCopterDeviceInfoLog) << Q_FUNC_INFO << "Selected Output Range:" << outputRange.minimum << outputRange.maximum << outputRange.accuracy;
        }
    }

    _readingChangedConnection = connect(_compass, &QCompass::readingChanged, this, [this]() {
        QCompassReading* const reading = _compass->reading();
        if (!reading) {
            return;
        }

        _calibrationLevel = reading->calibrationLevel();
        _azimuth = reading->azimuth();

        emit compassUpdated(_azimuth);

        QGeoPositionInfo update;
        update.setAttribute(QGeoPositionInfo::Attribute::Direction, _azimuth);
        update.setAttribute(QGeoPositionInfo::Attribute::DirectionAccuracy, _calibrationLevel);
        update.setTimestamp(QDateTime::currentDateTimeUtc());
        emit positionUpdated(update);
    });

    // _compass->setActive(true);
    const bool started = _compass->start();
    if (!started) {
        qCWarning(beeCopterDeviceInfoLog) << Q_FUNC_INFO << "Failed to start compass";
        return false;
    }

    return true;
}

void beeCopterCompass::quit()
{
    // _compass->setActive(false);
    _compass->stop();
    _compass->disconnect(_readingChangedConnection);
}

beeCopterCompassFilter::beeCopterCompassFilter()
    : QCompassFilter()
{
    qCDebug(beeCopterDeviceInfoLog) << Q_FUNC_INFO << this;
}

beeCopterCompassFilter::~beeCopterCompassFilter()
{
    qCDebug(beeCopterDeviceInfoLog) << Q_FUNC_INFO << this;
}

bool beeCopterCompassFilter::filter(QCompassReading *reading)
{
    if (!reading) {
        return false;
    }

    const qreal calibration = reading->calibrationLevel();
    return (calibration >= s_minCompassCalibrationLevel);
}

////////////////////////////////////////////////////////////////////

} // namespace beeCopterDeviceInfo
