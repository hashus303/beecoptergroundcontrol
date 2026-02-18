#pragma once

#include <gst/gstbin.h>

G_BEGIN_DECLS

#define GST_TYPE_beeCopter_VIDEO_SINK_BIN (gst_beeCopter_video_sink_bin_get_type())
G_DECLARE_FINAL_TYPE (GstbeeCopterVideoSinkBin, gst_beeCopter_video_sink_bin, GST, beeCopter_VIDEO_SINK_BIN, GstBin)

struct _GstbeeCopterVideoSinkBin
{
    GstBin parent;
    GstElement *glsinkbin;
    GstElement *qmlglsink;
};

G_END_DECLS
