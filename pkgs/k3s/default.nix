let version = "1.24.8+k3s1";
in stdenv.mkDerivation {
  inherit version;
  name = "k3s";
  src = fetchurl {
    url = "https://github.com/k3s-io/k3s/releases/download/v1.24.8%2Bk3s1/k3s";
    sha256 = "sha256-IvRnG/23A9ZyIjFpNpRzgtbsMPSytbN5Boo/KExLSyE=";
  };
}

