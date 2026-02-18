#include "beeCopterVideoStreamInfo.h"
#include "beeCopterLoggingCategory.h"

beeCopter_LOGGING_CATEGORY(beeCopterVideoStreamInfoLog, "Camera.beeCopterVideoStreamInfo")

beeCopterVideoStreamInfo::beeCopterVideoStreamInfo(const mavlink_video_stream_information_t &info, QObject *parent)
    : QObject(parent)
{
    qCDebug(beeCopterVideoStreamInfoLog) << this;

    (void) memcpy(&_streamInfo, &info, sizeof(mavlink_video_stream_information_t));
}

beeCopterVideoStreamInfo::~beeCopterVideoStreamInfo()
{

}

qreal beeCopterVideoStreamInfo::aspectRatio() const
{
    qreal ar = 1.0;
    if (!resolution().isNull()) {
        ar = static_cast<double>(_streamInfo.resolution_h) / static_cast<double>(_streamInfo.resolution_v);
    }
    return ar;
}

bool beeCopterVideoStreamInfo::update(const mavlink_video_stream_status_t &status)
{
    bool changed = false;

    if (_streamInfo.hfov != status.hfov) {
        changed = true;
        _streamInfo.hfov = status.hfov;
    }

    if (_streamInfo.flags != status.flags) {
        changed = true;
        _streamInfo.flags = status.flags;
    }

    if (_streamInfo.bitrate != status.bitrate) {
        changed = true;
        _streamInfo.bitrate = status.bitrate;
    }

    if (_streamInfo.rotation != status.rotation) {
        changed = true;
        _streamInfo.rotation = status.rotation;
    }

    if (_streamInfo.framerate != status.framerate) {
        changed = true;
        _streamInfo.framerate = status.framerate;
    }

    if (_streamInfo.resolution_h != status.resolution_h) {
        changed = true;
        _streamInfo.resolution_h = status.resolution_h;
    }

    if (_streamInfo.resolution_v != status.resolution_v) {
        changed = true;
        _streamInfo.resolution_v = status.resolution_v;
    }

    if (changed) {
        emit infoChanged();
    }

    return changed;
}
