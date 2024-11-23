# copy from https://github.com/somasis/nixos/blob/13edfc1e5ac7628d86269f8ff049c20572c6b0bb/pkgs/json2nix/default.nix
{
  lib,
  writeShellApplication,
  nix,
  coreutils,
  nixfmt,
}:
(writeShellApplication {
  name = "json2nix";

  runtimeInputs = [
    coreutils
    nix
    nixfmt
  ];

  text = builtins.readFile ./json2nix.sh;
})
// {
  meta = with lib; {
    description = "Convert JSON to Nix expressions";
    license = licenses.unlicense;
    maintainers = with maintainers; [somasis];
  };
}
