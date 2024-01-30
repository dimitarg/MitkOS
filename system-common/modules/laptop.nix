{ config, lib, pkgs, osConfig, inputs, ... }:

{
  services.power-profiles-daemon.enable = false; # not recommended to use power-profiles-daemon together with tlp
  services.tlp.enable = true; # todo configure

  environment.systemPackages = with pkgs; [
    powertop # just the package / cli for monitoring purposes, not the service / auto-tuning functionality, as that conflicts with tlp
  ];
}