# /etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
  imports = [
    ./modules/desktop.nix
    ./modules/containers.nix
    ./modules/networking.nix
    ./modules/system.nix
    ./modules/service.nix
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
  # homeMode = "0755"; # ここでパーミッションを指定できます
    uid = 1001;
    description = "Chouette2100";
    extraGroups = [ "networkmanager" "wheel" "incus-admin" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIESoXUKQ+RNr/bJ99H09filTh0Xfh4E8/oK4kIV5KOeq chouette@600G4Mint"
    ];
  };

  users.users.ubuntu = {
    isNormalUser = true;
  # homeMode = "0755"; # ここでパーミッションを指定できます
    uid = 1000;
    description = "ubuntu";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.bashInteractive;
    initialHashedPassword = "$6$LJ25W5RoVYzQDw7E$1.Y8737sC0yDFLpQ53wkMg1ZTD0/WCdg4NoqTzLxZlePk2x.XVAcjhvKY.Gs3LC2K3DHU8nkAXKDkCEhfuyzF.";
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
    openssl
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

  # 状態バージョン
  system.stateVersion = "25.11";
}
