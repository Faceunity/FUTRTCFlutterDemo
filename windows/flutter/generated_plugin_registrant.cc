//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <permission_handler_windows/permission_handler_windows_plugin.h>
#include <tencent_trtc_cloud/tencent_trtc_cloud_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  PermissionHandlerWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PermissionHandlerWindowsPlugin"));
  TencentTrtcCloudPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("TencentTrtcCloudPlugin"));
}
