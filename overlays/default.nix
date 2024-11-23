# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  # additions = final: _prev: final // self.packages;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
    gnucash = prev.gnucash.overrideAttrs (oldAttrs: {
      desktopItem = prev.makeDesktopItem {
        type = "Application";
        name = "GnuCash";
        exec = "LANG=ja_JP ${prev.gnucash}/bin/gnucash %f";
        icon = "${prev.gnucash}/share/gnucash/pixmaps/gnucash-icon.ico";
        genericName = "Finance Management";
        comment = "Manage your finances, accounts, and investments";
        desktopName = "GnuCash";
        categories = ["Office" "Finance"];
      };
    });

    fx = prev.fx.overrideAttrs (oldAttrs: {
      postInstall = ''
        mv $out/bin/fx $out/bin/fj
      '';
      meta.mainProgram = "fj";
    });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
