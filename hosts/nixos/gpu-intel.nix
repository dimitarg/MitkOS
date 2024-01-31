{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.common-gpu-intel
  ];

  # Iris Xe graphics
  boot.kernelParams = [ "i915.force_probe=46a6" ];

}

