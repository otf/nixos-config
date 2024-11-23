{
  lib,
  pkgs,
  config,
  ...
}: {
  services.traefik = {
    enable = true;

    dynamicConfigOptions = {
      http = {
        # plantuml
        services.plantuml = {
          loadBalancer = {
            servers = [{url = "http://127.0.0.1:8080";}];
          };
        };
        routers.plantuml = {
          rule = "PathPrefix(`/plantuml`)";
          entryPoints = ["web"];
          service = "plantuml";
        };

        # gitea
        middlewares.gitea = {
          replacepathregex = {
            regex = "^/gitea/(.*)";
            replacement = "/$1";
          };
        };
        services.gitea = {
          loadBalancer = {
            servers = [{url = "http://127.0.0.1:3001";}];
          };
        };
        routers.gitea = {
          rule = "PathPrefix(`/gitea`)";
          entryPoints = ["web"];
          service = "gitea";
          middlewares = ["gitea"];
        };

        # dashboard
        routers.dashboard = {
          rule = "PathPrefix(`/`)";
          entryPoints = ["web"];
          service = "api@internal";
        };
      };
    };
    staticConfigOptions = {
      api.dashboard = true;
      global = {
        checkNewVersion = false;
        sendAnonymousUsage = false;
      };

      entryPoints.web.address = ":80";
      # entryPoints.websecure.address = ":443";
      accessLog = {}; # enabled
      log.level = "info";
    };
  };

  system.stateVersion = "23.05";
}
