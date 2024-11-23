{
  config,
  pkgs,
  ...
}: {
  wayland.windowManager.hyprland = {
    enable = pkgs.stdenv.isLinux;
    settings = let
      im = "fcitx5 --replace -d";
      # menu = "rofi -show drun";
      terminal = "kitty";
      fileManager = "dolphin";
    in {
      "env" = "XCURSOR_SIZE,48";
      "$mod" = "SUPER";

      exec-once = [
        im
      ];

      bind = [
        "$mod, Q, exec, ${terminal}"
        "$mod, M, exit,"
        # "$mod, R, exec, ${menu}"
        "$mod, E, exec, ${fileManager}"
      ];
    };
  };
}
