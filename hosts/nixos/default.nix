{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./from-install.nix
    ./gpu-intel.nix
    ../../system-common/modules/intel-laptop.nix
  ];

}

