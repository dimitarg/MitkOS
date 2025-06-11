{
  modulesPath,
  lib,
  pkgs,
  inputs,
  osConfig,
  ...
}:
{
  # disable suspend on inactive
  dconf.settings = {
    "org.gnome.settings-daemon.plugins.power" = {
      "sleep-inactive-battery-type" = "nothing";
      "sleep-inactive-ac-type" = "nothing";
      "idle-dim" = false;
      "sleep-inactive-battery-timeout" = 0;
      "sleep-inactive-ac-timeout" = 0;
    };
    "org.gnome.desktop.session" = {
      "idle-delay" = 0;
    };

  };

}
