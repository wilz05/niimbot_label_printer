//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <niimbot_label_printer/niimbot_label_printer_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) niimbot_label_printer_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "NiimbotLabelPrinterPlugin");
  niimbot_label_printer_plugin_register_with_registrar(niimbot_label_printer_registrar);
}
