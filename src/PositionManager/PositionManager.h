#pragma once

#include <QtCore/QLoggingCategory>
#include <QtCore/QObject>
#include <QtPositioning/QGeoCoordinate>
#include <QtPositioning/QGeoPositionInfo>
#include <QtQmlIntegration/QtQmlIntegration>

Q_DECLARE_LOGGING_CATEGORY(beeCopterPositionManagerLog)

class QGeoPositionInfoSource;
class QNmeaPositionInfoSource;
class beeCopterCompass;

class beeCopterPositionManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("")

    Q_PROPERTY(QGeoCoordinate gcsPosition                   READ gcsPosition                    NOTIFY gcsPositionChanged)
    Q_PROPERTY(qreal          gcsHeading                    READ gcsHeading                     NOTIFY gcsHeadingChanged)
    Q_PROPERTY(qreal          gcsPositionHorizontalAccuracy READ gcsPositionHorizontalAccuracy  NOTIFY gcsPositionHorizontalAccuracyChanged)

public:
    explicit beeCopterPositionManager(QObject *parent = nullptr);
    ~beeCopterPositionManager();

    /// Gets the singleton instance of AudioOutput.
    ///     @return The singleton instance.
    static beeCopterPositionManager *instance();

    void init();
    QGeoCoordinate gcsPosition() const { return _gcsPosition; }
    qreal gcsHeading() const { return _gcsHeading; }
    qreal gcsPositionHorizontalAccuracy() const { return _gcsPositionHorizontalAccuracy; }
    QGeoPositionInfo geoPositionInfo() const { return _geoPositionInfo; }
    int updateInterval() const { return _updateInterval; }

    void setNmeaSourceDevice(QIODevice *device);

signals:
    void gcsPositionChanged(QGeoCoordinate gcsPosition);
    void gcsHeadingChanged(qreal gcsHeading);
    void positionInfoUpdated(QGeoPositionInfo update);
    void gcsPositionHorizontalAccuracyChanged(qreal gcsPositionHorizontalAccuracy);

private slots:
    void _positionUpdated(const QGeoPositionInfo &update);

private:
    enum beeCopterPositionSource {
        Simulated,
        InternalGPS,
        Log,
        NmeaGPS,
        ExternalGPS
    };

    void _setPositionSource(beeCopterPositionSource source);
    void _setupPositionSources();
    void _handlePermissionStatus(Qt::PermissionStatus permissionStatus);
    void _checkPermission();
    void _setGCSHeading(qreal newGCSHeading);
    void _setGCSPosition(const QGeoCoordinate &newGCSPosition);

    bool _usingPluginSource = false;
    int _updateInterval = 0;

    QGeoPositionInfo _geoPositionInfo;
    QGeoCoordinate _gcsPosition;
    qreal _gcsHeading = qQNaN();
    qreal _gcsPositionHorizontalAccuracy = std::numeric_limits<qreal>::infinity();
    qreal _gcsPositionVerticalAccuracy = std::numeric_limits<qreal>::infinity();
    qreal _gcsPositionAccuracy = std::numeric_limits<qreal>::infinity();
    qreal _gcsDirectionAccuracy = std::numeric_limits<qreal>::infinity();

    QGeoPositionInfoSource *_currentSource = nullptr;
    QGeoPositionInfoSource *_defaultSource = nullptr;
    QNmeaPositionInfoSource *_nmeaSource = nullptr;
    QGeoPositionInfoSource *_simulatedSource = nullptr;

    beeCopterCompass *_compass = nullptr;

    static constexpr qreal kMinHorizonalAccuracyMeters = 100.;
    static constexpr qreal kMinVerticalAccuracyMeters = 10.;
    static constexpr qreal kMinDirectionAccuracyDegrees = 30.;
};
