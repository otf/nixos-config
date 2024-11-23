{
  self,
  inputs,
  ...
}: {
  perSystem = {
    self',
    pkgs,
    system,
    ...
  }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfreePredicate = pkg:
        builtins.elem (pkgs.lib.getName pkg) [
          "google-chrome"
          "slack"
          "android-studio-stable"
          "vscode"
        ];

      config.permittedInsecurePackages = [
        "electron-27.3.11"
      ];

      overlays = [
        inputs.android-nixpkgs.overlays.default
        # ========================================
        # nixvimを無効化(他の参照あり)
        #
        # inputs.vim-plugins-overlay.overlay
        # ========================================
        inputs.purescript-overlay.overlays.default
        # self.overlays.additions
        # self.overlays.modifications
        self.overlays.unstable-packages
      ];
    };

    # Accessible through 'nix run .#activate $USER@$HOST
    legacyPackages.homeConfigurations = let
      homeModuleKeys = let
        usernames = ["otf"];
        hostnames = ["kilo" "mbp"];
      in
        builtins.concatLists (map (h: (map (u: {
            username = u;
            hostname = h;
          })
          usernames))
        hostnames);
    in
      builtins.foldl' (acc: {
        username,
        hostname,
      }:
        acc
        // {
          "${username}@${hostname}" = inputs.self.nixos-unified.lib.mkHomeConfiguration pkgs ({pkgs, ...}: {
            imports = [
              ./home.nix
            ];
            home.username = username;
            home.homeDirectory = "/${
              if pkgs.stdenv.isDarwin
              then "Users"
              else "home"
            }/${username}";
            home.stateVersion = "24.05";
          });
        }) {}
      homeModuleKeys;
  };
}
