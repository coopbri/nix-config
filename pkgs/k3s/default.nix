# { lib, stdenv, fetchurl, }:
# let version = "1.24.8+k3s1";
# in stdenv.mkDerivation {
#   inherit version;
#   inherit k3sRuntimeDeps;
#   name = "k3s";
#   k3sVersion = "1.24.8+k3s1";
#   src = fetchurl {
#     url = "https://github.com/k3s-io/k3s/releases/download/v1.24.8%2Bk3s1/k3s";
#     sha256 = "sha256-qnB4C32keQYiAAo8m/40/Fsx6pjzf9n0LTf6oZ7qVJs=";
#   };
#   # unpackPhase = "tar xf $src";
#   # phases = [ "installPhase" ]; # Removes all phases except installPhase
#   unpackPhase = ":";

#   installPhase = ''
#     # wildcard to match the arm64 build too
#     install -m 0755 dist/artifacts/k3s* -D $out/bin/k3s
#     wrapProgram $out/bin/k3s \
#       --prefix PATH : ${lib.makeBinPath k3sRuntimeDeps} \
#       --prefix PATH : "$out/bin"
#   '';

# }

{ pkgs ? import <nixpkgs> { } }:
pkgs.stdenv.mkDerivation {
  name = "k3s";
  src = pkgs.fetchurl {
    url = "https://github.com/k3s-io/k3s/releases/download/v1.24.8%2Bk3s1/k3s";
    sha256 = "sha256-qnB4C32keQYiAAo8m/40/Fsx6pjzf9n0LTf6oZ7qVJs=";
  };
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/k3s
    chmod +x $out/bin/k3s
  '';
}
