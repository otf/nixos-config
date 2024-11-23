{
  inputs,
  self,
  ...
}: {
  flake = {
    darwinConfigurations.mbp = self.nixos-unified.lib.mkMacosSystem {home-manager = true;} {
      nixpkgs.hostPlatform = "aarch64-darwin";
      imports = [./configuration.nix];
    };
  };
}
