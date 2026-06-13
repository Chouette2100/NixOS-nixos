{ inputs, ... }: {
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true; # $EDITOR を nvim に設定

    # 基本設定 (vim.opt.xxx)
    opts = {
      number = true;         # 行番号表示
      relativenumber = true; # 相対行番号
      shiftwidth = 2;        # インデント幅
      tabstop = 2;
      expandtab = true;      # タブをスペースに
      smartindent = true;
      ignorecase = true;     # 検索時に大文字小文字を無視
      smartcase = true;
      termguicolors = true;  # 真彩色対応
    };

    # キーマップ設定
    keymaps = [
      {
        mode = "n";
        key = "<leader>ff";
        action = "<cmd>Telescope find_files<CR>";
        options.desc = "Find Files";
      }
    ];

    # プラグイン設定
    plugins = {
      # 見た目系
      lualine.enable = true;   # ステータスライン
      bufferline.enable = true; # タブバー
      treesitter.enable = true; # シンタックスハイライト

      # 開発便利系
      telescope.enable = true; # ファイル検索・曖昧検索
      oil.enable = true;       # ファイル操作（エディタ感覚でファイル操作できる）
      web-devicons.enable = true;

      # LSP (ここがnixvimの真骨頂)
      lsp = {
        enable = true;
        servers = {
          gopls.enable = true;    # Go用
          nixd.enable = true;     # Nix用 (nilより最近は人気)
          lua_ls.enable = true;   # Lua用
        };
      };

      # 補完系
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings.sources = [
          { name = "nvim_lsp"; }
          { name = "path"; }
          { name = "buffer"; }
        ];
        settings.mapping = {
          "<C-Space>" = "cmp.mapping.complete()";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<Tab>" = "cmp.mapping.select_next_item()";
        };
      };
    };

    # カラースキーム
    colorschemes.catppuccin.enable = true;
  };
}
