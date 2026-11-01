{
  description = "Acer Nitro V16 NixOS system configuration with Flakes and Home Manager";

  inputs = {
    # System packages track the unstable or a specific stable branch
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager tracks its own repository, locked to match your nixpkgs version
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Caelestia Shell
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }: {
    nixosConfigurations = {
      # nixos below is hostname
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hardware-configuration.nix
          ./configuration.nix

          # Integrate Home Manager as a NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };

            home-manager.users.lolcraft2 = import ./home.nix;
          }
        ];
      };
    };
  };
}
