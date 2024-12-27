{ config, pkgs, inputs, osConfig, guestUserConfig, ... }:

{
    
    # Home Manager needs a bit of information about us and the paths it should manage.
    home.username = guestUserConfig.userName;
    home.homeDirectory = "/home/${guestUserConfig.userName}";

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

      pkgs.google-chrome
      
      pkgs.spotify
      pkgs.vlc
      
      pkgs.okular
      pkgs.shotwell
      pkgs.transmission_4-gtk
    ];

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

    home.file.".face".source = ../../../assets/derpina.jpg;

}

