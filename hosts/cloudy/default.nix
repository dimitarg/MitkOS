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
    # WIP: making this a headless machine
    # ./gui/sys.nix
    inputs.disko.nixosModules.disko
  ];

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
    };
  };

  # Do something useful with this machine until I start using it again
  services.foldingathome = {
    enable = true;
  };

  {
  networking.firewall = {
    allowedTCPPorts = [ 7396 ]; # foldingathome
  };
}


  users.users.${osConfig.hostSettings.userName}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINi5PXCCF0n2dS8yeOL6Pw0BJsiXcJAjr+29wleWdGqn imap@nixos"
  ];

}
