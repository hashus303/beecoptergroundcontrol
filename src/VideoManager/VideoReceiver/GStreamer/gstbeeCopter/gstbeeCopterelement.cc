#include "gstbeeCopterelements.h"

#define GST_CAT_DEFAULT gst_beeCopter_debug
GST_DEBUG_CATEGORY_STATIC (GST_CAT_DEFAULT);

void
beeCopter_element_init(GstPlugin *plugin)
{
    (void) plugin;
    static gsize res = FALSE;
    if (g_once_init_enter(&res)) {
        GST_DEBUG_CATEGORY_INIT (gst_beeCopter_debug, "beeCopter", 0, "beeCopter");
        g_once_init_leave(&res, TRUE);
    }
}
