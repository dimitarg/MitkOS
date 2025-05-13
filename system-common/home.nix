{ config, pkgs, inputs, osConfig, system, ... }:

{
    
    imports = [
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

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = ["org.gnome.Papers.desktop"];
        "text/plain" = ["org.gnome.TextEditor.desktop"];
      };
    };

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

      # gtk4 pdf viewer, can sign PDFs via digital certs
      pkgs.papers

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

          "browser.aboutConfig.showWarning" = false;

          "dom.security.https_only_mode" = true;
          # disables firefox password manager as we use an external one
          "signon.rememberSignons" = false;
          "privacy.donottrackheader.enabled" = true;
          "browser.contentblocking.category" = "strict";
          # video hardware accerelation using vaapi
          "media.ffmpeg.vaapi.enabled" = true;

          "browser.newtabpage.activity-stream.showSponsored" =  false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;

          "extensions.getAddons.showPane" = false;
          "extensions.htmlaboutaddons.recommendations.enabled" = false;

          "browser.discovery.enabled" =  false;

          "browser.newtabpage.activity-stream.feeds.telemetry" =  false;
          "browser.newtabpage.activity-stream.telemetry" = false;

          "app.shield.optoutstudies.enabled" = false;
          /* 0341: disable Normandy/Shield [FF60+]
          * Shield is a telemetry system that can push and test "recipes"
          * [1] https://mozilla.github.io/normandy/ ***/
          "app.normandy.enabled" = false;
          "app.normandy.api_url" = "";

          "security.ssl.require_safe_negotiation" = true;

          # TODO consider https://github.com/arkenfox/user.js/blob/3d76c74c80485931425464fec0e59d6cb461677a/user.js#L1175 
          # For now, give Mozilla benefit of doubt
        };

        extensions = {
          packages = with pkgs.nur.repos.rycee.firefox-addons; [
            lastpass-password-manager
            privacy-badger
            ublock-origin
          ];
        };
      };

      policies = {
        "SecurityDevices" = {
          "Add" = {
            "CAC Module" = "${pkgs.opensc}/lib/opensc-pkcs11.so";
          };
        };
        EnableTrackingProtection = {
          Value= true;
          Cryptomining = true;
          Fingerprinting = true;
          EmailTracking = true;
        };
      };
      
    };

    # programs.chromium = {
    #   enable = true;
    # };

    programs.zsh = {
      enable = true;
      shellAliases = {
        ll = "ls -lah";
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

    programs.starship = {
      enable = true;
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

      profiles.default = {
        extensions = [
          pkgs.vscode-extensions.bbenoist.nix
          pkgs.vscode-extensions.scalameta.metals
          pkgs.vscode-extensions.scala-lang.scala
          pkgs.vscode-extensions.haskell.haskell

          pkgs.vscode-extensions.rust-lang.rust-analyzer
          
          pkgs.vscode-extensions.tamasfe.even-better-toml
          pkgs.vscode-extensions.k--kato.intellij-idea-keybindings
          pkgs.vscode-extensions.streetsidesoftware.code-spell-checker
          pkgs.vscode-extensions.disneystreaming.smithy
          # these are missing in nixpkgs
          # could be fixed via nix-community/nix-vscode-extensions
          # pkgs.vscode-extensions.buenon.scratchpads
          # pkgs.vscode-extensions.unison-lang.unison
        ];

        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;

        userSettings = {
          "files.watcherExclude" = {
          "**/.bloop" = true;
          "**/.metals" = true;
          "**/.ammonite" = true;
          };
          "editor.tabSize" = 2;

          "metals.suggestLatestUpgrade" = false;
          "metals.bloopJvmProperties" = [
            "-Xms2G"
            "-Xmx8G"
          ];
          
          "cSpell.userWords" = [
            "usecase"
            "usecases"
            "RDBMS"
            "Mailgun"
            "PosgtreSQL"
          ];
          "cSpell.language" = "en-GB";
        };
      
      };

    };

    home.file.".face".source = ../assets/profilepic.jpg;

    dconf.settings = {
      "org.gnome.desktop.input-sources" = {
        "sources" = [
          (pkgs.lib.gvariant.mkTuple [ "xkb" "us" ])
          (pkgs.lib.gvariant.mkTuple [ "xkb" "bg+phonetic" ])
        ];
      };
    };

}

