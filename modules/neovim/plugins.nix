{ ... }:
{
    # プラグイン設定
    programs.nixvim.plugins = {

    # 2. キー操作をガイドするメニュー (which-key) を有効化
    which-key = {
      enable = true;
      # メニューの見た目や挙動を細かく設定できますが、まずはデフォルトでOK
    };

      # --- デバッグ設定 (DAP) ---
      dap = {
        enable = true;
     #  extensions = {
     #    dap-ui.enable = true;    # デバッグ画面のUI
     #    dap-go.enable = true;    # Go用設定の自動化
     #    dap-virtual-text.enable = true; # 変数の値をコード上に表示
     #  };
      };
      dap-ui.enable = true;    # デバッグ画面のUI
      dap-go.enable = true;    # Go用設定の自動化
      dap-virtual-text.enable = true; # 変数の値をコード上に表示

      # デバッグ用のキーマップ（例）
      which-key.settings.spec = [
        {
          __unkeyed-1 = "<leader>d";
          group = "Debug";
        }
      ];

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

    # 3. ファイラー (Neo-tree) の導入 (LazyVimで使われているもの)
    neo-tree = {
      enable = true;
    # closeIfLastWindow = true;
      settings.close_if_last_window = true; # Neo-treeが最後のウィンドウなら自動で閉じる設定
    };

      # Copilot 本体の設定
        copilot-lua = {
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

    };
}
