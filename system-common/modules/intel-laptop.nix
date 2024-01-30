{ config, lib, pkgs, osConfig, inputs, ... }:

{
  imports =
    [
      ./laptop.nix
    ];

  services.thermald.enable = true;
}