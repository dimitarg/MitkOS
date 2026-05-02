{ lib, config, pkgs, osConfig, inputs, ... }:

{
  # Automated system updates - pull from GitHub daily at 20:00
  system.autoUpgrade = {
    enable = true;
    dates = "20:00";
    flake = "github:dimitarg/MitkOS";
    allowReboot = true;
  };
}
