{ lib, config, pkgs, inputs, osConfig, system, ... }:
{
  services.vscode-server.enable = true;

  home.file.".vscode-server/data/Machine/settings.json".text =
    builtins.toJSON (import ../vscode-settings.nix);
}