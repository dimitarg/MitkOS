# Config generated during first-time install (primarily boot settings and disk encryption), which is machine-specific
# and therefore not in common system config. Originally generated in configuration.nix as opposed to hardware-configuration.nix
{ config, pkgs, ... }:

{

  boot.initrd.luks.devices."luks-b9a237f8-83ed-4ece-9f05-e657c2abd6a6".device = "/dev/disk/by-uuid/b9a237f8-83ed-4ece-9f05-e657c2abd6a6";

}