{ config, lib, pkgs, osConfig, inputs, ... }:

{
  services.power-profiles-daemon.enable = false; # not recommended to use power-profiles-daemon together with tlp
  services.tlp = {
    enable = true;
    settings = {
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      DEVICES_TO_DISABLE_ON_STARTUP = "bluetooth";
    };
  };

  environment.systemPackages = with pkgs; [
    powertop # just the package / cli for monitoring purposes, not the service / auto-tuning functionality, as that conflicts with tlp
  ];
}