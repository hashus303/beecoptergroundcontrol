#include "beeCopterFenceCircle.h"
#include "JsonHelper.h"

beeCopterFenceCircle::beeCopterFenceCircle(QObject* parent)
    : beeCopterMapCircle  (parent)
    , _inclusion    (true)
{
    _init();
}

beeCopterFenceCircle::beeCopterFenceCircle(const QGeoCoordinate& center, double radius, bool inclusion, QObject* parent)
    : beeCopterMapCircle  (center, radius, false /* showRotation */, true /* clockwiseRotation */, parent)
    , _inclusion    (inclusion)
{
    _init();
}

beeCopterFenceCircle::beeCopterFenceCircle(const beeCopterFenceCircle& other, QObject* parent)
    : beeCopterMapCircle  (other, parent)
    , _inclusion    (other._inclusion)
{
    _init();
}

void beeCopterFenceCircle::_init(void)
{
    connect(this, &beeCopterFenceCircle::inclusionChanged, this, &beeCopterFenceCircle::_setDirty);
}

const beeCopterFenceCircle& beeCopterFenceCircle::operator=(const beeCopterFenceCircle& other)
{
    beeCopterMapCircle::operator=(other);

    setInclusion(other._inclusion);

    return *this;
}

void beeCopterFenceCircle::_setDirty(void)
{
    setDirty(true);
}

void beeCopterFenceCircle::saveToJson(QJsonObject& json)
{
    json[JsonHelper::jsonVersionKey] = _jsonCurrentVersion;
    json[_jsonInclusionKey] = _inclusion;
    beeCopterMapCircle::saveToJson(json);
}

bool beeCopterFenceCircle::loadFromJson(const QJsonObject& json, QString& errorString)
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
        errorString = tr("GeoFence Circle only supports version %1").arg(_jsonCurrentVersion);
        return false;
    }

    if (!beeCopterMapCircle::loadFromJson(json, errorString)) {
        return false;
    }

    setInclusion(json[_jsonInclusionKey].toBool());

    return true;
}

void beeCopterFenceCircle::setInclusion(bool inclusion)
{
    if (inclusion != _inclusion) {
        _inclusion = inclusion;
        emit inclusionChanged(inclusion);
    }
}
