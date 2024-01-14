# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/3cb59657-e2e6-4966-899c-a6a7542aca89";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."luks-6c64fa97-22f4-412e-939f-6c10a34852c1".device = "/dev/disk/by-uuid/6c64fa97-22f4-412e-939f-6c10a34852c1";

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-uuid/2715-F3CB";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/5943254d-68d2-4149-9069-b6f703fb22a9"; }
    ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp45s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp43s0.useDHCP = lib.mkDefault true;

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
