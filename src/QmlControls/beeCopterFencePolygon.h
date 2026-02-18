#pragma once

#include "beeCopterMapPolygon.h"

/// The beeCopterFencePolygon class provides a polygon used by GeoFence support.
class beeCopterFencePolygon : public beeCopterMapPolygon
{
    Q_OBJECT

public:
    beeCopterFencePolygon(bool inclusion, QObject* parent = nullptr);
    beeCopterFencePolygon(const beeCopterFencePolygon& other, QObject* parent = nullptr);

    const beeCopterFencePolygon& operator=(const beeCopterFencePolygon& other);

    Q_PROPERTY(bool inclusion READ inclusion WRITE setInclusion NOTIFY inclusionChanged)

    /// Saves the beeCopterFencePolygon to the json object.
    ///     @param json Json object to save to
    void saveToJson(QJsonObject& json);

    /// Load a beeCopterFencePolygon from json
    ///     @param json Json object to load from
    ///     @param required true: no polygon in object will generate error
    ///     @param errorString Error string if return is false
    /// @return true: success, false: failure (errorString set)
    bool loadFromJson(const QJsonObject& json, bool required, QString& errorString);

    // Property methods

    bool inclusion      (void) const { return _inclusion; }
    void setInclusion   (bool inclusion);

signals:
    void inclusionChanged   (bool inclusion);

private slots:
    void _setDirty(void);

private:
    void _init(void);

    bool _inclusion;

    static constexpr int _jsonCurrentVersion = 1;

    static constexpr const char* _jsonInclusionKey = "inclusion";
};
