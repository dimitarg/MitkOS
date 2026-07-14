{ config, lib, pkgs, osConfig, inputs, ... }:

{
  config = lib.mkIf osConfig.gui.enable {

    environment.systemPackages = [
      pkgs.gnome-software # for flatpak apps
    ];

    services.flatpak = {
      enable = true;
      # todo to see stuff in gnome software, for the time being we need to imperatively run
      # flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    };

  };
}
