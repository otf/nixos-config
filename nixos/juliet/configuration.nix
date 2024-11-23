{
  lib,
  pkgs,
  config,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./traefik.nix
  ];

  nix.settings.trusted-users = ["root" "@wheel"];
  security.sudo.wheelNeedsPassword = false;
  nix.settings.experimental-features = ["nix-command" "flakes"];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

  networking.hostName = "juliet";
  # networking.resolvconf.dnsExtensionMechanism = false;
  networking.defaultGateway = "172.16.0.1";
  networking.nameservers = ["127.0.0.1" "8.8.8.8"];
  # networking.resolvconf.useLocalResolver = false;
  networking.interfaces.ens18.ipv4.addresses = [
    {
      address = "172.16.1.10";
      prefixLength = 16;
    }
  ];

  users.users.otf = {
    isNormalUser = true;
    extraGroups = ["wheel"]; # Enable ‘sudo’ for the user.
  };

  environment.systemPackages = with pkgs; [
  ];

  services.openssh.enable = true;
  services.qemuGuest.enable = true;

  services.unbound = {
    enable = true;
    settings = {
      server = {
        interface = ["0.0.0.0" "::0"];
        access-control = [
          "0.0.0.0/0 refuse"
          "127.0.0.0/8 allow"
          "::1/128 allow"
          "172.16.0.0/16 allow"
        ];
        local-zone = ''"lan." static'';
        local-data = [
          ''"bravo.lan. A 172.16.1.2"''
          ''"hotel.lan. A 172.16.1.8"''
          ''"juliet.lan. A 172.16.1.10"''
          ''"kilo.lan. A 172.16.1.11"''
        ];
        # forward-zone = [
        #   {
        #     name = ".";
        #     forward-addr = ["1.1.1.1@853#cloudflare-dns.com" "1.0.0.1@853#cloudflare-dns.com"];
        #   }
        # ];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [53 80 8000 8080 8081 8083 5000 3001];
  networking.firewall.allowedUDPPorts = [53];

  services.plantuml-server = {
    enable = true;
    listenPort = 8080;
    listenHost = "0.0.0.0";
  };

  services.calibre-server = {
    enable = true;
    port = 8081;
    host = "0.0.0.0";
    libraries = ["/var/lib/calibre"];
  };

  services.calibre-web = {
    enable = true;
    listen.ip = "0.0.0.0";
    listen.port = 8083;
    user = "calibre-server";
    options = {
      enableBookUploading = true;
      calibreLibrary = "/var/lib/calibre";
    };
  };

  services.gitea = {
    enable = false;
    appName = "otf's Gitea server";
    database = {
      # type = "postgres";
      # passwordFile = config.sops.secrets."postgres/gitea_dbpass".path;
    };
    settings.server = {
      HTTP_PORT = 3001;
      ROOT_URL = "http://juliet.lan/gitea/";
    };
  };
  # sops.secrets."postgres/gitea_dbpass" = {
  #   sopsFile = ../../secrets/postgres.yaml;
  #   owner = config.services.gitea.user;
  # };

  virtualisation.oci-containers.containers = {
    archivebox = {
      image = "archivebox/archivebox:dev";
      imageFile = pkgs.dockerTools.pullImage {
        imageName = "archivebox/archivebox";
        imageDigest = "sha256:5a93892ead3c1ab1d51ed63e86935a2ff5476672b4c4d43f48b70ea97fc9e339";
        sha256 = "1gl80hk4mbyvb17f2zaa45nqsxwk8a6j3xnfr7ng7w1yffabc64h";
        finalImageName = "archivebox/archivebox";
        finalImageTag = "dev";
      };

      volumes = [
        "/var/lib/archivebox:/data"
      ];

      ports = [
        "8001:8000"
      ];

      cmd = ["server" "--quick-init" "0.0.0.0:8000"];

      environment = {
        ALLOWED_HOSTS = "*";
        SAVE_ARCHIVE_DOT_ORG = "False";
        ADMIN_USERNAME = "admin";
        ADMIN_PASSWORD = "admin";
      };
    };
  };

  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    packages = with pkgs; [
      ipafont
      ipaexfont
    ];
  };

  system.stateVersion = "23.05";
}
