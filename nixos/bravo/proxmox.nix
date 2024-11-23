{
  flake,
  lib,
  pkgs,
  ...
}:
pkgs.optionalAttrs (pkgs.stdenv.isLinux && pkgs.stdenv.isx86_64) {
  nixpkgs.overlays = [
    flake.inputs.proxmox-nixos.overlays.x86_64-linux
  ];

  services.proxmox-ve.enable = true;
}
