{
  description = "Dimitar's NixOS Configurations";

  inputs = {
    # this tracks nixos-unstable, as opposed to master, which would cause breakage
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # home-manager, used for managing user configuration
    home-manager = {
      # home-manager master is built against nixos-unstable, so this is correct
      url = "github:nix-community/home-manager";
      # , but also explicitly pin home-manager's nixpkgs input to this flake's nixpkgs
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = github:nix-community/NUR;

    zsh-nix-shell = {
      url = "github:chisui/zsh-nix-shell";
      flake = false;
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nur, nixos-generators, ... } @ inputs : 
  let
    host-nixos = {
      hostName = "nixos";
      userName = "fmap";
      userFullName = "Dimitar Georgiev";
      userInitialPassword = "abcd";
    };
    linux64 = "x86_64-linux";
  in {
    
      nixosConfigurations = {

        "nixos" = nixpkgs.lib.nixosSystem {
          system = linux64;

          specialArgs = {
            hostSettings = host-nixos;
            inherit inputs;
          }; # pass custom arguments into all sub module.
          
          modules = [
            
            ./system-common/configuration.nix # common config
            ./hosts/nixos/hardware-configuration.nix # hardware scan
            ./hosts/nixos/from-install.nix # host-specific
            ./hosts/nixos/gpu-intel.nix # hardware quirks specific to this laptop

            home-manager.nixosModules.home-manager
            {
              # see https://discourse.nixos.org/t/home-manager-useuserpackages-useglobalpkgs-settings/34506/3
              # basically, true / true the sane defaults if the system is a NixOS system
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                hostSettings = host-nixos;
                inherit inputs;
              };
              home-manager.users.${host-nixos.userName} = import ./home-manager/home.nix;

            }
          ];
        };
        
      };

      packages.${linux64}.nixosIso = nixos-generators.nixosGenerate {

        system = linux64;

        specialArgs = {
          hostSettings = host-nixos;
          inherit inputs;
        }; # pass custom arguments into all sub module.
          
        modules = [
            
          ./system-common/configuration.nix # common config
          # ./hosts/nixos/hardware-configuration.nix # hardware scan
          # ./hosts/nixos/from-install.nix # host-specific
          # ./hosts/nixos/gpu-intel.nix # hardware quirks specific to this laptop


          home-manager.nixosModules.home-manager
          {
            # see https://discourse.nixos.org/t/home-manager-useuserpackages-useglobalpkgs-settings/34506/3
            # basically, true / true the sane defaults if the system is a NixOS system
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              hostSettings = host-nixos;
              inherit inputs;
            };
            home-manager.users.${host-nixos.userName} = import ./home-manager/home.nix;
          }
        ];

        customFormats = {
          iso-custom-compression = {
            imports = [
              "${nixpkgs}/nixos/modules/installer/cd-dvd/iso-image.nix"
            ];
            isoImage.makeEfiBootable = true;
            isoImage.makeUsbBootable = true;
            formatAttr = "isoImage";
            fileExtension = ".iso";
            isoImage.squashfsCompression = "zstd -Xcompression-level 1";
          };
        };

        format = "iso-custom-compression";
        
      };
    };
  }
