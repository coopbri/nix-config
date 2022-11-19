{
  description = "Personal Nix(OS) config";

  inputs = {
    # Home Manager: https://nixos.wiki/wiki/home_manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      inherit (self) outputs;
      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
    in rec {
      # Reusable NixOS modules you might want to export
      # These are usually stuff you would upstream into nixpkgs
      nixosModules = import ./modules/nixos;

      # Reusable home-manager modules you might want to export
      # These are usually stuff you would upstream into home-manager
      homeManagerModules = import ./modules/home-manager;

      # custom packages and modifications, exported as overlays
      overlays = import ./overlays;

      legacyPackages = forAllSystems (system:
        import nixpkgs {
          inherit system;
          # apply overlays
          overlays = with overlays; [ additions modifications ];
          # config.allowUnfree = true;
        });

      # custom packages (acessible through 'nix build', 'nix shell', etc.)
      packages = forAllSystems
        (system: import ./pkgs { pkgs = legacyPackages.${system}; });

      # devshell for bootstrapping
      # acessible through 'nix develop' or 'nix-shell' (legacy)
      devShells = forAllSystems (system:
        let pkgs = legacyPackages.${system};
        in import ./shell.nix { inherit pkgs; });

      # NixOS config
      nixosConfigurations = {
        # format: <hostname> = ...
        # Ethereum node
        snowflake = nixpkgs.lib.nixosSystem {
          pkgs = legacyPackages.x86_64-linux;
          specialArgs = { inherit inputs outputs; };
          modules = [ ./nixos/configuration.nix ];
        };
      };

      # Home Manager config
      homeConfigurations = {
        "brian@snowflake" = home-manager.lib.homeManagerConfiguration {
          pkgs =
            # Home Manager requires 'pkgs' instance
            legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [ ./home-manager/home.nix ];
        };
      };
    };
}
