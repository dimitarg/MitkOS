{ config, pkgs, ... }:


let
  unstable = import <nixpkgs-unstable> { config.allowUnfree = true; };
in {

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # access to additional packages via https://github.com/nix-community/NUR
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };


  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "fmap";
  home.homeDirectory = "/home/fmap";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = [
    pkgs.htop
    pkgs.bind

    pkgs.slack
    pkgs.zoom-us
    pkgs.webcamoid

    pkgs.awscli2
    pkgs.jetbrains.idea-ultimate
  ];


  programs.firefox = {
    enable = true;
    # we need a Profile in order for extension provisioning to work
    profiles.default = {
      id = 0;
      name = "Default";
      isDefault = true;

      settings = {
        "dom.security.https_only_mode" = true;
        # disables firefox password manager as we use an external one
        "signon.rememberSignons" = false;
      };
    };
    extensions = [
      pkgs.nur.repos.rycee.firefox-addons.lastpass-password-manager
      pkgs.nur.repos.rycee.firefox-addons.https-everywhere
    ];
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -lah";
      # this file is expected to be created manually and is not provisioned via system config or home manager
      workvpn = "sudo openvpn --config /etc/openvpn_configs/work.ovpn";
    };
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ 
        "git"
        "aws"
        "command-not-found"
      ];
      theme = "robbyrussell";
    };
    historySubstringSearch = {
      enable = true;
    };

    enableCompletion = true;
    
    # This allows to use zsh as a shell in nix-shell, instead of defaulting to bash
    # See https://github.com/chisui/zsh-nix-shell
    plugins = [
      {
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.5.0";
          sha256 = "0za4aiwwrlawnia4f29msk822rj9bgcygw6a8a6iikiwzjjz0g91";
        };
      }
    ];
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    # this is true by default, and so is bash, just being explicit.
    enableZshIntegration = true;
  };


  programs.git = {
    enable = true;
    userName = "Dimitar Georgiev";
    userEmail = "dimitar.georgiev.bg@gmail.com";
  };

  programs.vscode = {
    enable = true;
    package = unstable.vscode;
    extensions = [
      unstable.vscode-extensions.bbenoist.nix
      unstable.vscode-extensions.scalameta.metals
      unstable.vscode-extensions.scala-lang.scala
    ];
  };
  
}
