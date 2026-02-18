#include "beeCopterMapPolyline.h"
#include "beeCopterGeo.h"
#include "JsonHelper.h"
#include "JsonParsing.h"
#include "beeCopterQGeoCoordinate.h"
#include "beeCopterApplication.h"
#include "ShapeFileHelper.h"
#include "beeCopterLoggingCategory.h"

#include <QtCore/QLineF>
#include <QMetaMethod>

beeCopterMapPolyline::beeCopterMapPolyline(QObject* parent)
    : QObject               (parent)
    , _dirty                (false)
    , _interactive          (false)
{
    _init();
}

beeCopterMapPolyline::beeCopterMapPolyline(const beeCopterMapPolyline& other, QObject* parent)
    : QObject               (parent)
    , _dirty                (false)
    , _interactive          (false)
{
    *this = other;

    _init();
}

beeCopterMapPolyline::~beeCopterMapPolyline()
{
    beeCopterApp()->removeCompressedSignal(QMetaMethod::fromSignal(&beeCopterMapPolyline::pathChanged));
}

const beeCopterMapPolyline& beeCopterMapPolyline::operator=(const beeCopterMapPolyline& other)
{
    clear();

    QVariantList vertices = other.path();
    for (int i=0; i<vertices.count(); i++) {
        appendVertex(vertices[i].value<QGeoCoordinate>());
    }

    setDirty(true);

    return *this;
}

void beeCopterMapPolyline::_init(void)
{
    connect(&_polylineModel, &QmlObjectListModel::dirtyChanged, this, &beeCopterMapPolyline::_polylineModelDirtyChanged);
    connect(&_polylineModel, &QmlObjectListModel::countChanged, this, &beeCopterMapPolyline::_polylineModelCountChanged);
    connect(&_polylineModel, &QmlObjectListModel::modelReset, this, &beeCopterMapPolyline::pathChanged);

    connect(this, &beeCopterMapPolyline::countChanged, this, &beeCopterMapPolyline::isValidChanged);
    connect(this, &beeCopterMapPolyline::countChanged, this, &beeCopterMapPolyline::isEmptyChanged);

    beeCopterApp()->addCompressedSignal(QMetaMethod::fromSignal(&beeCopterMapPolyline::pathChanged));
}

void beeCopterMapPolyline::clear(void)
{
    _polylinePath.clear();
    emit pathChanged();

    _polylineModel.clearAndDeleteContents();

    emit cleared();

    setDirty(true);
}

void beeCopterMapPolyline::adjustVertex(int vertexIndex, const QGeoCoordinate coordinate)
{
    _polylinePath[vertexIndex] = QVariant::fromValue(coordinate);
    _polylineModel.value<beeCopterQGeoCoordinate*>(vertexIndex)->setCoordinate(coordinate);
    if (!_deferredPathChanged) {
        _deferredPathChanged = true;
        QTimer::singleShot(0, this, [this]() {
            emit pathChanged();
            _deferredPathChanged = false;
        });
    }
    setDirty(true);
}

void beeCopterMapPolyline::setDirty(bool dirty)
{
    if (_dirty != dirty) {
        _dirty = dirty;
        if (!dirty) {
            _polylineModel.setDirty(false);
        }
        emit dirtyChanged(dirty);
    }
}
QGeoCoordinate beeCopterMapPolyline::_coordFromPointF(const QPointF& point) const
{
    QGeoCoordinate coord;

    if (_polylinePath.count() > 0) {
        QGeoCoordinate tangentOrigin = _polylinePath[0].value<QGeoCoordinate>();
        beeCopterGeo::convertNedToGeo(-point.y(), point.x(), 0, tangentOrigin, coord);
    }

    return coord;
}

QPointF beeCopterMapPolyline::_pointFFromCoord(const QGeoCoordinate& coordinate) const
{
    if (_polylinePath.count() > 0) {
        double y, x, down;
        QGeoCoordinate tangentOrigin = _polylinePath[0].value<QGeoCoordinate>();

        beeCopterGeo::convertGeoToNed(coordinate, tangentOrigin, y, x, down);
        return QPointF(x, -y);
    }

    return QPointF();
}

void beeCopterMapPolyline::setPath(const QList<QGeoCoordinate>& path)
{
    beginReset();

    _polylinePath.clear();
    _polylineModel.clearAndDeleteContents();
    for (const QGeoCoordinate& coord: path) {
        _polylinePath.append(QVariant::fromValue(coord));
        _polylineModel.append(new beeCopterQGeoCoordinate(coord, this));
    }

    setDirty(true);

    endReset();
}

void beeCopterMapPolyline::setPath(const QVariantList& path)
{
    beginReset();

    _polylinePath = path;
    _polylineModel.clearAndDeleteContents();
    for (int i=0; i<_polylinePath.count(); i++) {
        _polylineModel.append(new beeCopterQGeoCoordinate(_polylinePath[i].value<QGeoCoordinate>(), this));
    }
    setDirty(true);

    endReset();
}


void beeCopterMapPolyline::saveToJson(QJsonObject& json)
{
    QJsonValue jsonValue;

    JsonHelper::saveGeoCoordinateArray(_polylinePath, false /* writeAltitude*/, jsonValue);
    json.insert(jsonPolylineKey, jsonValue);
    setDirty(false);
}

bool beeCopterMapPolyline::loadFromJson(const QJsonObject& json, bool required, QString& errorString)
{
    errorString.clear();
    clear();

    if (required) {
        if (!JsonParsing::validateRequiredKeys(json, QStringList(jsonPolylineKey), errorString)) {
            return false;
        }
    } else if (!json.contains(jsonPolylineKey)) {
        return true;
    }

    if (!JsonHelper::loadGeoCoordinateArray(json[jsonPolylineKey], false /* altitudeRequired */, _polylinePath, errorString)) {
        return false;
    }

    for (int i=0; i<_polylinePath.count(); i++) {
        _polylineModel.append(new beeCopterQGeoCoordinate(_polylinePath[i].value<QGeoCoordinate>(), this));
    }

    setDirty(false);
    emit pathChanged();

    return true;
}

QList<QGeoCoordinate> beeCopterMapPolyline::coordinateList(void) const
{
    QList<QGeoCoordinate> coords;

    for (int i=0; i<_polylinePath.count(); i++) {
        coords.append(_polylinePath[i].value<QGeoCoordinate>());
    }

    return coords;
}

void beeCopterMapPolyline::splitSegment(int vertexIndex)
{
    int nextIndex = vertexIndex + 1;
    if (nextIndex > _polylinePath.length() - 1) {
        return;
    }

    QGeoCoordinate firstVertex = _polylinePath[vertexIndex].value<QGeoCoordinate>();
    QGeoCoordinate nextVertex = _polylinePath[nextIndex].value<QGeoCoordinate>();

    double distance = firstVertex.distanceTo(nextVertex);
    double azimuth = firstVertex.azimuthTo(nextVertex);
    QGeoCoordinate newVertex = firstVertex.atDistanceAndAzimuth(distance / 2, azimuth);

    if (nextIndex == 0) {
        appendVertex(newVertex);
    } else {
        _polylineModel.insert(nextIndex, new beeCopterQGeoCoordinate(newVertex, this));
        _polylinePath.insert(nextIndex, QVariant::fromValue(newVertex));
        emit pathChanged();
    }
}

void beeCopterMapPolyline::appendVertex(const QGeoCoordinate& coordinate)
{
    _polylinePath.append(QVariant::fromValue(coordinate));
    _polylineModel.append(new beeCopterQGeoCoordinate(coordinate, this));
    emit pathChanged();
}

void beeCopterMapPolyline::removeVertex(int vertexIndex)
{
    if (vertexIndex < 0 || vertexIndex > _polylinePath.length() - 1) {
        qWarning() << "Call to removeVertex with bad vertexIndex:count" << vertexIndex << _polylinePath.length();
        return;
    }

    if (_polylinePath.length() <= 2) {
        // Don't allow the user to trash the polyline
        return;
    }

    QObject* coordObj = _polylineModel.removeAt(vertexIndex);
    coordObj->deleteLater();
    if(vertexIndex == _selectedVertexIndex) {
        selectVertex(-1);
    } else if (vertexIndex < _selectedVertexIndex) {
        selectVertex(_selectedVertexIndex - 1);
    } // else do nothing - keep current selected vertex

    _polylinePath.removeAt(vertexIndex);
    emit pathChanged();
}

void beeCopterMapPolyline::setInteractive(bool interactive)
{
    if (_interactive != interactive) {
        _interactive = interactive;
        emit interactiveChanged(interactive);
    }
}

QGeoCoordinate beeCopterMapPolyline::vertexCoordinate(int vertex) const
{
    if (vertex >= 0 && vertex < _polylinePath.count()) {
        return _polylinePath[vertex].value<QGeoCoordinate>();
    } else {
        qWarning() << "beeCopterMapPolyline::vertexCoordinate bad vertex requested";
        return QGeoCoordinate();
    }
}

QList<QPointF> beeCopterMapPolyline::nedPolyline(void)
{
    QList<QPointF>  nedPolyline;

    if (count() > 0) {
        QGeoCoordinate  tangentOrigin = vertexCoordinate(0);

        for (int i=0; i<_polylinePath.count(); i++) {
            double y, x, down;
            QGeoCoordinate vertex = vertexCoordinate(i);
            if (i == 0) {
                // This avoids a nan calculation that comes out of convertGeoToNed
                x = y = 0;
            } else {
                beeCopterGeo::convertGeoToNed(vertex, tangentOrigin, y, x, down);
            }
            nedPolyline += QPointF(x, y);
        }
    }

    return nedPolyline;
}

QList<QGeoCoordinate> beeCopterMapPolyline::offsetPolyline(double distance)
{
    QList<QGeoCoordinate> rgNewPolyline;

    // I'm sure there is some beautiful famous algorithm to do this, but here is a brute force method

    if (count() > 1) {
        // Convert the polygon to NED
        QList<QPointF> rgNedVertices = nedPolyline();

        // Walk the edges, offsetting by the specified distance
        QList<QLineF> rgOffsetEdges;
        for (int i=0; i<rgNedVertices.count() - 1; i++) {
            QLineF  offsetEdge;
            QLineF  originalEdge(rgNedVertices[i], rgNedVertices[i + 1]);

            QLineF workerLine = originalEdge;
            workerLine.setLength(distance);
            workerLine.setAngle(workerLine.angle() - 90.0);
            offsetEdge.setP1(workerLine.p2());

            workerLine.setPoints(originalEdge.p2(), originalEdge.p1());
            workerLine.setLength(distance);
            workerLine.setAngle(workerLine.angle() + 90.0);
            offsetEdge.setP2(workerLine.p2());

            rgOffsetEdges.append(offsetEdge);
        }

        QGeoCoordinate  tangentOrigin = vertexCoordinate(0);

        // Add first vertex
        QGeoCoordinate coord;
        beeCopterGeo::convertNedToGeo(rgOffsetEdges[0].p1().y(), rgOffsetEdges[0].p1().x(), 0, tangentOrigin, coord);
        rgNewPolyline.append(coord);

        // Intersect the offset edges to generate new central vertices
        QPointF  newVertex;
        for (int i=1; i<rgOffsetEdges.count(); i++) {
            auto intersect = rgOffsetEdges[i - 1].intersects(rgOffsetEdges[i], &newVertex);
            if (intersect == QLineF::NoIntersection) {
                // Two lines are colinear
                newVertex = rgOffsetEdges[i].p2();
            }
            beeCopterGeo::convertNedToGeo(newVertex.y(), newVertex.x(), 0, tangentOrigin, coord);
            rgNewPolyline.append(coord);
        }

        // Add last vertex
        int lastIndex = rgOffsetEdges.count() - 1;
        beeCopterGeo::convertNedToGeo(rgOffsetEdges[lastIndex].p2().y(), rgOffsetEdges[lastIndex].p2().x(), 0, tangentOrigin, coord);
        rgNewPolyline.append(coord);
    }

    return rgNewPolyline;
}

bool beeCopterMapPolyline::loadKMLOrSHPFile(const QString &file)
{
    QString errorString;
    QList<QList<QGeoCoordinate>> polylines;
    if (!ShapeFileHelper::loadPolylinesFromFile(file, polylines, errorString)) {
        beeCopterApp()->showAppMessage(errorString);
        return false;
    }
    if (polylines.isEmpty()) {
        beeCopterApp()->showAppMessage(tr("No polylines found in file"));
        return false;
    }
    const QList<QGeoCoordinate>& rgCoords = polylines.first();

    beginReset();
    clear();
    appendVertices(rgCoords);
    endReset();

    return true;
}

void beeCopterMapPolyline::_polylineModelDirtyChanged(bool dirty)
{
    if (dirty) {
        setDirty(true);
    }
}

void beeCopterMapPolyline::_polylineModelCountChanged(int count)
{
    emit countChanged(count);
}


double beeCopterMapPolyline::length(void) const
{
    double length = 0;

    for (int i=0; i<_polylinePath.count() - 1; i++) {
        QGeoCoordinate from = _polylinePath[i].value<QGeoCoordinate>();
        QGeoCoordinate to = _polylinePath[i+1].value<QGeoCoordinate>();
        length += from.distanceTo(to);
    }

    return length;
}

void beeCopterMapPolyline::appendVertices(const QList<QGeoCoordinate>& coordinates)
{
    beginReset();

    QList<QObject*> objects;
    for (const QGeoCoordinate& coordinate: coordinates) {
        objects.append(new beeCopterQGeoCoordinate(coordinate, this));
        _polylinePath.append(QVariant::fromValue(coordinate));
    }
    _polylineModel.append(objects);

    endReset();

    emit pathChanged();
}

void beeCopterMapPolyline::beginReset(void)
{
    _polylineModel.beginResetModel();
}

void beeCopterMapPolyline::endReset(void)
{
    _polylineModel.endResetModel();
}

void beeCopterMapPolyline::setTraceMode(bool traceMode)
{
    if (traceMode != _traceMode) {
        _traceMode = traceMode;
        emit traceModeChanged(traceMode);
    }
}

void beeCopterMapPolyline::selectVertex(int index)
{
    if(index == _selectedVertexIndex) return;   // do nothing

    if(-1 <= index && index < count()) {
        _selectedVertexIndex = index;
    } else {
        if (!beeCopterApp()->runningUnitTests()) {
            qWarning() << QStringLiteral("beeCopterMapPolyline: Selected vertex index (%1) is out of bounds! "
                                         "Polyline vertices indexes range is [%2..%3].").arg(index).arg(0).arg(count()-1);
        }
        _selectedVertexIndex = -1;   // deselect vertex
    }

    emit selectedVertexChanged(_selectedVertexIndex);
}
