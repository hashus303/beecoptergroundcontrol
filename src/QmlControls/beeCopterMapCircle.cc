#include "beeCopterMapCircle.h"
#include "JsonHelper.h"
#include "ParameterManager.h"

beeCopterMapCircle::beeCopterMapCircle(QObject* parent)
    : QObject           (parent)
    , _dirty            (false)
    , _interactive      (false)
    , _showRotation     (false)
    , _clockwiseRotation(true)
{
    _init();
}

beeCopterMapCircle::beeCopterMapCircle(const QGeoCoordinate& center, double radius, bool showRotation, bool clockwiseRotation, QObject* parent)
    : QObject           (parent)
    , _dirty            (false)
    , _center           (center)
    , _radius           (ParameterManager::defaultComponentId, _radiusFactName, FactMetaData::valueTypeDouble)
    , _interactive      (false)
    , _showRotation     (showRotation)
    , _clockwiseRotation(clockwiseRotation)
{
    _radius.setRawValue(radius);
    _init();
}

beeCopterMapCircle::beeCopterMapCircle(const beeCopterMapCircle& other, QObject* parent)
    : QObject           (parent)
    , _dirty            (false)
    , _center           (other._center)
    , _radius           (ParameterManager::defaultComponentId, _radiusFactName, FactMetaData::valueTypeDouble)
    , _interactive      (false)
    , _showRotation     (other._showRotation)
    , _clockwiseRotation(other._clockwiseRotation)
{
    _radius.setRawValue(other._radius.rawValue());
    _init();
}

const beeCopterMapCircle& beeCopterMapCircle::operator=(const beeCopterMapCircle& other)
{
    setCenter(other._center);
    _radius.setRawValue(other._radius.rawValue());
    setDirty(true);

    return *this;
}

void beeCopterMapCircle::_init(void)
{
    _nameToMetaDataMap = FactMetaData::createMapFromJsonFile(QStringLiteral(":/json/beeCopterMapCircle.Facts.json"), this);
    _radius.setMetaData(_nameToMetaDataMap[_radiusFactName]);

    connect(this,       &beeCopterMapCircle::centerChanged,   this, &beeCopterMapCircle::_setDirty);
    connect(&_radius,   &Fact::rawValueChanged,         this, &beeCopterMapCircle::_setDirty);
}

void beeCopterMapCircle::setDirty(bool dirty)
{
    if (_dirty != dirty) {
        _dirty = dirty;
        emit dirtyChanged(dirty);
    }
}

void beeCopterMapCircle::saveToJson(QJsonObject& json)
{
    QJsonValue jsonValue;
    QJsonObject circleObject;

    JsonHelper::saveGeoCoordinate(_center, false /* writeAltitude*/, jsonValue);
    circleObject.insert(_jsonCenterKey, jsonValue);
    circleObject.insert(_jsonRadiusKey, _radius.rawValue().toDouble());

    json.insert(jsonCircleKey, circleObject);
}

bool beeCopterMapCircle::loadFromJson(const QJsonObject& json, QString& errorString)
{
    errorString.clear();

    QList<JsonHelper::KeyValidateInfo> circleKeyInfo = {
        { jsonCircleKey, QJsonValue::Object, true },
    };
    if (!JsonHelper::validateKeys(json, circleKeyInfo, errorString)) {
        return false;
    }

    QJsonObject circleObject = json[jsonCircleKey].toObject();

    QList<JsonHelper::KeyValidateInfo> circleObjectKeyInfo = {
        { _jsonCenterKey, QJsonValue::Array,    true },
        { _jsonRadiusKey, QJsonValue::Double,   true },
    };
    if (!JsonHelper::validateKeys(circleObject, circleObjectKeyInfo, errorString)) {
        return false;
    }

    QGeoCoordinate center;
    if (!JsonHelper::loadGeoCoordinate(circleObject[_jsonCenterKey], false /* altitudeRequired */, center, errorString)) {
        return false;
    }
    setCenter(center);
    _radius.setRawValue(circleObject[_jsonRadiusKey].toDouble());

    _interactive =          false;
    _showRotation =         false;
    _clockwiseRotation =    true;

    return true;
}

void beeCopterMapCircle::setCenter(QGeoCoordinate newCenter)
{
    if (newCenter != _center) {
        _center = newCenter;
        setDirty(true);
        emit centerChanged(newCenter);
    }
}

void beeCopterMapCircle::_setDirty(void)
{
    setDirty(true);
}

void beeCopterMapCircle::setInteractive(bool interactive)
{
    if (_interactive != interactive) {
        _interactive = interactive;
        emit interactiveChanged(interactive);
    }
}

void beeCopterMapCircle::setShowRotation(bool showRotation)
{
    if (showRotation != _showRotation) {
        _showRotation = showRotation;
        emit showRotationChanged(showRotation);
    }
}

void beeCopterMapCircle::setClockwiseRotation(bool clockwiseRotation)
{
    if (clockwiseRotation != _clockwiseRotation) {
        _clockwiseRotation = clockwiseRotation;
        emit clockwiseRotationChanged(clockwiseRotation);
    }
}
