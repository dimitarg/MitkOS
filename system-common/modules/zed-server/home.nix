{ pkgs, ... }:
# Server-side counterpart of ../code-server/home.nix, but for Zed's SSH remote
# development instead of VSCode Remote-SSH.
#
# Zed connects over plain SSH and runs a "remote server" binary on the host, in
# ~/.zed_server/. The binary Zed would download from zed.dev is a generic Linux
# build and won't run on NixOS (wrong dynamic linker) -- the same problem
# nixos-vscode-server solves for the VSCode server. So, like that module, we
# provide a NixOS-native server binary instead: the version-matched
# `remote_server` output of this flake's `zed-editor` package.
#
# Because cloudy and the client laptops are all built from the same flake.lock,
# the client's Zed and this binary come from the same nixpkgs revision. The
# client derives the expected file name from its own version
# (zed-remote-server-stable-<version>), which is exactly what the symlink below
# provides -- so the client finds and uses it directly, with no need for the
# `upload_binary_over_ssh` client setting.
{
  # `recursive = true` links each file inside the package's bin/ into a real,
  # writable ~/.zed_server directory (rather than making ~/.zed_server itself a
  # read-only store symlink, which would break Zed's need to write there).
  home.file.".zed_server" = {
    source = "${pkgs.zed-editor.remote_server}/bin";
    recursive = true;
  };

  # During remote development the language servers run on the host, not the
  # client, so the LSP binaries must be on the remote PATH. Shared with the gui
  # module via ../zed-language-servers.nix so the set stays in sync.
  home.packages = import ../zed-language-servers.nix pkgs;

  # Zed does not propagate the client's settings to the remote host, and the
  # language servers run here, so their configuration must be readable
  # server-side. This is the Zed twin of code-server's Machine settings.json;
  # the shared file is also imported by the gui module for local editing.
  home.file.".config/zed/settings.json".text =
    builtins.toJSON (import ../zed-settings.nix);
}
