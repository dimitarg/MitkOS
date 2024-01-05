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
  };

  outputs = { self, nixpkgs, home-manager, nur, ... } @ inputs : {
    
    nixosConfigurations = {
      # By default, NixOS will try to refer the nixosConfiguration with its hostname.

      # Main laptop
      "nixos" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        # specialArgs = {...};  # pass custom arguments into all sub module.
        
        modules = [
          
          ./hosts/nixos/configuration.nix

          home-manager.nixosModules.home-manager
          {
            # see https://discourse.nixos.org/t/home-manager-useuserpackages-useglobalpkgs-settings/34506/3
            # basically, true / true the sane defaults if the system is a NixOS system
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.extraSpecialArgs = {
              inherit inputs;
            };

            home-manager.users.fmap = import ./home-manager/home.nix;

          }
        ];
      };
    };
  };
}