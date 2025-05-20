{
  description = "Dimitar's NixOS Configurations";

  inputs = {
    # this tracks nixos-unstable, as opposed to master, which would cause breakage
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # NixOS profiles to optimize settings for different hardware.
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    # home-manager, used for managing user configuration
    home-manager = {
      # home-manager master is built against nixos-unstable, so this is correct
      url = "github:nix-community/home-manager";
      # , but also explicitly pin home-manager's nixpkgs input to this flake's nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = github:nix-community/NUR;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zsh-nix-shell = {
      url = "github:chisui/zsh-nix-shell";
      flake = false;
    };

    # Workaround for https://github.com/NixOS/nixpkgs/issues/171054
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, home-manager, nur, ... } @ inputs : {
    
    nixosConfigurations = {

      # Main laptop
      "nixos" = let
        osConfig = {
          hostSettings = {
            hostName = "nixos";
            userName = "imap";
            userFullName = "Dimitar Georgiev";
          };
          virt-manager = {
            enable = true;
          };
          gaming = {
            enable = true;
          };
        };
        guestUserConfig = {
          enable = false;
        };
        system = "x86_64-linux";
        
      in nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit osConfig;
          inherit inputs;
          inherit guestUserConfig;
        }; # pass custom arguments into all sub module.
        
        modules = [
          
          ./system-common/sys.nix # common config
          ./hosts/nixos

          home-manager.nixosModules.home-manager
          {
            # see https://discourse.nixos.org/t/home-manager-useuserpackages-useglobalpkgs-settings/34506/3
            # basically, true / true the sane defaults if the system is a NixOS system
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.backupFileExtension = "backup";

            home-manager.extraSpecialArgs = {
              inherit inputs;
              inherit osConfig;
              inherit guestUserConfig;
              inherit system;
            };

            home-manager.users.${osConfig.hostSettings.userName} = import ./system-common/home.nix;

            home-manager.users.${guestUserConfig.userName} = import ./system-common/modules/guest-user/home.nix;

          }
        ];
      };

      # Spare hardware
      "spare" = let
        osConfig = {
          hostSettings = {
            hostName = "spare";
            userName = "fmap";
            userFullName = "Dimitar Georgiev";
          };
          virt-manager = {
            enable = true;
          };
          gaming = {
            enable = false;
          };
        };
        guestUserConfig = {
          enable = false;
        };
        system = "x86_64-linux";
        
      in nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit osConfig;
          inherit inputs;
          inherit guestUserConfig;
        }; # pass custom arguments into all sub module.
        
        modules = [
          
          ./system-common/sys.nix # common config
          ./hosts/spare

          home-manager.nixosModules.home-manager
          {
            # see https://discourse.nixos.org/t/home-manager-useuserpackages-useglobalpkgs-settings/34506/3
            # basically, true / true the sane defaults if the system is a NixOS system
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.backupFileExtension = "backup";

            home-manager.extraSpecialArgs = {
              inherit inputs;
              inherit osConfig;
              inherit guestUserConfig;
              inherit system;
            };

            home-manager.users.${osConfig.hostSettings.userName} = import ./system-common/home.nix;
          }
        ];
      };

      # Virtual manager test machine provisioned via playbooks/virtual-new-install.nix
      "virt-nixos" = let
        osConfig = {
          hostSettings = {
            hostName = "virt-nixos";
            userName = "imap";
            userFullName = "Dimitar Georgiev";
          };
          virt-manager = {
            enable = false;
          };
          gaming = {
            enable = false;
          };
        };
      in nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = {
          inherit osConfig;
          inherit inputs;
        }; # pass custom arguments into all sub module.
        
        modules = [
          
          ./system-common/sys.nix # common config

          ./hosts/virt-nixos/hardware-configuration.nix # hardware scan

          home-manager.nixosModules.home-manager
          {
            # see https://discourse.nixos.org/t/home-manager-useuserpackages-useglobalpkgs-settings/34506/3
            # basically, true / true the sane defaults if the system is a NixOS system
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = {
              inherit inputs;
              inherit osConfig;
            };

            home-manager.users.${osConfig.hostSettings.userName} = import ./system-common/home.nix;

          }
        ];
      };
      
    };
  };
}