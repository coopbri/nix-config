{ inputs, outputs, lib, config, pkgs, ... }: {
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

  # nixpkgs = {
  #   # You can add overlays here
  #   overlays = [
  #     # If you want to use overlays your own flake exports (from overlays dir):
  #     # outputs.overlays.modifications
  #     # outputs.overlays.additions

  #     # Or overlays exported from other flakes:
  #     # neovim-nightly-overlay.overlays.default

  #     # Or define it inline, for example:
  #     # (final: prev: {
  #     #   hi = final.hello.overrideAttrs (oldAttrs: {
  #     #     patches = [ ./change-hello-to-hi.patch ];
  #     #   });
  #     # })
  #   ];
  #   # Nixpkgs instance
  #   config = {
  #     # allow unfree software packages
  #     allowUnfree = true;
  #   };
  # };

  nix = {
    # add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # add inputs to the system's legacy channels
    # this makes legacy nix commands consistent as well!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}")
      config.nix.registry;

    settings = {
      # TODO disable dirty git working tree warnings
      # warn-dirty = false;
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
      # authorized SSH public keys
      #openssh.authorizedKeys.keys = [
      # TODO
      #  "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDBw2Es9HuXqIXsSQpVQ91PsQVxIyJBA1vcH0KF5/opy0xKo/Tlnm30a6q5rgQZ1pjdz5pL0SdzMfLFP+4h/j729j5QXcShdRxeJTvFXTEXvcfGJRwJPbAfchfaoEDiP7RrgskNGtaEbrir1ObUL2PCIMIlu6OHCP7U2lyymwEw+Cajq3SSAmaL73RBphtVf/WVgM6wInQFKaaxZLOCX0w+3hlAW3DFeS4OEvsa0xSlUWAkEm/H1VTPnCmJJkU3yTujFxxFFdem2zAMN8iF8dAPD+UKLxTUUv1ZttEmWH3OLMTIdgtNmsJCXgmviFa1JhM//4BXe693pMHbz6G7bZ+1tjSF43a3p7rB5GKmiAeRRFs/priChC5V9q53bCBJuk9e8k9/08sxoDVUwxCX7QUt4UM3k6xOtsKbwzG9oOaP7CXc39iegCUZHvw7Kwcf5IhlzMK8NFjHDLzCbJZ6AH8kTlJ8um2feaY0bx0m480J6JhSBDAECIPpY3gIFld8xK0= brian"
      #];
      # ! "docker" is effectively root
      extraGroups = [ "networkmanager" "wheel" "docker" ];
      # packages can be specified here, but controlled by Home Manager instead
      # packages = with pkgs; [  ];
    };
  };

  # packages installed in system profile. To search, run:
  # $ nix search $PACKAGE_NAME
  # NB: default packages: https://search.nixos.org/options?channel=unstable&show=environment.defaultPackages&from=0&size=50&sort=relevance&type=packages&query=defaultPackages
  environment.systemPackages = with pkgs; [
    gnumake
    lm_sensors
    # network utilities
    lsof
    iperf
    speedtest-cli
    # shell
    zsh
    oh-my-zsh
    # editor
    vim
    # TODO neovim
    # Kubernetes
    k3s
    # Ethereum
    erigon
    # k3sPin
    #  wget
  ];
  # ] ++ overlayPkgs;
  # };

  # inject shells into `/etc/shells`: https://nixos.wiki/wiki/Command_Shell#Changing_default_shell
  environment.shells = with pkgs; [ zsh ];

  # Erigon service
  systemd.services.erigon = {
    description = "Erigon RPC daemon";
    serviceConfig = {
      After = "network.target network-online.target";
      Wants = "network-online.target";
      ExecStart =
        # --http (RPC daemon)
	# --metrics (Grafana + Prometheus)
        "${pkgs.erigon}/bin/erigon --ws --datadir=/mnt/erigon/mainnet private.api.addr=localhost:9090 --http.api=eth,erigon,web3,net,debug,trace,txpool";
      User = "brian";
      Restart = "always";
      RestartSec = "5s";
    };
    wantedBy = [ "multi-user.target" ];
  };

  # environment.variables = [];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Fail2ban intrusion mitigation
  # https://nixos.wiki/wiki/Fail2ban
  services.fail2ban = {
    enable = true;
    # max attempts allowed before banning
    maxretry = 5;
    # ignore  IP address ranges
    ignoreIP = [
      "127.0.0.0/8"
      "10.0.0.0/8"
      "172.16.0.0/12"
      "192.168.0.0/16"
      # "8.8.8.8"
    ];
  };

  # SSH server
  services.openssh = {
    enable = true;
    # forbid SSH root login
    permitRootLogin = "no";
    # disable password authentication in favor of keys
    passwordAuthentication = false;
    # kbdInteractiveAuthentication = false;
  };

  # K3s
  # NB: node hostnames must be unique. See https://docs.k3s.io/installation/requirements#prerequisites for solutions
  services.k3s = {
    enable = false;
    role = "server";
    extraFlags = toString [
      # disable Flannel CNI in favor of Cilium
      "--flannel-backend=none"
      # disable default network policy enforcer in favor of Cilium policy enforcer
      "--disable-network-policy"
      # disable `kube-proxy` in favor of Cilium
      # ? unsure if needed
      "--disable-kube-proxy"
      # disable metrics server
      # TODO enable metrics-server
      "--disable metrics-server"
      "--disable traefik"
      # "--disable local-storage"
      # "--disable coredns"
      # use embedded etcd datastore
      # "--cluster-init"
      # "--tls-san 10.43.0.1"
    ];
  };

  # Open ports in the firewall.
  # NB: Docker can override firewall rules here (a fix will be implemented upstream in future). Track https://github.com/NixOS/nixpkgs/issues/111852
  networking.firewall = {
    allowedTCPPorts = [
      # ssh (NB: technically this is enabled by default: https://github.com/NixOS/nixpkgs/issues/19504)
      22
      # k3s API server
      6443
    ];
  };

  system.autoUpgrade.enable = true;

  # `man configuration.nix`; https://nixos.org/nixos/options.html
  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "22.05";
}
