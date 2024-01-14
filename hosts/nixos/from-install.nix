# Config generated during first-time install (primarily boot settings and disk encryption), which is machine-specific
# and therefore not in common system config. Originally generated in configuration.nix as opposed to hardware-configuration.nix
{ config, pkgs, ... }:

{
  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Enable swap on luks
  boot.initrd.luks.devices."luks-d074f5e5-f947-43b3-9406-65fe6864d93e".device = "/dev/disk/by-uuid/d074f5e5-f947-43b3-9406-65fe6864d93e";
  boot.initrd.luks.devices."luks-d074f5e5-f947-43b3-9406-65fe6864d93e".keyFile = "/crypto_keyfile.bin";
}