# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, hostSettings, inputs, ... }:

{
  # Use latest stable kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # this was originally added to fix suspend issues on Clevo; now common system config
  boot.kernelParams = [ "mem_sleep_default=deep" ];
  
  networking.hostName = hostSettings.hostName;

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Sofia";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.utf8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "bg_BG.utf8";
    LC_IDENTIFICATION = "bg_BG.utf8";
    LC_MEASUREMENT = "bg_BG.utf8";
    LC_MONETARY = "bg_BG.utf8";
    LC_NAME = "bg_BG.utf8";
    LC_NUMERIC = "bg_BG.utf8";
    LC_PAPER = "bg_BG.utf8";
    LC_TELEPHONE = "bg_BG.utf8";
    LC_TIME = "bg_BG.utf8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;

  services.xserver.desktopManager.gnome = {
  enable = true;
  extraGSettingsOverrides = ''
    [org.gnome.desktop.interface]
    enable-hot-corners=false
    [org.gnome.desktop.peripherals.touchpad]
    tap-to-click=true
  '';

};

  # Configure keymap
  # Unfortunately this only gets picked up on initial setup. If you
  # change these, run:
  # gsettings reset org.gnome.desktop.input-sources xkb-options
  # gsettings reset org.gnome.desktop.input-sources sources
  # reboot
  # (source: https://discourse.nixos.org/t/problem-with-xkboptions-it-doesnt-seem-to-take-effect/5269?u=jtojnar)
  services.xserver = {
    layout = "us,bg";
    xkbVariant = ",phonetic";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  
  # smart card daemon
  services.pcscd = {
    enable = true;
    plugins = [pkgs.ccid];
  };


  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
  
  
  # enable docker. This will auto-start dockerd
  virtualisation = {
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };

    libvirtd = {
      enable = true;
    };
  };

  programs.virt-manager.enable = true;
      

  programs.zsh.enable=true;
  users.defaultUserShell = pkgs.zsh;
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${hostSettings.userName} = {
    isNormalUser = true;
    description = hostSettings.userFullName;
    extraGroups = [ "networkmanager" "wheel" "docker"];
  };
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    openvpn
    curl
    killall

    # certs / smart cards
    pcsclite
    ccid
    opensc
  ];


  # exclude some packages that I don't use from the default GUI distro
 environment.gnome.excludePackages = with pkgs.gnome; [
   cheese      # photo booth
   epiphany    # web browser
   pkgs.gedit       # text editor, not needed as we have vscode and nano
   pkgs.gnome-text-editor
   # totem       # video player
   # evince      # document viewer
   geary       # email client
   seahorse    # password manager
   # gnome-calculator gnome-calendar  gnome-clocks
   gnome-contacts
   gnome-maps
   # gnome-music
   pkgs.gnome-photos
   gnome-weather
   yelp
   # gnome-disk-utility pkgs.gnome-connections
   pkgs.gnome-tour
   gnome-characters
   gnome-font-viewer
 ];

  services.xserver.excludePackages = [
    pkgs.xterm 
  ];

  # zsh completion for system packages
  environment.pathsToLink = [ "/share/zsh" ];
  # add zsh to GDM shells
  environment.shells = with pkgs; [ zsh ];

  # this is a hardcoded path to where I keep openvpn configs that are managed outside nix store
  # make sure update-resolv-conf exists in that path, as it may be used by some ovpn configs
  environment.etc."openvpn_configs/update-resolv-conf".source = "${pkgs.update-resolv-conf}/libexec/openvpn/update-resolv-conf";
  
  # This seems enough to fix slack Screen sharing for me.
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryFlavor = "gnome3";
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # firmware update service
  services.fwupd.enable = true;
  
  # firewall enabled with no allowed ingress is the default, let's make it explicit here.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
    allowPing = false;
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
