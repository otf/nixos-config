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
    apps.terraform = let
      terraform = pkgs.opentofu;
      terraformConfiguration = inputs.terranix.lib.terranixConfiguration {
        inherit system;
        modules = [
          ./config.nix
        ];
      };
    in {
      type = "app";
      program = toString (pkgs.writers.writeBash "terraform" ''
        if [[ -e config.tf.json ]]; then rm -f config.tf.json; fi
        cp ${terraformConfiguration} config.tf.json
        export $(cat .env| grep -v "#" | xargs)
        eval `ssh-agent -s`
        ssh-add ~/.ssh/id_ed25519
        ${terraform}/bin/tofu "$@"
      '');
    };
  };
}
