{ config, pkgs, ... }:
{
  imports = [
    <home-manager/nixos>
  ];



  home-manager.users.fmap = {

      # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

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

    

    xdg.enable = true;

    home.packages = [
      
      pkgs.htop
      pkgs.bind
      pkgs.jq
      pkgs.file

      # needed globally for user because config is user-global anyways
      pkgs.awscli2

      # comms
      pkgs.slack
      pkgs.zoom-us
      pkgs.discord
      

      pkgs.jetbrains.idea-ultimate

      # non-work
      pkgs.gnome.gnome-sound-recorder
      pkgs.webcamoid
      pkgs.spotify
      pkgs.transmission
      pkgs.vlc

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
          "privacy.donottrackheader.enabled" = true;
          # video hardware accerelation using vaapi
          "media.ffmpeg.vaapi.enabled" = true;

        };

        extensions = [
          pkgs.nur.repos.rycee.firefox-addons.lastpass-password-manager
          pkgs.nur.repos.rycee.firefox-addons.privacy-badger
          pkgs.nur.repos.rycee.firefox-addons.ublock-origin
        ];
      };
      
    };

    programs.zsh = {
      enable = true;
      shellAliases = {
        ll = "ls -lah";
        # this file is expected to be created manually and is not provisioned via system config or home manager
        workvpn = "sudo openvpn --config /etc/openvpn_configs/work-new.ovpn";
      };
      history = {
        size = 10000;
        path = "${config.home-manager.users.fmap.xdg.dataHome}/zsh/history";
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
            rev = "v0.6.0";
            sha256 = "B0mdmIqefbm5H8wSG1h41c/J4shA186OyqvivmSK42Q=";
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
      extraConfig = {
        push = {
          autoSetupRemote = true;
        };
      };
    };

    programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      extensions = [
        pkgs.vscode-extensions.bbenoist.nix
        pkgs.vscode-extensions.scalameta.metals
        pkgs.vscode-extensions.scala-lang.scala
      ];
    };

    home.file.".face".source = ./assets/profilepic.jpg;

  };
}

