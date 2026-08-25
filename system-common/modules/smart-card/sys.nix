# Smart card stack, used for digital signing (national eID cards and the like):
# the reader daemon plus the PKCS#11 provider that browsers and PDF viewers
# load. See ./home.nix for the user-side half (registering that provider with
# firefox's NSS database).
#
# Imported from ../gui/sys.nix, i.e. GUI hosts only -- nothing on a headless
# host has a card reader attached, or anything to sign with.
#
# The mkIf below only exists because ../gui/sys.nix is itself imported
# unconditionally and self-guards the same way (cf. ../flatpak.nix); an
# unguarded module here would land on headless hosts too. Once the gui module
# is imported explicitly per host instead, drop the guard and keep the body.
{ lib, config, pkgs, osConfig, inputs, ... }:

{
  config = lib.mkIf osConfig.gui.enable {

    # smart card daemon
    services.pcscd = {
      enable = true;
      plugins = [ pkgs.ccid ];
    };

    environment.systemPackages = with pkgs; [
      pcsclite
      ccid
      # PKCS#11 provider. Deliberately in the *system* profile, not the user's:
      # the firefox policy in ./home.nix registers it by its
      # /run/current-system/sw/lib path -- see the comment there for why.
      opensc
    ];

  };
}
