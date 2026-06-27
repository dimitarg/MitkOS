# Language servers used by Zed, shared between the local editor (gui module)
# and the remote host (zed-server module) so the set stays in sync and is not
# duplicated.
#
# On NixOS the LSP binaries Zed would otherwise download into
# ~/.local/share/zed/languages won't run, so we provide them from nixpkgs on
# PATH instead -- on the client for local editing, and on the remote host where
# the servers actually run during SSH remote development.
#
# Add future Zed language servers here (and, if they need configuration, to
# ./zed-settings.nix).
pkgs: [
  # nix language server
  pkgs.nixd
  # scala language server
  pkgs.metals
]
