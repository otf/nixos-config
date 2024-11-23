{
  flake,
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    flake.inputs.nix-bitcoin.nixosModules.default
  ];
  nix-bitcoin.generateSecrets = true;

  nix-bitcoin.onionServices.bitcoind.public = true;
  nix-bitcoin.onionServices.clightning.public = false;

  services.bitcoind = {
    enable = true;
    regtest = true;
    txindex = true;
  };

  services.clightning = {
    enable = true;
  };

  services.electrs = {
    enable = true;
  };

  services.rtl = {
    enable = true;
    nodes.clightning.enable = true;
  };

  services.btcpayserver = {
    enable = true;
    lightningBackend = "clightning";
  };

  nix-bitcoin.operator = {
    enable = true;
    name = "otf";
  };

  nix-bitcoin.nodeinfo = {
    enable = true;
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      local all all trust
      host all all 127.0.0.1/32 trust
      host all all ::1/128 trust
    '';
  };
}
