# /etc/nixos/home.nix
{ config, pkgs, lib, inputs, ... }:

{
  home.stateVersion = "25.11";
  home.username = "chouette";
  home.homeDirectory = "/home/chouette";

  # SSH鍵の設定（sourceを使用）
  home.file = {
    ".ssh/id_ed25519.pub" = {
      source = ./secrets/id_ed25519.pub;
      force = true;  # 追加
    };
#   ".ssh/authorized_keys" = {
#     source = ./secrets/authorized_keys;
#     force = true;  # 追加
#   };
    # SSH設定ファイル（textを使用）
    ".ssh/config" = {
      text = ''
      Host github.com
        HostName github.com
        User git
        IdentityFile ~/.ssh/id_ed25519
        IdentitiesOnly yes
#   
#     Host *
#       AddKeysToAgent yes
#       UseKeychain yes
      '';
      force = true;
    };
  };


  # 秘密鍵の復号化をactivationScriptで実行
  home.activation = {
    decryptSSHKey = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # age鍵が存在する場合のみ復号化を実行
      if [ -f "${config.home.homeDirectory}/.config/age/key.txt" ]; then
        ${pkgs.age}/bin/age -d \
          -i "${config.home.homeDirectory}/.config/age/key.txt" \
          -o "${config.home.homeDirectory}/.ssh/id_ed25519" \
          "${config.home.homeDirectory}/NixOS-nixos/secrets/id_ed25519.age"
        
        # パーミッションを設定
        # 秘密鍵の権限
        chmod 600 "${config.home.homeDirectory}/.ssh/id_ed25519"
        # 公開鍵の権限（念のため）
        # chmod 644 "${config.home.homeDirectory}/.ssh/id_ed25519.pub"

        echo "SSH private key decrypted successfully"
      else
        echo "Warning: age key not found at ~/.config/age/key.txt"
        echo "Please decrypt manually:"
        echo "  age -d -i ~/.config/age/key.txt -o ~/.ssh/id_ed25519 ~/NixOS-nixos/secrets/id_ed25519.age"
      fi
    '';
  };

# # SSH設定ファイル（textを使用）
# xdg.configFile= {
#   "ssh/config" = {
#     text = ''
#       Host github.com
#         HostName github.com
#         User git
#         IdentityFile ~/.ssh/id_ed25519
#         IdentitiesOnly yes
#       
#       Host *
#         AddKeysToAgent yes
#         UseKeychain yes
#       '';
#     force = true;
#   };
# };

  # 権限設定
  systemd.user.tmpfiles.rules = [
    "f /home/chouette/.ssh/id_ed25519 0600 - - - -"
    "f /home/chouette/.ssh/config 0600 - - - -"
  ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    extensions = with pkgs.vscode-extensions; [
      golang.go
      mhutchie.git-graph
      ms-ceintl.vscode-language-pack-ja
      vscodevim.vim
    ];
  };

  # ユーザーセッションで spice-vdagent を自動起動
  # service.spice-vdagent.enable = true;

  # Git設定
  programs.git = {
    enable = true;
    settings = {
      user.name = "Chouette2100";
      user.email = "your-email@example.com";
      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };

  # SSHエージェント
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;  # 追加
    matchBlocks = {
      "*" = {
        forwardAgent = true;
      };
    };
  };

  # Bash設定
  programs.bash = {
    enable = true;
    shellAliases = {
      ll = "ls -la";
      update = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
      clean = "sudo nix-collect-garbage -d";
    };
    
    initExtra = ''
      export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
      
      if [ -z "$SSH_AUTH_SOCK" ]; then
        eval "$(ssh-agent -s)" > /dev/null
      fi
    '';
  };

  xdg.configFile."kscreenlockerrc".text = ''
    [Daemon]
    Autolock=false
    LockOnStartup=false
  '';

  # 便利なパッケージ
  home.packages = with pkgs; [
    neovim
    tmux
    htop
    tree
    ripgrep
    fzf
    bat
    wget
    curl
    unzip
    jq
  ];
}
