{
  inputs,
  self,
  ...
}: {
  flake = {
    deploy.nodes.bravo = {
      hostname = "bravo";

      profiles.system = {
        sshUser = "otf";
        user = "root";
        path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.bravo;
        remoteBuild = true;
      };
    };
    deploy.nodes.juliet = {
      hostname = "juliet";

      profiles.system = {
        sshUser = "otf";
        user = "root";
        path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.juliet;
        remoteBuild = true;
      };
    };
    deploy.nodes.kilo = {
      hostname = "kilo";

      profiles.system = {
        sshUser = "otf";
        user = "root";
        path = inputs.deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.kilo;
        remoteBuild = true;
      };
    };
  };
}
