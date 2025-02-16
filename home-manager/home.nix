# Home Manager configuration; configure home environment (replaces `~/.config/nixpkgs/home.nix`)

# TODO modularize

{ inputs, outputs, lib, config, pkgs, ... }: {
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  # https://github.com/NixOS/nixpkgs/blob/4a9f9e03fcf2ad79c9383845acb9234e1c56b533/pkgs/applications/networking/cluster/k3s/default.nix#L50
  # pkgs.k3s.override { k3sVersion="1.24.8+k3s1"; }

  nixpkgs = {
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
    ];
    config = {
      allowUnfree = true;
      # workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
    };
  };

  home = {
    username = "brian";
    homeDirectory = "/home/brian";
  };

  # programs.neovim.enable = true;
  home.packages = with pkgs; [
    bat
    htop
    neofetch
    # Nix
    nixfmt
    # Docker
    docker
    docker-compose
    # Kubernetes
    kubectl
    kubernetes-helm
    cilium-cli
  ];

  # Home Manager
  programs.home-manager.enable = true;

  # zsh
  programs.zsh = {
    enable = true;
    shellAliases = {
      nup = "sudo nixos-rebuild switch --flake ~/nix-config#snowflake";
      hmup = "home-manager switch --flake ~/nix-config#brian@snowflake";
      ngc = "nix-store --gc";
      nr = "sudo nix-store --verify --check-contents --repair";
      k = "kubectl";
      cat = "bat";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };
  };

  # git
  programs.git = {
    enable = true;
    userName = "Brian Cooper";
    userEmail = "brian@brian-cooper.com";
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "22.05";
}
