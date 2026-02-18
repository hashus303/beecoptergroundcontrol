#pragma once

#include <gst/gst.h>

G_BEGIN_DECLS

void beeCopter_element_init(GstPlugin *plugin);

GST_ELEMENT_REGISTER_DECLARE(beeCoptervideosinkbin);

G_END_DECLS
