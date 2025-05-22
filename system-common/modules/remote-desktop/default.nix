{ lib, config, pkgs, osConfig, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    # gives us winpr-makecert, see readme of this module
    freerdp
  ];

  services.gnome.gnome-remote-desktop.enable = true;

  # this makes sure g-r-d systemd service is started
  systemd.services."gnome-remote-desktop".wantedBy = [ "graphical.target" ];

  # TODO firewall settings
}