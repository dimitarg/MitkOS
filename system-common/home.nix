{ config, pkgs, inputs, osConfig, ... }:

{
    
    # access to additional packages not in nixpkgs via https://github.com/nix-community/NUR
    imports = [
      # this module adds config.nur / config.nur.repos to config, used later
      inputs.nur.nixosModules.nur
      modules/virt-manager/home.nix
    ];

    # Home Manager needs a bit of information about us and the paths it should manage.
    home.username = osConfig.hostSettings.userName;
    home.homeDirectory = "/home/${osConfig.hostSettings.userName}";

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
      # slack screensharing is broken under wayland, use slack web app in chrome until this gets resolved
      # https://forums.slackcommunity.com/s/feed/0D53a00009BSEGACA5
      # pkgs.slack
      pkgs.zoom-us
      pkgs.discord

      pkgs.jetbrains.idea-ultimate

      # non-work
      pkgs.spotify
      pkgs.vlc

      pkgs.libreoffice
      pkgs.okular
      pkgs.shotwell

      pkgs.transmission_4-gtk

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
          config.nur.repos.rycee.firefox-addons.lastpass-password-manager
          config.nur.repos.rycee.firefox-addons.privacy-badger
          config.nur.repos.rycee.firefox-addons.ublock-origin
        ];
      };

      policies = {
        "SecurityDevices" = {
          "Add" = {
            "CAC Module" = "${pkgs.opensc}/lib/opensc-pkcs11.so";
          };
        };
      };
      
    };

    programs.chromium = {
      enable = true;
    };

    programs.zsh = {
      enable = true;
      shellAliases = {
        ll = "ls -lah";
        # this file is expected to be created manually and is not provisioned via system config or home manager
        workvpn = "sudo openvpn --config /etc/openvpn_configs/work-new.ovpn";
        # this file is expected to be created manually and is not provisioned via system config or home manager
        jenkins_tunnel = "sudo ssh -C -L 443:test-jenkins.api-hss.com:443 -o StrictHostKeychecking=no -i ~/.ssh/hss-bastion ec2-user@3.9.190.245";
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
      plugins = [
        {
          name = "zsh-nix-shell";
          file = "nix-shell.plugin.zsh";
          src = inputs.zsh-nix-shell.outPath;
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
        pkgs.vscode-extensions.haskell.haskell
        pkgs.vscode-extensions.rust-lang.rust-analyzer
        pkgs.vscode-extensions.tamasfe.even-better-toml
      ];

      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;

      userSettings = {
        files.watcherExclude = {
        "**/.bloop" = true;
        "**/.metals" = true;
        "**/.ammonite" = true;
        };
        editor.tabSize = 2;
        metals.suggestLatestUpgrade = false;
      };

    };

    home.file.".face".source = ../assets/profilepic.jpg;

}

