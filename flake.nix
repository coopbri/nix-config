{
  description = "Personal Nix(OS) config";

  inputs = {
    # Home Manager: https://nixos.wiki/wiki/home_manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = { nixpkgs, home-manager, ... }@inputs: {
    # NixOS config
    nixosConfigurations = {
      # format: <hostname> = ...
      # Ethereum node
      snowflake = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ ./nixos/configuration.nix ];
      };
    };

    # Home Manager config
    homeConfigurations = {
      "brian@snowflake" = home-manager.lib.homeManagerConfiguration {
        pkgs =
          # Home Manager requires 'pkgs' instance
          nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { inherit inputs; };
        modules = [ ./home-manager/home.nix ];
      };
    };
  };
}
