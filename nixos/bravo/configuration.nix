{
  lib,
  pkgs,
  config,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
    ./redmine.nix
  ];
  # ++ (pkgs.optionals (pkgs.stdenv.isLinux && pkgs.stdenv.isx86_64) [
  #   ./proxmox.nix
  # ]);

  nix.settings.trusted-users = ["root" "otf" "@wheel"];
  security.sudo.wheelNeedsPassword = false;
  nix.settings.experimental-features = ["nix-command" "flakes"];

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh.enable = true;
  services.qemuGuest.enable = true;

  services.cloud-init = {
    btrfs.enable = true;
    settings = {
      datasource_list = ["NoCloud" "ConfigDrive"]; # for proxmox ve
    };
  };

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.cowsay
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

  networking.hostName = "bravo";
  # networking.resolvconf.dnsExtensionMechanism = false;
  networking.defaultGateway = "172.16.0.1";
  networking.nameservers = ["172.16.1.10" "8.8.8.8"];
  # networking.resolvconf.useLocalResolver = false;
  networking.interfaces.ens18.ipv4.addresses = [
    {
      address = "172.16.1.2";
      prefixLength = 16;
    }
  ];

  users.users = pkgs.lib.genAttrs ["otf"] (username: {
    isNormalUser = true;
    extraGroups = [
      "libvirtd"
      "wheel"
      "audio"
      "sound"
      "video"
      "networkmanager"
      "input"
      "tty"
      "docker"
      "kvm"
      "adbusers"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB21ugHVP5YtoYQEc/mt3w/rgeomYojgpfK9DC0oDbRl"
    ];
  });

  networking.firewall.allowedTCPPorts = [5000];
  networking.firewall.allowedUDPPorts = [];

  system.stateVersion = "24.05";
}
