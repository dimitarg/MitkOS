{ config, pkgs, ... }:

{
  boot.loader.limine.enable = true;
  
  # no idea if this is needed
  boot.loader.efi.canTouchEfiVariables = true;

}