# Config generated during first-time install (primarily boot settings and disk encryption), which is machine-specific
# and therefore not in common system config. Originally generated in configuration.nix as opposed to hardware-configuration.nix
{ config, pkgs, ... }:

{


  # Enable swap on luks
  boot.initrd.luks.devices."luks-1acf76b6-03eb-4e91-a8dd-3d4e834b568f".device = "/dev/disk/by-uuid/1acf76b6-03eb-4e91-a8dd-3d4e834b568f";
}