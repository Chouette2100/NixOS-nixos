{ inputs, ... }: {
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  programs.nixvim.version.enableNixpkgsReleaseCheck = false;

  programs.nixvim = {
    enable = true;
    defaultEditor = true; # $EDITOR を nvim に設定

    # 1. リーダーキーを「スペース」に設定 (LazyVimと同じ)
    globals.mapleader = " ";

    # 2. キー操作をガイドするメニュー (which-key) を有効化
    plugins.which-key = {
      enable = true;
      # メニューの見た目や挙動を細かく設定できますが、まずはデフォルトでOK
    };

    # 3. ファイラー (Neo-tree) の導入 (LazyVimで使われているもの)
    plugins.neo-tree = {
      enable = true;
    # closeIfLastWindow = true;
      settings.close_if_last_window = true; # Neo-treeが最後のウィンドウなら自動で閉じる設定
    };

    # Copilot 本体の設定
    plugins.copilot-lua = {
      enable = true;
      settings = {
        suggestion = {
          enabled = true;
          auto_trigger = true; # 入力中に自動で提案を出す
          keymap = {
            accept = "<M-l>"; # Alt + l で提案を確定 (LazyVimのデフォルトに近い)
            next = "<M-]>";   # Alt + ] で次の候補
            prev = "<M-[>";   # Alt + [ で前の候補
            dismiss = "<C-]>"; # Ctrl + ] でキャンセル
          };
        };
        panel = {
          enabled = true; # スペース + cp などで別ウィンドウに候補一覧を出す設定
        };
        filetypes = {
          markdown = true; # markdownでも有効にする
          help = false;
          gitcommit = false;
          "." = false;
        };
      };
    };

    plugins.copilot-chat = {
      enable = true;
    };

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
      completeopt = "menu,menuone,noselect"; # CopilotChat / cmp の補完を安定させる
    };

    # キーマップ設定
    keymaps = [

      #   ウィンドウ移動を Ctrl + hjkl に割り当てる
      { mode = "n"; key = "<C-h>"; action = "<C-w>h"; }
      { mode = "n"; key = "<C-j>"; action = "<C-w>j"; }
      { mode = "n"; key = "<C-k>"; action = "<C-w>k"; }
      { mode = "n"; key = "<C-l>"; action = "<C-w>l"; }

      #  ウィンドウサイズ変更を Alt + 矢印 に割り当てる
      { mode = "n"; key = "<A-Up>"; action = "<cmd>resize +2<cr>"; }
      { mode = "n"; key = "<A-Down>"; action = "<cmd>resize -2<cr>"; }
      { mode = "n"; key = "<A-Left>"; action = "<cmd>vertical resize -2<cr>"; }
      { mode = "n"; key = "<A-Right>"; action = "<cmd>vertical resize +2<cr>"; }

      # ターミナルモードで Esc を押すとノーマルモードに戻る
      { mode = "t"; key = "<Esc>"; action = "<C-\\><C-n>"; }
  
      # ターミナルモードから直接他のウィンドウへ移動できるようにする
      { mode = "t"; key = "<C-h>"; action = "<C-\\><C-n><C-w>h"; }
      { mode = "t"; key = "<C-j>"; action = "<C-\\><C-n><C-w>j"; }
      { mode = "t"; key = "<C-k>"; action = "<C-\\><C-n><C-w>k"; }
      { mode = "t"; key = "<C-l>"; action = "<C-\\><C-n><C-w>l"; }

      # スペース + ff でファイル検索 (Telescope)
      {
        mode = "n";
        key = "<leader>ff";
        action = "<cmd>Telescope find_files<CR>";
        options.desc = "Find Files";
      }

      # スペース + e でファイラー（Neo-tree）を開く
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>Neotree toggle<CR>";
        options = {
          desc = "Explorer (Neo-tree)";
        };
      }

      # スペース + / でライブグレップ（全文検索）
      {
        mode = "n";
        key = "<leader>/";
        action = "<cmd>Telescope live_grep<CR>";
        options = {
          desc = "Grep (Root Dir)";
        };
      }

      # Copilot Chat 関連のキーマップ
      # チャットウィンドウをトグル（開閉）する
      {
        mode = "n";
        key = "<leader>cc"; # Copilot Chat の略
        action = "<cmd>CopilotChatToggle<CR>";
        options = {
          desc = "Toggle Copilot Chat";
        };
      }

      # 選択した範囲に対して説明を求める（ビジュアルモード）
      {
        mode = "v";
        key = "<leader>ce"; # Copilot Explain
        action = "<cmd>CopilotChatExplain<CR>";
        options = {
          desc = "CopilotChat - Explain code";
        };
      }

      # 選択した範囲の修正案を出す（ビジュアルモード）
      {
        mode = "v";
        key = "<leader>cf"; # Copilot Fix
        action = "<cmd>CopilotChatFix<CR>";
        options = {
          desc = "CopilotChat - Fix code";
        };
      }

      # 自由入力でチャットを開く（現在のバッファの内容をコンテキストにする）
      {
        mode = "n";
        key = "<leader>cq"; # Copilot Quick chat
        action = ":CopilotChat "; # <CR>を入れないことで、コマンドラインに文字を入力できる状態で止める
        options = {
          desc = "CopilotChat - Quick prompt";
          silent = false; # コマンドを表示したいのでfalse
        };
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

      toggleterm = {
        enable = true;
        settings = {
          open_mapping = "[[<C-t>]]"; # Ctrl + t でターミナルを出し入れ
          direction = "horizontal";    # 下側に開く (float や vertical も可能)
          size = 15;
        };
      };
    };

    # カラースキーム
    colorschemes.catppuccin.enable = true;

  };
}
