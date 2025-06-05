{ lib, config, pkgs, osConfig, inputs, ... }:

{
  config = lib.mkIf osConfig.gui.enable {

      networking.networkmanager.enable = true;
      users.users.${osConfig.hostSettings.userName}.extraGroups = [ "networkmanager" ];

      environment.systemPackages = with pkgs; [
        waypipe
      ];
      
      services.displayManager.gdm.enable = true;

      services.desktopManager.gnome = {
        enable = true;
        extraGSettingsOverrides = ''
          [org.gnome.desktop.interface]
          enable-hot-corners=false
          [org.gnome.desktop.peripherals.touchpad]
          tap-to-click=true
        '';
      };

      services.xserver = {
        # this is confusing naming, we're actually using wayland
        enable = true;

        # Configure keymap
        # Unfortunately this only gets picked up on initial setup. If you
        # change these, run:
        # gsettings reset org.gnome.desktop.input-sources xkb-options
        # gsettings reset org.gnome.desktop.input-sources sources
        # reboot
        # (source: https://discourse.nixos.org/t/problem-with-xkboptions-it-doesnt-seem-to-take-effect/5269?u=jtojnar)
        xkb = {
          layout = "us,bg";
          variant = ",phonetic";
        };

        excludePackages = [
          pkgs.xterm 
        ];
      };

      # Enable CUPS to print documents.
      services.printing.enable = true;

      services.pulseaudio.enable = false;
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
      services.libinput.enable = true;

      # exclude some packages that I don't use from the default GUI distro
      environment.gnome.excludePackages = with pkgs.gnome; [
        pkgs.cheese      # photo booth
        pkgs.epiphany    # web browser

        pkgs.gedit       # text editors, not needed as we have vscode and nano and gnome-text-editor

        #  we're no longer removing this as it's a default editor for non-techies
        #  if absent, text files open in LibreOffice writer or some other random program, which is horrible UX 
        # pkgs.gnome-text-editor
        

        pkgs.geary       # email client. Probably use Thunderbird if we need one.
        pkgs.seahorse    # password manager

        # gnome-calculator gnome-calendar  gnome-clocks
        pkgs.gnome-contacts
        pkgs.gnome-maps

        # gnome-music
        pkgs.gnome-photos
        pkgs.gnome-weather
        pkgs.yelp
        
        pkgs.gnome-tour
        pkgs.gnome-characters
        pkgs.gnome-font-viewer

        # gnome pdf viewer, removed since we use `papers`
        pkgs.evince
      ];

      # I don't really remember why I installed this - maybe I needed a GPG key for OSS signing
      # https://github.com/dimitarg/MitkOS/commit/dd1b8633f4b9347612badb5c4a0d29f012016115
      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
        pinentryPackage = pkgs.pinentry-gnome3;
      };


  };
}
