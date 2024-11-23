{
  config,
  lib,
  pkgs,
  flake,
  ...
}: {
  imports = [
    ./hyprland.nix
  ];

  config = lib.mkIf pkgs.stdenv.isLinux {
    dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        name = "rofi launcher";
        command = "rofi -show combi -normal-window";
        binding = "<Super>space";
      };

      # for Accessibility
      "org/gnome/desktop/a11y" = {
        "always-show-universal-access-status" = true;
      };

      "org/gnome/desktop/interface" = {
        "text-scaling-factor" = 1.25;
      };

      "org/gnome/desktop/interface" = {
        "cursor-size" = 64;
      };

      # for screensavors
      "org/gnome/desktop/session" = {
        "idle-delay" = "uint32 0";
      };

      "org/gnome/settings-daemon/plugins/power" = {
        "sleep-inactive-ac-type" = "nothing";
      };

      # for extensions
      "org/gnome/shell" = {
        "favorite-apps" = [
          "org.gnome.Nautilus.desktop"
          "google-chrome.desktop"
          "org.gnome.TextEditor.desktop"
          "virt-manager.desktop"
          "gnucash.desktop"
          "logseq.desktop"
          "org.gnome.Console.desktop"
        ];
        "disable-user-extensions" = false;
        "disabled-extensions" = [
        ];
        "enabled-extensions" = [
          "kimpanel@kde.org"
          "places-menu@gnome-shell-extensions.gcampax.github.com"
          "workspace-indicator@gnome-shell-extensions.gcampax.github.com"
          "caffeine@patapon.info"
          "custom-command-toggle@storageb.github.com"
          "appindicatorsupport@rgcjonas.gmail.com"
          "tailscale-status@maxgallup.github.com"
        ];
      };

      "org/gnome/shell/extensions/custom-command-toggle" = {
        "entryrow1-setting" = ''
          notify-send "Custom Command Toggle" "Hello world!"
        '';
        "entryrow2-setting" = ''
        '';
        "entryrow3-setting" = "My Button";
        "entryrow4-setting" = "face-smile-symbolic";
      };

      "org/gnome/desktop/search-providers" = {
        "disabled" = [
          "org.gnome.Epiphany.desktop"
          "org.gnome.clocks.desktop"
          "org.gnome.Settings.desktop"
          "org.gnome.Characters.desktop"
          "org.gnome.Calendar.desktop"
        ];
      };

      "org/gnome/desktop/remote-desktop/rdp" = {
        "enable" = true;
      };

      "system/locale/region" = {
        "region" = "ja_JP.UTF-8";
      };

      # for appearance
      "org/gnome/desktop/interface" = {
        "color-scheme" = "prefer-dark";
      };
      # for wallpaper
      # /org/gnome/desktop/screensaver/picture-uri
      #   'file:///run/current-system/sw/share/backgrounds/gnome/pills-l.jpg'
      # /org/gnome/desktop/screensaver/primary-color
      #   '#d3a778'
    };
    # home.file = builtins.listToAttrs (
    #   map
    #   (pkg: {
    #     name = ".config/autostart/" + pkg.pname + ".desktop";
    #     value =
    #       if pkg ? desktopItem
    #       then {
    #         text = pkg.desktopItem.text;
    #       }
    #       else {
    #         source = pkg + "/share/applications/" + pkg.pname + ".desktop";
    #       };
    #   })
    #   [
    #     pkgs.tailscale-systray
    #   ]
    # );
    # xdg.configFile."autostart/tailscale-systray.desktop".text = ''
    #   [Desktop Entry]
    #   Type=Application
    #   Exec=${pkgs.tailscale-systray}/bin/tailscale-systray
    #   Hidden=false
    #   NoDisplay=false
    #   X-GNOME-Autostart-enabled=true
    #   Name=Tailscale Systray
    # '';
    home.packages = let
      note =
        pkgs.writeShellScriptBin "note"
        ''
          source ~/.config/notion/notion.env
          body=$(jq -n \
            --arg database_id "$NOTION_DATABASE_ID" \
            --arg content "$1" \
            '{parent: {database_id: $database_id}, properties: {title:{title:[{text:{content: $content}}]}}}'
          )

          response=$(curl -X POST \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $NOTION_KEY" \
            -H "Notion-Version: 2021-08-16" --data "$body" https://api.notion.com/v1/pages)

          echo $response
          xdg-open $(echo $response | jq -r '.url')
        '';
    in
      with pkgs; [
        thunderbird
        libnotify
        skk-dicts
        skktools
        flake.inputs.nix-software-center.packages.x86_64-linux.nix-software-center
        google-chrome
        slack
        firefox
        # xfce.thunar
        wl-clipboard
        keepassxc
        gnome.adwaita-icon-theme
        gnome.pomodoro
        gnomeExtensions.appindicator
        freeplane
        gimp
        inkscape
        waydroid
        gnome.gnome-sound-recorder
        gnucash
        libqalculate
        note
      ];

    programs = {
      vscode = {
        enable = true;
      };
      waybar = {
        enable = true;
      };
      rofi = {
        enable = true;
        terminal = "kgx";
        extraConfig = let
          systemScript = pkgs.writeShellScriptBin "system" ''
            set -euCo pipefail

            function main() {
              local -Ar menu=(
                ['Lock']='dm-tool lock'
                ['Logout']='i3-msg exit'
                ['Poweroff']='systemctl poweroff'
                ['Reboot']='systemctl reboot'
                ['Note']='note'
              )

              local -r IFS=$'\n'
              [[ $# -ne 0 ]] && eval "''${menu[$1]}" || echo "''${!menu[*]}"
            }

            main $@
          '';
        in {
          modi = "combi,calc,system:${systemScript}/bin/system";
          combi-modi = "window,drun";
          sidebar-mode = true;
        };
        theme = "Arc-Dark";
        location = "center";
        font = "MonaspiceNe Nerd Font Mono 24";
        plugins = [pkgs.rofi-calc pkgs.rofi-emoji];
      };
      kitty = {
        enable = false;
        font = {
          name = "MonaspiceNe Nerd Font Mono";
          size = 16;
        };
      };
      wezterm = {
        enable = false;
        extraConfig = ''
          local wezterm = require 'wezterm'

          local config = {}

          if wezterm.config_builder then
            config = wezterm.config_builder()
          end

          config.color_scheme = 'Catppuccin Frappé (Gogh)'
          config.window_background_opacity = 0.8
          config.enable_tab_bar = false;

          return config
        '';
      };
    };
  };
}
