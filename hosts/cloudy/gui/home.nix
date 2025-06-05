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
    };
  };

}
