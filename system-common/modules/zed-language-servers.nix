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
  # java language server (Eclipse JDT LS). Used by the Zed `java` extension for
  # reading Java dependency sources from Scala projects. Note: jdtls only
  # understands Maven/Gradle/standalone Java projects, so it does not know an
  # sbt project's classpath -- expect basic Java features (syntax, hover,
  # outline, JDK navigation) rather than full cross-dependency navigation.
  pkgs.jdt-language-server
]
