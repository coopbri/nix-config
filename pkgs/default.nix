# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example' or (legacy) 'nix-build -A example'

# { pkgs ? (import ../nixpkgs.nix) { } }: {
#   example = pkgs.callPackage ./example { };
# }

{ pkgs ? null, ... }: {
  # example = pkgs.callPackage ./example { };
#  k3s = pkgs.callPackage ./k3s { };
}
