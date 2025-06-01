{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./from-install.nix
    ../../system-common/modules/intel-laptop.nix
    ../../system-common/modules/systemd-boot.nix
    ../../system-common/modules/closed-firewall.nix
    
    # this profile is imported as path and not a flake output, since common profiles are getting deprecated
    # , because they're considered for moving in nixpkgs directly
    # this profile also enables the intel comet lake GPU profile
    # notably it switches the driver to `intel-media-driver`
    "${inputs.nixos-hardware}/common/cpu/intel/comet-lake" 

  ];

}

