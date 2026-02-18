#pragma once

#include <QtCore/QLoggingCategory>
#include <QtPositioning/QGeoPositionInfo>
#include <QtSensors/QAmbientTemperatureSensor>
#include <QtSensors/QCompass>
#include <QtSensors/QPressureSensor>

Q_DECLARE_LOGGING_CATEGORY(beeCopterDeviceInfoLog)

namespace beeCopterDeviceInfo
{

////////////////////////////////////////////////////////////////////

class beeCopterAmbientTemperatureFilter : public QAmbientTemperatureFilter
{
public:
    beeCopterAmbientTemperatureFilter();
    ~beeCopterAmbientTemperatureFilter();

    bool filter(QAmbientTemperatureReading *reading) final;

private:
    static constexpr const qreal s_minValidTemperatureC = -40.;
    static constexpr const qreal s_maxValidTemperatureC = 85.;
};

class beeCopterAmbientTemperature : public QObject
{
    Q_OBJECT

public:
    beeCopterAmbientTemperature(QObject* parent = nullptr);
    ~beeCopterAmbientTemperature();

    static beeCopterAmbientTemperature* instance();

    qreal temperature() const { return _temperatureC; }

    bool init();
    void quit();

signals:
    void temperatureUpdated(qreal temperature);

private:
    QAmbientTemperatureSensor* _ambientTemperature = nullptr;
    std::shared_ptr<beeCopterAmbientTemperatureFilter> _ambientTemperatureFilter = nullptr;

    QMetaObject::Connection _readingChangedConnection;

    qreal _temperatureC = 0;
};

////////////////////////////////////////////////////////////////////

class beeCopterPressureFilter : public QPressureFilter
{
public:
    beeCopterPressureFilter();
    ~beeCopterPressureFilter();

    bool filter(QPressureReading *reading) final;

private:
    static constexpr const qreal s_minValidPressurePa = 45000.;
    static constexpr const qreal s_maxValidPressurePa = 110000.;

    static constexpr const qreal s_minValidTemperatureC = -40.;
    static constexpr const qreal s_maxValidTemperatureC = 85.;
};

class beeCopterPressure : public QObject
{
    Q_OBJECT

public:
    beeCopterPressure(QObject* parent = nullptr);
    ~beeCopterPressure();

    static beeCopterPressure* instance();

    qreal pressure() const { return _pressurePa; }
    qreal temperature() const { return _temperatureC; }

    bool init();
    void quit();

signals:
    void pressureUpdated(qreal pressure, qreal temperature);

private:
    QPressureSensor* _pressure = nullptr;
    std::shared_ptr<beeCopterPressureFilter> _pressureFilter = nullptr;

    QMetaObject::Connection _readingChangedConnection;

    qreal _temperatureC = 0;
    qreal _pressurePa = 0;
};

////////////////////////////////////////////////////////////////////

class beeCopterCompassFilter : public QCompassFilter
{
public:
    beeCopterCompassFilter();
    ~beeCopterCompassFilter();

    bool filter(QCompassReading *reading) final;

private:
    static constexpr qreal s_minCompassCalibrationLevel = 0.65;
};

class beeCopterCompass : public QObject
{
    Q_OBJECT

public:
    beeCopterCompass(QObject *parent = nullptr);
    ~beeCopterCompass();

    static beeCopterCompass* instance();

    bool init();
    void quit();

signals:
    void compassUpdated(qreal azimuth);
    void positionUpdated(QGeoPositionInfo update);

private:
    QCompass *_compass = nullptr;
    std::shared_ptr<beeCopterCompassFilter> _compassFilter = nullptr;

    QMetaObject::Connection _readingChangedConnection;

    qreal _azimuth = 0;
    qreal _calibrationLevel = 0;
};

////////////////////////////////////////////////////////////////////

} /* namespace beeCopterDeviceInfo */
