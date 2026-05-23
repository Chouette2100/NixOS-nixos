# /etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
  imports = [
    ./modules/desktop.nix
    ./modules/containers.nix
    ./modules/networking.nix
    ./modules/system.nix
  ];

  # SPICE ゲストエージェントサービスを有効化
# services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  # 必要に応じて SPICE 対応のグラフィックドライバを追加（QXL など）
  # QXL ドライバを使用する場合（virt-viewer などから接続）
  boot.kernelParams = [ "video=2560x1440@60" ]; # 解像度指定は任意
  services.xserver.videoDrivers = [ "qxl" ];   # X11 の場合

# # パッケージはサービスが自動的に追加するが、明示したい場合
# environment.systemPackages = with pkgs; [
#   spice-vdagent
# ];

  # ユーザー設定
  users.users.chouette = {
    isNormalUser = true;
    description = "Chouette2100";
    extraGroups = [ "networkmanager" "wheel" "incus-admin" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIESoXUKQ+RNr/bJ99H09filTh0Xfh4E8/oK4kIV5KOeq chouette@600G4Mint"
    ];
  };

  # システムパッケージ
  environment.systemPackages = with pkgs; [
    spice-vdagent
    rclone
    vim
    git
    htop
    distrobox
    nfs-utils
    age  # ageをシステムにインストール
    librecad
    inkscape
    gforth
    joplin-desktop
    obsidian
    go
#   vscode
#   neovim
#   vimPlugins.LazyVim
  ];

environment.etc."xdg/autostart/spice-vdagent.desktop".text = ''
  [Desktop Entry]
  Name=Spice vdagent
  Exec=spice-vdagent
  Type=Application
  X-GNOME-Autostart-enabled=true
  NoDisplay=true
'';

  # SSHサーバー設定
  services.openssh = {
    enable = true;
    ports = [ 9978 ];
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  networking.firewall.allowedTCPPorts = [ 9978 ];

  services.syncthing = {
    enable = true;
    user = "chouette";
    dataDir = "/home/chouette/MyProject/Obsidian"; # デフォルトの保存先
    configDir = "/home/chouette/.config/syncthing";
    guiAddress = "127.0.0.1:8384";
  };

# id=4401   modelname=deepseek-v4-flash   maxtokens=20000   [26-05-23 14:02 ( 26.5s)]
# 事前準備
# # 1. rclone をインストールして設定
# rclone config
# # → new remote → name: dropbox → type: dropbox → 認証URLにブラウザでアクセス

# # 2. テストマウント
# mkdir ~/Dropbox
# # id=4401   modelname=deepseek-v4-flash   maxtokens=20000   [26-05-23 14:02 ( 26.5s)]
# 事前準備
# # 1. rclone をインストールして設定
# rclone config
# # → new remote → name: dropbox → type: dropbox → 認証URLにブラウザでアクセス

# # 2. テストマウント
# mkdir ~/Dropbox
# rclone mount dropbox: ~/Dropbox &

# # 3. アンマウント
# fusermount -u ~/Dropbox

  {
    # rclone をインストール
    environment.systemPackages = [ pkgs.rclone ];

    # マウントポイントを自動マウントする systemd ユニットの例
    systemd.user.services.dropbox-mount = {
      description = "Dropbox mount (rclone)";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.rclone}/bin/rclone mount dropbox: /home/chouette/Dropbox --config=/home/chouette/.config/rclone/rclone.conf --daemon";
        ExecStop = "${pkgs.rclone}/bin/rclone unmount /home/chouette/Dropbox";
        Type = "forking";
        Restart = "on-failure";
      };
    };
  }

# # 3. アンマウント
# fusermount -u ~/Dropbox

  {
    # rclone をインストール
    environment.systemPackages = [ pkgs.rclone ];

    # マウントポイントを自動マウントする systemd ユニットの例
    systemd.user.services.dropbox-mount = {
      description = "Dropbox mount (rclone)";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.rclone}/bin/rclone mount dropbox: /home/chouette/Dropbox --config=/home/chouette/.config/rclone/rclone.conf --daemon";
        ExecStop = "${pkgs.rclone}/bin/rclone unmount /home/chouette/Dropbox";
        Type = "forking";
        Restart = "on-failure";
      };
    };
  }

  # 状態バージョン
  system.stateVersion = "25.11";
}
