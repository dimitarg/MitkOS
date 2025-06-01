{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./from-install.nix
    ../../system-common/modules/intel-laptop.nix
    ../../system-common/modules/systemd-boot.nix
    ../../system-common/modules/closed-firewall.nix

    
    # inputs.nixos-hardware.nixosModules.common-gpu-intel

    # this profile is imported as path and not a flake output, since common profiles are getting deprecated
    # , because they're considered for moving in nixpkgs directly
    # this profile also enables the intel alder lake GPU profile
    # notably it switches the driver to `intel-media-driver`
    "${inputs.nixos-hardware}/common/cpu/intel/alder-lake" 

  ];

  # this switches to `xe` (newer gen) from i915 default
  # hardware.intelgpu.driver = "xe";


  # but then: 

  # xe 0000:00:02.0: Your graphics device 46a6 is not officially supported
  # by xe driver in this kernel version. To force Xe probe,
  # use .force_probe='46a6' and i915.force_probe='!46a6'
  # module parameters or CONFIG_DRM_XE_FORCE_PROBE='46a6' and
  # CONFIG_DRM_I915_FORCE_PROBE='!46a6' configuration options.


  # so I did:
  # boot.kernelParams = [ "i915.force_probe=!46a6" "xe.force_probe=46a6" ];

  # but then I experienced a noticeable screen tear during stage 1 boot, and convinced myself this is not a good idea.

}

