#include "beeCopterFencePolygon.h"
#include "JsonHelper.h"

beeCopterFencePolygon::beeCopterFencePolygon(bool inclusion, QObject* parent)
    : beeCopterMapPolygon (parent)
    , _inclusion    (inclusion)
{
    _init();
}

beeCopterFencePolygon::beeCopterFencePolygon(const beeCopterFencePolygon& other, QObject* parent)
    : beeCopterMapPolygon (other, parent)
    , _inclusion    (other._inclusion)
{
    _init();
}

void beeCopterFencePolygon::_init(void)
{
    connect(this, &beeCopterFencePolygon::inclusionChanged, this, &beeCopterFencePolygon::_setDirty);
}

const beeCopterFencePolygon& beeCopterFencePolygon::operator=(const beeCopterFencePolygon& other)
{
    beeCopterMapPolygon::operator=(other);

    setInclusion(other._inclusion);

    return *this;
}

void beeCopterFencePolygon::_setDirty(void)
{
    setDirty(true);
}

void beeCopterFencePolygon::saveToJson(QJsonObject& json)
{
    json[JsonHelper::jsonVersionKey] = _jsonCurrentVersion;
    json[_jsonInclusionKey] = _inclusion;
    beeCopterMapPolygon::saveToJson(json);
}

bool beeCopterFencePolygon::loadFromJson(const QJsonObject& json, bool required, QString& errorString)
{
    errorString.clear();

    QList<JsonHelper::KeyValidateInfo> keyInfoList = {
        { JsonHelper::jsonVersionKey,   QJsonValue::Double, true },
        { _jsonInclusionKey,            QJsonValue::Bool,   true },
    };
    if (!JsonHelper::validateKeys(json, keyInfoList, errorString)) {
        return false;
    }

    if (json[JsonHelper::jsonVersionKey].toInt() != _jsonCurrentVersion) {
        errorString = tr("GeoFence Polygon only supports version %1").arg(_jsonCurrentVersion);
        return false;
    }

    if (!beeCopterMapPolygon::loadFromJson(json, required, errorString)) {
        return false;
    }

    setInclusion(json[_jsonInclusionKey].toBool());

    return true;
}

void beeCopterFencePolygon::setInclusion(bool inclusion)
{
    if (inclusion != _inclusion) {
        _inclusion = inclusion;
        emit inclusionChanged(inclusion);
    }
}
