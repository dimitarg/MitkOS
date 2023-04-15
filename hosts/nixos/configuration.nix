# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./gpu-intel.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-d074f5e5-f947-43b3-9406-65fe6864d93e".device = "/dev/disk/by-uuid/d074f5e5-f947-43b3-9406-65fe6864d93e";
  boot.initrd.luks.devices."luks-d074f5e5-f947-43b3-9406-65fe6864d93e".keyFile = "/crypto_keyfile.bin";

  # Use latest stable kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernelParams = [ "mem_sleep_default=deep" ];
  
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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
  };
      

  programs.zsh.enable=true;
  users.defaultUserShell = pkgs.zsh;
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.fmap = {
    isNormalUser = true;
    description = "Dimitar Georgiev";
    extraGroups = [ "networkmanager" "wheel" "docker"];
    packages = with pkgs; [
    #  no need currently, as we currently manage these via home manager. If any global system packages needed, add them here.
    ];
  };
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    openvpn
    curl
    killall
  ];


  # exclude some packages that I don't use from the default GUI distro
 environment.gnome.excludePackages = with pkgs.gnome; [
    cheese      # photo booth
    epiphany    # web browser
    gedit       # text editor
    pkgs.gnome-text-editor
    # totem       # video player
    # evince      # document viewer
    geary       # email client
    seahorse    # password manager
    # these should be self explanatory
    # gnome-calculator gnome-calendar gnome-characters gnome-clocks
   gnome-contacts
    #  gnome-font-viewer gnome-logs
   gnome-maps
   # gnome-music
   pkgs.gnome-photos
   # gnome-screenshot
    # gnome-system-monitor
   gnome-weather
   yelp
   # gnome-disk-utility pkgs.gnome-connections
   pkgs.gnome-tour
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
  
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

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
      dates = "weekly";
      options = "--delete-older-than 7d";
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
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
