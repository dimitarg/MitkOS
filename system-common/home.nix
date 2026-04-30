{ config, pkgs, inputs, osConfig, system, extraImports, ... }:

{
    
    imports = [
      modules/virt-manager/home.nix
      modules/gui/home.nix
    ] ++ osConfig.extraHomeModules;

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

    home.packages = [
      
      pkgs.htop
      pkgs.bind
      pkgs.jq
      pkgs.file

      # needed globally for user because config is user-global anyways
      pkgs.awscli2
      pkgs.kubectl

      pkgs.claude-code
    ];

    programs.zsh = {
      enable = true;
      
      # This is the default in newer home manager state versions
      dotDir = "${config.xdg.configHome}/zsh";
      
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
      # null is the default for newer home manager state.version's, this was added to not change existing behaviour
      # consider signing via ssh in the future?
      signing.format = "openpgp";
      settings = {
        user = {
          name = "Dimitar Georgiev";
          email = "dimitar.georgiev.bg@gmail.com";
        };
        push = {
          autoSetupRemote = true;
        };
      };
    };

    programs.k9s = {
      enable = true;
    };
}

