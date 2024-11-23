{
  self,
  lib,
  inputs,
  ...
}: {
  perSystem = {
    config,
    self',
    inputs',
    pkgs,
    system,
    ...
  }: {
    packages.json2nix = pkgs.callPackage ./json2nix {};
    packages.scrcpy = pkgs.callPackage ./scrcpy {};
  };
}
