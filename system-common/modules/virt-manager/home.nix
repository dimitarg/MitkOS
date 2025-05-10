{ lib, config, pkgs, osConfig, inputs, ... }:

{
   config = lib.mkIf osConfig.virt-manager.enable {
     # Boilerplate for virt-manager first time setup
     dconf.settings = {
       "org/virt-manager/virt-manager/connections" = {
          autoconnect = ["qemu:///system"];
          uris = ["qemu:///system"];
       };
     };

     home.packages = [
        pkgs.gnome-boxes
     ];
   };
}