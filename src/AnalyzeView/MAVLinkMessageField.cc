#include "MAVLinkMessageField.h"
#include "MAVLinkChartController.h"
#include "MAVLinkMessage.h"
#include "beeCopterApplication.h"
#include "beeCopterLoggingCategory.h"

#include <QtCharts/QLineSeries>
#include <QtCharts/QAbstractSeries>

beeCopter_LOGGING_CATEGORY(MAVLinkMessageFieldLog, "AnalyzeView.MAVLinkMessageField")

beeCopterMAVLinkMessageField::beeCopterMAVLinkMessageField(const QString &name, const QString &type, beeCopterMAVLinkMessage *parent)
    : QObject(parent)
    , _type(type)
    , _name(name)
    , _msg(parent)
{
    // qCDebug(MAVLinkMessageFieldLog) << Q_FUNC_INFO << this;

    qCDebug(MAVLinkMessageFieldLog) << "Field:" << name << type;
}

beeCopterMAVLinkMessageField::~beeCopterMAVLinkMessageField()
{
    // qCDebug(MAVLinkMessageFieldLog) << Q_FUNC_INFO << this;
}

void beeCopterMAVLinkMessageField::addSeries(MAVLinkChartController *chartController, QAbstractSeries *series)
{
    if (_pSeries) {
        return;
    }

    _chartController = chartController;
    _pSeries = series;
    emit seriesChanged();

    _dataIndex = 0;
    _msg->updateFieldSelection();
}

void beeCopterMAVLinkMessageField::delSeries()
{
    if (!_pSeries) {
        return;
    }

    _values.clear();
    QLineSeries *const lineSeries = static_cast<QLineSeries*>(_pSeries);
    lineSeries->replace(_values);
    _pSeries = nullptr;
    _chartController = nullptr;
    emit seriesChanged();
    _msg->updateFieldSelection();
}

QString beeCopterMAVLinkMessageField::label() const
{
    return (_msg->name() + ": " + _name);
}

void beeCopterMAVLinkMessageField::setSelectable(bool sel)
{
    if (_selectable != sel) {
        _selectable = sel;
        emit selectableChanged();
    }
}

int beeCopterMAVLinkMessageField::chartIndex() const
{
    if (_chartController) {
        return _chartController->chartIndex();
    }

    return 0;
}

void beeCopterMAVLinkMessageField::updateValue(const QString &newValue, qreal v)
{
    if (_value != newValue) {
        _value = newValue;
        emit valueChanged();
    }

    if (!_pSeries || !_chartController) {
        return;
    }

    const int count = _values.count();
    if (count < (50 * 60)) { ///< Arbitrary limit of 1 minute of data at 50Hz for now
        const QPointF p(beeCopterApp()->msecsSinceBoot(), v);
        _values.append(p);
    } else {
        if (_dataIndex >= count) {
            _dataIndex = 0;
        }
        _values[_dataIndex].setX(beeCopterApp()->msecsSinceBoot());
        _values[_dataIndex].setY(v);
        _dataIndex++;
    }

    if (_chartController->rangeYIndex() != 0) {
        return;
    }

    qreal vmin = std::numeric_limits<qreal>::max();
    qreal vmax = std::numeric_limits<qreal>::min();
    for (const QPointF &point : _values) {
        const qreal value = point.y();
        if (vmax < value) {
            vmax = value;
        }
        if (vmin > value) {
            vmin = value;
        }
    }

    bool changed = false;
    if (std::abs(_rangeMin - vmin) > 0.000001) {
        _rangeMin = vmin;
        changed = true;
    }

    if (std::abs(_rangeMax - vmax) > 0.000001) {
        _rangeMax = vmax;
        changed = true;
    }

    if (changed) {
        _chartController->updateYRange();
    }
}

void beeCopterMAVLinkMessageField::updateSeries()
{
    const int count = _values.count();
    if (count <= 1) {
        return;
    }

    QList<QPointF> s;
    s.reserve(count);
    int idx = _dataIndex;
    for (int i = 0; i < count; i++, idx++) {
        if (idx >= count) {
            idx = 0;
        }

        const QPointF p(_values[idx]);
        s.append(p);
    }

    QLineSeries *const lineSeries = static_cast<QLineSeries*>(_pSeries);
    lineSeries->replace(s);
}
