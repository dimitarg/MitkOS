{ lib, config, pkgs, osConfig, inputs, guestUserConfig, ... }:

{
  config = lib.mkIf guestUserConfig.enable {
      # Define a user account. Don't forget to set a password with ‘passwd’.
      users.users.${guestUserConfig.userName} = {
        isNormalUser = true;
        description = guestUserConfig.userFullName;
      };
   };
}