#pragma once

#include "beeCopterMapCircle.h"

/// The beeCopterFenceCircle class provides a cicle used by GeoFence support.
class beeCopterFenceCircle : public beeCopterMapCircle
{
    Q_OBJECT

public:
    beeCopterFenceCircle(QObject* parent = nullptr);
    beeCopterFenceCircle(const QGeoCoordinate& center, double radius, bool inclusion, QObject* parent = nullptr);
    beeCopterFenceCircle(const beeCopterFenceCircle& other, QObject* parent = nullptr);

    const beeCopterFenceCircle& operator=(const beeCopterFenceCircle& other);

    Q_PROPERTY(bool inclusion READ inclusion WRITE setInclusion NOTIFY inclusionChanged)

    /// Saves the beeCopterFenceCircle to the json object.
    ///     @param json Json object to save to
    void saveToJson(QJsonObject& json);

    /// Load a beeCopterFenceCircle from json
    ///     @param json Json object to load from
    ///     @param errorString Error string if return is false
    /// @return true: success, false: failure (errorString set)
    bool loadFromJson(const QJsonObject& json, QString& errorString);

    // Property methods

    bool inclusion      (void) const { return _inclusion; }
    void setInclusion   (bool inclusion);

signals:
    void inclusionChanged(bool inclusion);

private slots:
    void _setDirty(void);

private:
    void _init(void);

    bool _inclusion;

    static constexpr int _jsonCurrentVersion = 1;

    static constexpr const char* _jsonInclusionKey = "inclusion";
};
