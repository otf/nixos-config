{
  flake,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
  ];

  services.redmine = {
    port = 5000;
    enable = true;
    plugins = {
      redmine_issues_panel = builtins.fetchurl {
        url = "https://github.com/redmica/redmine_issues_panel/archive/refs/tags/v1.0.3.zip";
        sha256 = "sha256-Bt86f21Cp/NmkByjAxVIaDKSimxcI/8FSDHRgQfcy/A=";
      };
    };
    database = {
      host = "localhost";
      port = 5432;
      type = "postgresql";
      name = "redmine";
      user = "redmine";
      # passwordFile = "";
      # -> "/run/keys/redmine-dbpassword"
    };
  };

  # systemd.timers."shutdown-redmine" = {
  #   wantedBy = ["timers.target"];
  #   timerConfig = {
  #     OnCalendar = "Mon..Fri 18:10";
  #     Unit = "shutdown-redmine.service";
  #   };
  # };

  # systemd.services."shutdown-redmine" = {
  #   script = ''
  #     systemctl stop redmine
  #   '';
  #   serviceConfig = {
  #     Type = "oneshot";
  #     User = "root";
  #   };
  # };
}
