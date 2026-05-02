{ config, pkgs, ... }:

{
  imports =
    [
      ./limine-boot.nix
    ];

  boot.loader.limine.secureBoot.enable = true;
}