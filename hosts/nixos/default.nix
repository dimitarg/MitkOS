{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./from-install.nix
    ../../system-common/modules/intel-laptop.nix
    
    # inputs.nixos-hardware.nixosModules.common-gpu-intel

    # this profile is imported as path and not a flake output, since common profiles are getting deprecated
    # , because they're considered for moving in nixpkgs directly
    # this profile also enables the intel alder lake GPU profile
    # notably it switches the driver to `intel-media-driver`
    "${inputs.nixos-hardware}/common/cpu/intel/alder-lake" 
  ];

}

