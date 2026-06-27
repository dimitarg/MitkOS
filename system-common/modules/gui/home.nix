{ lib, config, pkgs, inputs, osConfig, system, ... }:

{
  config = lib.mkIf osConfig.gui.enable {
    xdg = {
      enable = true;

      # Hide GNOME's "Extensions" app (gnome-extensions-app) from the app grid and
      # the overview search.
      # Ref: https://github.com/NixOS/nixpkgs/issues/297847
      dataFile."applications/org.gnome.Extensions.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Extensions
        Exec=gnome-extensions-app
        NoDisplay=true
        Hidden=true
      '';

      mimeApps = {
        enable = true;
        defaultApplications = {

          "application/pdf" = ["org.gnome.Papers.desktop"];
          "text/plain" = ["org.gnome.TextEditor.desktop"];
          "text/xml" = ["org.gnome.TextEditor.desktop"];
          "application/xml" = ["org.gnome.TextEditor.desktop"];

          # When chromium is added, it seems to hijack associations even though it's not added as default
          "text/html" = ["firefox.desktop"];
          "x-scheme-handler/http" = ["firefox.desktop"];
          "x-scheme-handler/https" = ["firefox.desktop"];

        };
      };


    };

    home.packages = [
      
      pkgs.slack
      pkgs.zoom-us
      pkgs.discord

      pkgs.jetbrains.idea

      # non-work
      pkgs.spotify
      pkgs.vlc

      pkgs.libreoffice

      # gtk4 pdf viewer, can sign PDFs via digital certs
      pkgs.papers

      pkgs.transmission_4-gtk

    # Zed language servers, shared with the cloudy remote host (zed-server
    # module) via ../zed-language-servers.nix.
    ] ++ import ../zed-language-servers.nix pkgs;

    programs.firefox = {
      # this is default in newer home manager state versions
      configPath = "${config.xdg.configHome}/mozilla/firefox";
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
          "privacy.globalprivacycontrol.enabled" = true;
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
          packages = with pkgs.firefox-addons; [
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

    programs.vscode = {
      enable = true;
      # package = pkgs.vscodium;

      profiles.default = {
        extensions = with pkgs.nix-vscode-extensions.vscode-marketplace-release; [
          bbenoist.nix
          scalameta.metals
          scala-lang.scala
          haskell.haskell

          rust-lang.rust-analyzer
          
          tamasfe.even-better-toml
          k--kato.intellij-idea-keybindings
          streetsidesoftware.code-spell-checker
          disneystreaming.smithy
          github.copilot
          github.copilot-chat

          mkhl.direnv

          buenon.scratchpads
          # unison-lang.unison
        ];

        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;

        userSettings = import ../vscode-settings.nix;
      
      };

    };

    programs.zed-editor = {
      enable = true;
      # Write settings.json as a declarative store symlink instead of jq-merging
      # into the on-disk file (the default). The merge only ever adds/overrides
      # keys and never deletes them, so removing a setting in nix would never
      # take effect (this is how a stale lsp.metals.binary.arguments lingered and
      # blocked Metals DAP). Trade-off: settings.json becomes read-only, so
      # interactive changes in Zed won't persist -- put them in nix instead. This
      # matches how the zed-server module writes cloudy's settings.json.
      mutableUserSettings = false;
      extensions = [ "nix" "toml" "rust" "scala" "haskell" "java" ];
      # Client-only UI settings live here; the LSP/language settings that the
      # remote host also needs are shared via ../zed-settings.nix (see that
      # file for why they cannot stay client-side for remote development).
      userSettings = {
        base_keymap = "JetBrains";

        theme = {
          mode = "dark";
          dark = "One Dark";
          light = "One Light";
        };
      } // import ../zed-settings.nix;
    };

    # Global Zed debug + task configs, shared with the cloudy remote host
    # (zed-server module) so Scala run/debug presets are always available.
    # Merged into every workspace; project-level .zed/{debug,tasks}.json, if
    # present, take precedence.
    home.file.".config/zed/debug.json".text =
      builtins.toJSON (import ../zed-debug.nix);
    home.file.".config/zed/tasks.json".text =
      builtins.toJSON (import ../zed-tasks.nix);

    # terminal emulator
    programs.ghostty = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      systemd.enable = true;
      # https://ghostty.org/docs/config/reference
      settings = {
        shell-integration-features = [
          # https://ghostty.org/docs/help/terminfo
          "sudo"
          "ssh-terminfo"
          "ssh-env"
        ];
      };
    };

    home.sessionVariables = {
      # needed because gnome terminal is removed by us
      TERMINAL = "ghostty";
    };

    # needed because gnome terminal is removed by us
    xdg.terminal-exec = {
      enable = true;
      settings.default = [
        "ghostty"
      ];
    };

    programs.chromium = {
      enable = true;
      package = pkgs.ungoogled-chromium;
    };


    home.file.".face".source = ../../../assets/profilepic.jpg;

    dconf.settings = {
      "org.gnome.desktop.input-sources" = {
        "sources" = [
          (pkgs.lib.gvariant.mkTuple [ "xkb" "us" ])
          (pkgs.lib.gvariant.mkTuple [ "xkb" "bg+phonetic" ])
        ];
      };
      # Free up workspace left/right shortcuts so they don't conflict
      # with VSCode forward/back navigation.
      "org.gnome.desktop.wm.keybindings" = {
        "switch-to-workspace-left" = [ "" ];
        "switch-to-workspace-right" = [ "" ];
      };
    };
  };
}

