{
  pkgs,
  config,
  ...
}: {
  services.nix-daemon.enable = true;
  nix.settings.experimental-features = "nix-command flakes";
  nix.settings.sandbox = "relaxed";
  nix.linux-builder.enable = true;
  nix.settings.trusted-users = ["otf"];

  homebrew.enable = true;
  homebrew.brews = [
    "wireguard-tools"
  ];
  homebrew.casks = [
    "docker"
    "iterm2"
    "karabiner-elements"
  ];
  homebrew.masApps = {
    Xcode = 497799835;
  };

  environment.systemPackages = with pkgs; [
  ];

  environment.shells = with pkgs; [
    bashInteractive
  ];

  services.tailscale.enable = true;

  system.stateVersion = 4;
}
