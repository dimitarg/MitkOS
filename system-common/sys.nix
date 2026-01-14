# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, osConfig, inputs, ... }:

{
  imports = [
    inputs.nix-index-database.nixosModules.nix-index
    modules/virt-manager/sys.nix
    modules/gaming.nix
    modules/guest-user/sys.nix
    modules/gui/sys.nix
  ];

  # Use latest stable kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  
  networking.hostName = osConfig.hostSettings.hostName;

  # Set your time zone.
  time.timeZone = "Europe/Sofia";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "bg_BG.UTF8";
    LC_IDENTIFICATION = "bg_BG.UTF8";
    LC_MEASUREMENT = "bg_BG.UTF8";
    LC_MONETARY = "bg_BG.UTF8";
    LC_NAME = "bg_BG.UTF8";
    LC_NUMERIC = "bg_BG.UTF8";
    LC_PAPER = "bg_BG.UTF8";
    LC_TELEPHONE = "bg_BG.UTF8";
    LC_TIME = "bg_BG.UTF8";
  };

fonts.packages = [
  ## installs nerd-fonts ligatures to be used in Starship
  pkgs.nerd-fonts.adwaita-mono 
];

  
  security.rtkit.enable = true;
  

  
  # smart card daemon
  services.pcscd = {
    enable = true;
    plugins = [pkgs.ccid];
  };
  
  
  # enable docker. This will auto-start dockerd
  virtualisation = {
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
  };      

  programs.zsh.enable=true;
  users.defaultUserShell = pkgs.zsh;

  # command-not-found support
  programs.nix-index.enable = true;
  # run program without installing ti, by typing `, <program>`
  programs.nix-index-database.comma.enable = true;
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${osConfig.hostSettings.userName} = {
    isNormalUser = true;
    description = osConfig.hostSettings.userFullName;
    extraGroups = [ "wheel" "docker"];
  };
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    inputs.nur.overlays.default
    inputs.nix-vscode-extensions.overlays.default
  ];


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    openvpn3
    curl
    killall

    # certs / smart cards
    pcsclite
    ccid
    opensc

    # nix packages version diff tool
    nvd

  ];


  # zsh completion for system packages
  environment.pathsToLink = [ "/share/zsh" ];
  # add zsh to login shells
  environment.shells = with pkgs; [ zsh ];

  
  programs.mtr.enable = true;
  
  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # firmware update service
  services.fwupd.enable = true;

  programs.openvpn3 = {
    enable = true;
  };


  # Nix daemon config
  nix = {
    # Automate garbage collection
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 5d";
    };

    settings = {
      # Automate `nix store --optimise`
      auto-optimise-store = true;

      # Avoid unwanted garbage collection when using nix-direnv
      keep-outputs = true;
      keep-derivations = true;

      #enable nix flakes
      experimental-features = [ "nix-command" "flakes" ];
    };

    # this is a flake system, disable nix channels
    channel = {
      enable = false;
    };

    # add system / flake nixpgs path to NIX_PATH to in an effort to ensure legacy CLI works
    # Note this doesn't actually work, see https://discourse.nixos.org/t/disabling-channels-breaks-nix-path-resolution/34825
    nixPath = [ "nixpkgs=${inputs.nixpkgs.outPath}" ];

    registry = {
      # this sets the system flake registry's nixpkgs to the nixpkgs used to build the NixOS distro
      # this ensures cli commands using the flake registry (such as `nix shell`) will reuse the same nixpkgs,
      # ensuring consistency and preventing unnecessary downloads
      nixpkgs.flake = inputs.nixpkgs;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
