{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./from-install.nix
    ../../system-common/modules/intel-laptop.nix
    inputs.nixos-hardware.nixosModules.common-gpu-intel
  ];

}

