{ lib, config, pkgs, inputs, osConfig, system, ... }:
{
  programs.obs-studio = {
    enable = true;
  };
}