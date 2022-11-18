{ inputs, outputs, lib, config, pkgs, ... }:
# ? necessary?
# with builtins;
# let
#   k3sPin = import (builtins.fetchTarball {
#     name = "k3s-1-24";
#     url =
#       "https://github.com/nixos/nixpkgs/archive/ee01de29d2f58d56b1be4ae24c24bd91c5380cea.tar.gz";
#       sha256="0829fqp43cp2ck56jympn5kk8ssjsyy993nsp0fjrnhi265hqps7"
#   }) { };
# in with lib; {
# let
# pkgs = import (builtins.fetchTarball {
#   # nixpkgsUnstable2022_09_05 = import (builtins.fetchTarball {
#   url =
#     "https://github.com/NixOS/nixpkgs/archive/ee01de29d2f58d56b1be4ae24c24bd91c5380cea.tar.gz";
#   # sha256 can be calculated with nix-prefetch-url --unpack $URL
#   sha256 = "0829fqp43cp2ck56jympn5kk8ssjsyy993nsp0fjrnhi265hqps7";
# }) { };

# k3sPin = pkgs.k3s;
# overlayPkgs = with nixpkgs; [ overlays.k3s ];
# in {
{
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # generated configuration from hardware scan
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays your own flake exports (from overlays dir):
      # outputs.overlays.modifications
      # outputs.overlays.additions

      # Or overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })

      # TODO remove below in favor of import file (above)
      # (final: prev: {
      #   # example = prev.example.overrideAttrs (oldAttrs: rec {
      #   # ...
      #   # });
      #   # k3s = prev.k3s.overrideAttrs (oldAttrs: rec {
      #   k3s = prev.k3s.overrideAttrs (oldAttrs: {
      #     src = final.fetchFromGitHub {
      #       owner = "k3s-io";
      #       repo = "k3s";
      #       rev = "648004e4faeaf9e8705386342e95ec9bd211c2b8";
      #       # If you don't know the hash, the first time, set:
      #       # sha256 = "0000000000000000000000000000000000000000000000000000";
      #       # then nix will fail the build with such an error message:
      #       # hash mismatch in fixed-output derivation '/nix/store/m1ga09c0z1a6n7rj8ky3s31dpgalsn0n-source':
      #       # wanted: sha256:0000000000000000000000000000000000000000000000000000
      #       # got:    sha256:173gxk0ymiw94glyjzjizp8bv8g72gwkjhacigd1an09jshdrjb4
      #       sha256 = "0000000000000000000000000000000000000000000000000000";
      #     };
      #   });
      # })
      # TODO ^^^
    ];
    # Nixpkgs instance
    config = {
      # allow unfree software packages
      allowUnfree = true;
    };
  };

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}")
      config.nix.registry;

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;
    };
  };

  # overlayPkgs = [ outputs.overlays.k3s ];

  # hostname
  networking.hostName = "snowflake";

  # bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # networking
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  # ! Unsure if below is required (check default)
  networking.wireless.enable = false;
  networking.networkmanager.enable = true;

  # timezone
  time.timeZone = "America/Chicago";

  # i18n
  i18n.defaultLocale = "en_US.utf8";

  # X11 keymap
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # default shell
  users.defaultUserShell = pkgs.zsh;

  # virtualization
  virtualisation.docker.enable = true;

  # user config
  users.users = {
    brian = {
      # TODO: You can set an initial password for your user.
      # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
      # Be sure to change it (using passwd) after rebooting!
      # initialPassword = "correcthorsebatterystaple";
      isNormalUser = true;
      description = "brian";
      # openssh.authorizedKeys.keys = [
      # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
      # ];
      # ! "docker" is effectively root
      extraGroups = [ "networkmanager" "wheel" "docker" ];
      # ?
      # packages = with pkgs; [ vim ];
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # NB: default packages: https://search.nixos.org/options?channel=unstable&show=environment.defaultPackages&from=0&size=50&sort=relevance&type=packages&query=defaultPackages
  # let
  #  in {
  environment.systemPackages = with pkgs; [
    # shell
    zsh
    oh-my-zsh
    # editor
    vim
    # TODO neovim
    # Kubernetes
    k3s
    # k3sPin
    #  wget
    # Required for `k3s`: https://github.com/rancher/k3os/issues/702#issuecomment-849175078
    # apparmor-parser
  ];
  # ] ++ overlayPkgs;
  # };

  # inject shells into `/etc/shells`: https://nixos.wiki/wiki/Command_Shell#Changing_default_shell
  environment.shells = with pkgs; [ zsh ];

  # environment.variables = [];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # SSH server
  services.openssh = {
    enable = true;
    # forbid SSH root login
    permitRootLogin = "no";
    # TODO disable password authentication in favor of keys
    # passwordAuthentication = false;
  };

  services.k3s = {
    enable = true;
    # NB: node hostnames must be unique. See https://docs.k3s.io/installation/requirements#prerequisites for solutions
    role = "server";
    extraFlags = toString [
      # disable Flannel CNI in favor of Cilium
      "--flannel-backend=none"
      # disable default network policy enforcer in favor of Cilium policy enforcer
      "--disable-network-policy"
      # "--kubelet-arg=v=4" # Optionally add additional args to k3s
      # TODO enable metrics-server
      "--disable metrics-server"
    ];
  };

  # Open ports in the firewall.
  networking.firewall = {
    #    enable = true;
    allowedTCPPorts = [
      # 22 (enabled by default)
      # k3s API server
      6443
    ];
  };
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # system.autoUpgrade.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "22.05";
}
