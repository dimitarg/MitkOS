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

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nur, disko, ... } @ inputs : {

    nixosConfigurations = let

      makeSystem = { osConfig, guestUserConfig, system, modules } : nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = {
          inherit osConfig;
          inherit inputs;
          inherit guestUserConfig;
        }; # pass custom arguments into all sub module.

        inherit modules;

      };
      makeHmConfig = { osConfig, guestUserConfig, system } : {
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
      };
    in {

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
          gui = {
            enable = true;
          };
          extraHomeModules = [];
        };
        guestUserConfig = {
          enable = false;
        };
        system = "x86_64-linux";

        hmConfig = makeHmConfig {
          inherit osConfig;
          inherit guestUserConfig;
          inherit system;
        };

      in makeSystem {
        inherit osConfig;
        inherit guestUserConfig;
        inherit system;

        modules = [

          ./system-common/sys.nix # common config
          ./system-common/modules/cloudflare-dns
          ./hosts/nixos
          home-manager.nixosModules.home-manager hmConfig
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
          gui = {
            enable = true;
          };
          extraHomeModules = [];
        };
        guestUserConfig = {
          enable = false;
        };
        system = "x86_64-linux";

        hmConfig = makeHmConfig {
          inherit osConfig;
          inherit guestUserConfig;
          inherit system;
        };

      in makeSystem {

        inherit osConfig;
        inherit guestUserConfig;
        inherit system;

        modules = [

          ./system-common/sys.nix # common config
          ./hosts/spare

          home-manager.nixosModules.home-manager hmConfig
        ];
      };

      # Remote hardware
      "cloudy" = let
        osConfig = {
          hostSettings = {
            hostName = "cloudy";
            userName = "imap";
            userFullName = "Dimitar Georgiev";
          };
          virt-manager = {
            enable = false;
          };
          gaming = {
            enable = false;
          };
          gui = {
            # WIP making this a headless machine
            enable = false;
          };
          extraHomeModules = [
           # WIP making this a headless machine
           # ./hosts/cloudy/gui/home.nix
          ];
        };
        guestUserConfig = {
          enable = false;
        };
        system = "x86_64-linux";

        hmConfig = makeHmConfig {
          inherit osConfig;
          inherit guestUserConfig;
          inherit system;
        };

      in makeSystem {

        inherit osConfig;
        inherit guestUserConfig;
        inherit system;

        modules = [

          ./system-common/sys.nix # common config
          ./hosts/cloudy
          home-manager.nixosModules.home-manager hmConfig
          # WIP making this a headless machine
          #./system-common/modules/remote-desktop
        ];
      };

    };
  };
}
