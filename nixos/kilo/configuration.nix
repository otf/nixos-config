{
  flake,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./development.nix
  ];

  nix.settings.trusted-users = ["root" "@wheel"];
  security.sudo.wheelNeedsPassword = false;
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.sandbox = "relaxed";

  nixpkgs.config.pulseaudio = true;
  nixpkgs.config.cudaSupport = true;

  # for GPU passthrough(GeForce GTX 1650)
  # boot.kernelParams = ["intel_iommu=on"];
  # boot.kernelModules = ["vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virtqfd"];
  # boot.extraModprobeConfig = "options vfio-pci ids=10de:1f82,10de:10fa";

  boot.kernelPackages = pkgs.linuxPackages_6_6;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "kilo";
  networking.useDHCP = false;
  # networking.resolvconf.dnsExtensionMechanism = false;
  networking.defaultGateway = "172.16.0.1";

  # juliet's DNS and google dns
  networking.nameservers = ["172.16.1.10" "8.8.8.8"];
  networking.interfaces.eno1.ipv4.addresses = [
    {
      address = "172.16.1.11";
      prefixLength = 16;
    }
  ];
  networking.firewall.enable = false;

  sound.enable = true;
  hardware.pulseaudio.enable = true;

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
      "vboxusers"
      "vboxsf"
      "docker"
      "kvm"
      "adbusers"
    ];
  });

  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [
    "en_US.UTF-8/UTF-8"
    "ja_JP.UTF-8/UTF-8"
  ];
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-gtk
        fcitx5-skk
        fcitx5-skk-qt
        libsForQt5.fcitx5-qt
      ];
      settings.inputMethod = {
        "Groups/0" = {
          "Name" = "Default";
          "Default Layout" = "us";
          "DefaultIM" = "skk";
        };
        "Groups/0/Items/0"."Name" = "skk";
        "GroupOrder"."0" = "Default";
      };
      settings.addons = {
        skk.globalSection."InitialInputMode" = "Latin";
      };
    };
  };

  services.dbus.packages = [config.i18n.inputMethod.package];

  services.greetd = {
    enable = false;
    settings = {
      default_session = let
        gnome-script = pkgs.writeShellScriptBin "gnome-script" ''
          export XDG_SESSION_TYPE=wayland
          ${pkgs.dbus}/bin/dbus-run-session ${pkgs.gnome.gnome-session}/bin/gnome-session
        '';
        # gnome-desktop = pkgs.makeDesktopItem {
        #   name = "gnome-desktop";
        #   desktopName = "Gnome Desktop";
        #   exec = "${gnome-script}/bin/gnome-script";
        #   terminal = true;
        # };
      in {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet \
          --cmd 'bash --login'";
        user = "otf";
      };
    };
    vt = 2;
  };

  services.openssh.enable = true;
  services.tailscale.enable = false;

  services.ollama = {
    enable = true;
    listenAddress = "127.0.0.1:11434";
  };

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # services.xrdp.enable = true;
  # services.xrdp.defaultWindowManager = "${pkgs.gnome.gnome-session}/bin/gnome-session";
  # services.xrdp.openFirewall = true;

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;

  environment.systemPackages = with pkgs; [
    gnome-extension-manager
    gnomeExtensions.caffeine
    gnomeExtensions.kimpanel
    gnomeExtensions.appindicator

    llm
    aichat
  ];

  environment.gnome.excludePackages = with pkgs; [
    xterm
    yelp
    gnome-tour
    gnome.epiphany # web browser
    gnome.geary # email reader
    gnome.evince # document reader
    gnome.totem # video player
    gnome.gnome-music
    gnome.gnome-maps
  ];
  services.udev.packages = with pkgs; [
    gnome.gnome-settings-daemon
    pkgs.android-udev-rules
  ];

  services.udev.extraRules = ''
    # probably not needed:
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="d13e", ATTRS{idProduct}=="cc10", GROUP="plugdev", MODE="0666"

    # required:
    # from <https://github.com/signal11/hidapi/blob/master/udev/99-hid.rules>
    KERNEL=="hidraw*", ATTRS{idVendor}=="d13e", ATTRS{idProduct}=="cc10", GROUP="plugdev", MODE="0666"
  '';

  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  fonts = {
    packages = with pkgs; [
      monaspace
      # nerdfonts
      noto-fonts-cjk-serif
      noto-fonts-cjk-sans
      noto-fonts-emoji
    ];
    fontDir.enable = true;
    fontconfig = {
      defaultFonts = {
        serif = ["Noto Serif CJK JP"];
        sansSerif = ["Noto Sans CJK JP"];
        monospace = ["MonaspiceNe Nerd Font Mono"];
        emoji = ["Noto Color Emoji"];
      };
    };
  };

  environment.sessionVariables = {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    #   WLR_NO_HARDWARE_CURSOS = "1";
    #   WLR_RENDERER_ALLOW_SOFTWARE = "1";
    #   NIXOS_OZONE_WL = "1";
  };

  networking.nat.enable = true;
  networking.nat.externalInterface = "eno1";
  networking.nat.internalInterfaces = ["wg0"];
  networking.firewall = {
    allowedUDPPorts = [51820];
  };

  # server
  # networking.wireguard.interfaces = {
  #   # "wg0" is the network interface name. You can name the interface arbitrarily.
  #   wg0 = {
  #     # Determines the IP address and subnet of the server's end of the tunnel interface.
  #     ips = ["10.101.0.1/24"];

  #     # The port that WireGuard listens to. Must be accessible by the client.
  #     listenPort = 51820;

  #     # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
  #     # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
  #     postSetup = ''
  #       ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.101.0.0/24 -o eno1 -j MASQUERADE
  #     '';

  #     # This undoes the above command
  #     postShutdown = ''
  #       ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.101.0.0/24 -o eno1 -j MASQUERADE
  #     '';

  #     # Path to the private key file.
  #     #
  #     # Note: The private key can also be included inline via the privateKey option,
  #     # but this makes the private key world-readable; thus, using privateKeyFile is
  #     # recommended.
  #     privateKeyFile = "./wireguard-keys/private";

  #     peers = [
  #       # List of allowed peers.
  #       # {
  #       #   # Feel free to give a meaning full name
  #       #   # Public key of the peer (not a file path).
  #       #   publicKey = "{client public key}";
  #       #   # List of IPs assigned to this peer within the tunnel subnet. Used to configure routing.
  #       #   allowedIPs = ["10.100.0.2/32"];
  #       # }
  #     ];
  #   };
  # };

  # systemd.services."hello-world" = {
  #   script = ''
  #     set -eu
  #     ${pkgs.coreutils}/bin/echo "Hello World"
  #   '';
  #   serviceConfig = {
  #     OnCalendar = "daily";
  #     Persistent = true;
  #   };
  # };

  system.stateVersion = "23.11";
}
