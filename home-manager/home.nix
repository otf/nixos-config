{
  flake,
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    flake.inputs.nix-colors.homeManagerModule
    flake.inputs.nix-index-database.hmModules.nix-index
    ./desktop.nix
    ./darwin.nix
    ./nixvim.nix
    ./mobile-development.nix
  ];

  home.packages = with pkgs; [
    dnsutils
    ghq
    fx
    # json2nix
    nix-bash-completions
    chafa
    coq
    coqPackages.coqide
    scrcpy
    tig
    devbox
    aichat
    translate-shell
    typst
  ];

  programs = {
    command-not-found.enable = false;
    nix-index-database.comma.enable = true;
    nix-index.enableBashIntegration = true;

    eza.enable = true;
    fd.enable = true;
    ripgrep.enable = true;
    skim = {
      enable = true;
      enableBashIntegration = true;
    };
    yazi = {
      enable = true;
      enableBashIntegration = true;
    };

    home-manager.enable = true;
    bash = {
      enable = true;
      enableCompletion = true;
      sessionVariables = {
        EDITOR = "hx";
      };
      initExtra = ''
        source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
        ${lib.optionalString pkgs.stdenv.isDarwin "eval \"$(/opt/homebrew/bin/brew shellenv)\""}
        ${lib.optionalString pkgs.stdenv.isDarwin "export PATH=$PATH:~/.cargo/bin"}

        eval "$(zellij setup --generate-completion bash)"

        HISTSIZE=5000
        HISTIGNORE="fg*:bg*:history*:h*"

        function share_history {
          history -a
          history -c
          history -r
        }
        PROMPT_COMMAND='share_history'
        export HISTCONTROL=ignoreboth

        _aichat_bash() {
            if [[ -n "$READLINE_LINE" ]]; then
                  READLINE_LINE=$(aichat -e "$READLINE_LINE")
                  READLINE_POINT=''${#READLINE_LINE}
            fi
        }
        bind -x '"\ee": _aichat_bash'

        export PATH="$PATH":"$HOME/.pub-cache/bin"
        # export ANDROID_HOME="$HOME/.android/sdk"
        # export NDK_HOME="$HOME/.android/sdk/ndk/25.0.8775105"
      '';
    };
    git = {
      enable = true;
      extraConfig = {
        init.defaultBranch = "main";
        core.user.name = "otf";
        core.user.email = "otf@me.com";
      };
      delta.enable = true;
    };

    zellij = {
      enable = true;
      enableBashIntegration = true;
      settings = {
        copy_command =
          if pkgs.stdenv.isDarwin
          then "pbcopy"
          else "wl-copy";
      };
    };

    helix = {
      # HEADビルドをする場合にはコメントを解除してください。
      # package = flake.inputs.helix.packages.${pkgs.stdenv.hostPlatform.system}.helix;
      enable = true;
      settings = {
        theme = "catppuccin_frappe";
        editor.true-color = true;
      };
      defaultEditor = true;
      languages = {
        # language-server.typescript-language-server = with pkgs.nodePackages; {
        #   command = "${typescript-language-server}/bin/typescript-language-server";
        #   args = ["--stdio"];
        #   config.hostInfo = "helix";
        # };
        language-server.rust-analyzer = {
          command = "${pkgs.rust-analyzer}/bin/rust-analyzer";
        };
        language-server.purescript-language-server = {
          command = "${pkgs.purescript-language-server}/bin/purescript-language-server";
        };
        language-server.elm-language-server = {
          command = "${pkgs.elmPackages.elm-language-server}/bin/elm-language-server";
        };
        language = [
          {
            name = "javascript";
            language-servers = [];
            formatter = {
              command = "${pkgs.nodePackages.prettier}/bin/prettier";
              args = ["--parser" "typescript"];
            };
            auto-format = true;
          }
          {
            name = "typescript";
            language-servers = [];
            formatter = {
              command = "${pkgs.nodePackages.prettier}/bin/prettier";
              args = ["--parser" "typescript"];
            };
            auto-format = true;
          }
          {
            name = "rust";
            language-servers = [
              "rust-analyzer"
            ];
            formatter = {
              command = "${pkgs.rustfmt}/bin/rustfmt";
              args = ["-q" "--emit=stdout"];
            };
            auto-format = true;
          }
          {
            name = "nix";
            formatter.command = "${pkgs.alejandra}/bin/alejandra";
            auto-format = true;
          }
          {
            name = "elm";
            language-servers = ["elm-language-server"];
            formatter = {
              command = "${pkgs.elmPackages.elm-format}/bin/elm-format";
              args = ["--stdin"];
            };
            auto-format = true;
          }
          {
            name = "purescript";
            language-servers = ["purescript-language-server"];
            formatter = {
              command = "${pkgs.purs-tidy}/bin/purs-tidy";
              args = ["format"];
            };
            auto-format = true;
          }
        ];
      };
    };

    bat.enable = true;
    starship.enable = true;
    zoxide = {
      enable = true;
      enableBashIntegration = true;
    };

    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };

    ssh = {
      enable = true;
      matchBlocks = {
        "bravo" = {
          hostname = "172.16.1.2";
          user = "otf";
        };
        "hotel" = {
          hostname = "172.16.1.8";
          user = "otf";
        };
        "juliet" = {
          hostname = "172.16.1.10";
          user = "otf";
        };
        "kilo" = {
          hostname = "172.16.1.11";
          user = "otf";
        };
      };
    };

    gh.enable = true;
    jq.enable = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
