{ lib, config, pkgs, osConfig, inputs, ... }:

{
   config = lib.mkIf osConfig.virt-manager.enable {
     virtualisation = {
       libvirtd = {
         enable = true;
       };
     };
     programs.virt-manager.enable = true; 
   };
}