# User-side half of the smart card / digital signing stack: register the
# PKCS#11 provider installed by ./sys.nix with firefox's NSS database, which is
# what actually makes the card's certificates usable for signing.
#
# Imported from ../gui/home.nix. See ./sys.nix for why the mkIf is here.
{ lib, config, pkgs, osConfig, inputs, ... }:

{
  config = lib.mkIf osConfig.gui.enable {

    programs.firefox.policies.SecurityDevices.Add = {
      # Deliberately not "${pkgs.opensc}/lib/...": firefox copies this path
      # verbatim into the profile's pkcs11.txt, which is mutable state and is
      # never rewritten once a module of this name exists. A pinned store path
      # therefore dangles as soon as opensc is rebuilt and the old closure is
      # garbage collected, after which NSS silently stops loading the module.
      # That also breaks smart card signing in `papers`, because poppler reads
      # certificates out of the firefox NSS db. The system profile symlink
      # always resolves to the current opensc.
      "CAC Module" = "/run/current-system/sw/lib/opensc-pkcs11.so";
    };

  };
}
