{
  # inject custom packages
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
    # k3s = prev.k3s.overrideAttrs (oldAttrs: rec {
    k3s = prev.k3s.overrideAttrs (oldAttrs: {
      src = final.fetchFromGitHub {
        owner = "k3s-io";
        repo = "k3s";
        rev = "648004e4faeaf9e8705386342e95ec9bd211c2b8";
        # If you don't know the hash, the first time, set:
        # sha256 = "0000000000000000000000000000000000000000000000000000";
        # then nix will fail the build with such an error message:
        # hash mismatch in fixed-output derivation '/nix/store/m1ga09c0z1a6n7rj8ky3s31dpgalsn0n-source':
        # wanted: sha256:0000000000000000000000000000000000000000000000000000
        # got:    sha256:173gxk0ymiw94glyjzjizp8bv8g72gwkjhacigd1an09jshdrjb4
        # nix-prefetch-url --unpack $URL
        # sha256 = "0000000000000000000000000000000000000000000000000000";
        sha256 = "sha256-IvRnG/23A9ZyIjFpNpRzgtbsMPSytbN5Boo/KExLSyE=";
      };
    });
  };
}
