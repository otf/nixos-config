{
  config,
  pkgs,
  flake,
  ...
}: {
  imports = [
    flake.inputs.nixvim.homeManagerModules.nixvim
  ];

  programs.nixvim = {
    enable = true;
    vimAlias = true;
    plugins.lightline.enable = true;
    # colorschemes.catppuccin = {
    #   enable = true;
    #   flavour = "frappe";
    # };
    extraPlugins = with pkgs.vimPlugins; [
      vim-nix
      vim-easymotion
      vim-easy-align
      vim-fugitive
      fzf-vim
      denops-vim
      # {
      #   plugin = skkeleton;
      #   config = ''
      #     " 辞書を読み込む
      #     imap <C-j> <Plug>(skkeleton-enable)
      #     cmap <C-j> <Plug>(skkeleton-enable)
      #   '';
      # }
    ];
    plugins.lazy = {
      enable = true;
      plugins = [
        {
          name = "skkeleton";
          # config = ''
          #   " 辞書を読み込む
          #   imap <C-j> <Plug>(skkeleton-enable)
          #   cmap <C-j> <Plug>(skkeleton-enable)
          # '';
          pkg = pkgs.vimUtils.buildVimPlugin {
            name = "skkeleton";
            src = pkgs.fetchFromGitHub {
              owner = "vim-skk";
              repo = "skkeleton";
              rev = "1791a21f8e60907526b05b7d28c76429f375133d";
              hash = "sha256-86eVr7s3PcD2rnZ3/86AMc72LydObQzWaVsiwOYpfCI=";
              fetchSubmodules = false;
            };
          };
          dependencies = with pkgs.vimPlugins; [
            denops-vim
          ];
          lazy = false;
        }
      ];
    };
    plugins.lsp = {
      enable = false;
      servers = {
        nixd.enable = true;
      };
    };

    globals.mapleader = ",";
    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
      wrap = false;
      swapfile = false;
      backup = false;
    };
    extraConfigVim = ''
      let g:denops#deno = '${pkgs.deno}/bin/deno'
      let g:EasyMotion_do_mapping = 0

      map f <Plug>(easymotion-bd-f)
      nmap f <Plug>(easymotion-overwin-f)
      nmap s <Plug>(easymotion-overwin-f2)

      map <Space> <Plug>(easymotion-s2)
      map <Leader>j <Plug>(easymotion-j)
      map <Leader>k <Plug>(easymotion-k)

      xmap ga <Plug>(EasyAlign)
      nmap ga <Plug>(EasyAlign)
    '';
  };
}
