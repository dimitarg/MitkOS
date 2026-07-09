{ pkgs, ... }:
# Zed remote SSH server module.
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
  #
  # node is appended here (not in the shared LSP set) because it is a remote-only
  # need. Metals' "Cascade compile" and the other Metals: tasks run
  # `node ~/.metals-zed/cmd.mjs <command>` to POST to the proxy's HTTP port. The
  # nixpkgs zed-editor package wraps the local GUI with nodejs on PATH, so tasks
  # inherit node there for free; the downloaded remote_server binary is not
  # wrapped that way, so without this its task shell (`zsh -i -c 'node ...'`)
  # cannot find node. (The Metals LSP itself works regardless, via Zed's own
  # bundled node.)
  home.packages = import ../zed-language-servers.nix pkgs ++ [ pkgs.nodejs ];

  # Zed does not propagate the client's settings to the remote host, and the
  # language servers run here, so their configuration must be readable
  # server-side. This is the Zed twin of code-server's Machine settings.json;
  # the shared file is also imported by the gui module for local editing.
  home.file.".config/zed/settings.json".text =
    builtins.toJSON (import ../zed-settings.nix);

  # Scala run/debug presets, shared with the client via the same files the gui
  # module uses. Written here too so they are present whichever side Zed reads
  # them from for a remote project.
  home.file.".config/zed/debug.json".text =
    builtins.toJSON (import ../zed-debug.nix);
  home.file.".config/zed/tasks.json".text =
    builtins.toJSON (import ../zed-tasks.nix);
}
