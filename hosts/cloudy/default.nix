{
  modulesPath,
  lib,
  pkgs,
  inputs,
  osConfig,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ./disk-config.nix
    ./hardware-configuration.nix
    inputs.disko.nixosModules.disko
    ../../system-common/modules/disable-dhcpd-docker.nix
    ../../system-common/modules/unattended-upgrade
    # System half of the Zed remote-server module (home half is wired via
    # extraHomeModules in flake.nix). Lets Zed's downloaded native extension
    # helpers run on NixOS.
    ../../system-common/modules/zed-server/sys.nix
  ];

  # Note on missing full disk encryption:
  # FDE will not reasonably protect us from a rogue Hetzner since they have physical access to the machine and varioud ways to circumvent any protection
  # However, it would prevent us from a third party if their processes in decomissioning or repurposing our disk fall short.
  # Consider FDE next time we set up a remote machine.

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  users.users.${osConfig.hostSettings.userName}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINi5PXCCF0n2dS8yeOL6Pw0BJsiXcJAjr+29wleWdGqn imap@nixos"
  ];

}
