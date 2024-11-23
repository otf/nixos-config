{
  inputs,
  self,
  ...
}: {
  flake = {
    darwinConfigurations.mbp = self.nixos-unified.lib.mkMacosSystem {home-manager = true;} {
      nixpkgs.hostPlatform = "aarch64-darwin";
      imports = [
        inputs.nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            # Install Homebrew under the default prefix
            enable = true;

            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = true;

            # User owning the Homebrew prefix
            user = "otf";

            # Automatically migrate existing Homebrew installations
            autoMigrate = true;
          };
        }
        ./configuration.nix
      ];
    };
  };
}
