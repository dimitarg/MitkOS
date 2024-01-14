# Config generated during first-time install (primarily boot settings and disk encryption), which is machine-specific
# and therefore not in common system config
{ config, pkgs, ... }:

{
  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-d074f5e5-f947-43b3-9406-65fe6864d93e".device = "/dev/disk/by-uuid/d074f5e5-f947-43b3-9406-65fe6864d93e";
  boot.initrd.luks.devices."luks-d074f5e5-f947-43b3-9406-65fe6864d93e".keyFile = "/crypto_keyfile.bin";
}