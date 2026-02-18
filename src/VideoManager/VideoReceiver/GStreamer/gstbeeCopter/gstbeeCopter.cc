#include "gstbeeCopterelements.h"

static gboolean
plugin_init(GstPlugin *plugin)
{
    gboolean ret = FALSE;

    ret |= GST_ELEMENT_REGISTER(beeCoptervideosinkbin, plugin);

    return ret;
}

#define GST_PACKAGE_NAME   "GStreamer plugin for beeCopter's Video Receiver"
#define GST_PACKAGE_ORIGIN "https://beeCopter.com/"
#define GST_LICENSE        "LGPL"
#define PACKAGE            "beeCopter Video Receiver"
#define PACKAGE_VERSION    "current"

GST_PLUGIN_DEFINE(
    GST_VERSION_MAJOR, GST_VERSION_MINOR,
    beeCopter,
    "beeCopter Video Receiver Plugin",
    plugin_init,
    PACKAGE_VERSION, GST_LICENSE, GST_PACKAGE_NAME, GST_PACKAGE_ORIGIN
)
