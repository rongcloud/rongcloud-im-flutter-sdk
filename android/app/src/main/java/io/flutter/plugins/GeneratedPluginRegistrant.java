package io.flutter.plugins;

import io.flutter.plugin.common.PluginRegistry;
import io.rong.flutter.imlib.RongcloudImPlugin;

/**
 * Generated file. Do not edit.
 */
public final class GeneratedPluginRegistrant {
  public static void registerWith(PluginRegistry registry) {
    if (alreadyRegisteredWith(registry)) {
      return;
    }
    RongcloudImPlugin.registerWith(registry.registrarFor("io.rong.flutter.imlib.RongcloudImPlugin"));
  }

  private static boolean alreadyRegisteredWith(PluginRegistry registry) {
    final String key = GeneratedPluginRegistrant.class.getCanonicalName();
    if (registry.hasPlugin(key)) {
      return true;
    }
    registry.registrarFor(key);
    return false;
  }
}
