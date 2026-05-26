# /etc/nixos/configuration.nix
{ config, lib, pkgs, machineType ? "qemu", ... }:

let
  isQemu = machineType == "qemu";
in
{
  nixpkgs.config.allowUnfree = true;

  imports = [
    ./modules/desktop.nix
    ./modules/containers.nix
    ./modules/networking.nix
    ./modules/system.nix
    ./modules/service.nix
  ];

  # QEMU/KVM専用設定（SPICE / QXL）
  services.spice-vdagentd.enable = isQemu;
  boot.kernelParams = lib.optionals isQemu [ "video=2560x1440@60" ];
  services.xserver.videoDrivers = lib.optionals isQemu [ "qxl" ];

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

# users.users.ubuntu = {
#   isNormalUser = true;
# # homeMode = "0755"; # ここでパーミッションを指定できます
#   uid = 1000;
#   description = "ubuntu";
#   extraGroups = [ "networkmanager" "wheel" ];
#   shell = pkgs.bashInteractive;
#   initialHashedPassword = "$6$LJ25W5RoVYzQDw7E$1.Y8737sC0yDFLpQ53wkMg1ZTD0/WCdg4NoqTzLxZlePk2x.XVAcjhvKY.Gs3LC2K3DHU8nkAXKDkCEhfuyzF.";
#   openssh.authorizedKeys.keys = [
#     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIESoXUKQ+RNr/bJ99H09filTh0Xfh4E8/oK4kIV5KOeq chouette@600G4Mint"
#   ];
# };

  # システムパッケージ
  environment.systemPackages = with pkgs; [
    rclone
    vim
    git
    htop
    btop
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
    lsof
    google-chrome
    terminator
#   neovim
#   vimPlugins.LazyVim
  ] ++ lib.optionals isQemu [
    spice-vdagent
    nfs-utils
  ];

  environment.etc."xdg/autostart/spice-vdagent.desktop" = lib.mkIf isQemu {
    text = ''
  [Desktop Entry]
  Name=Spice vdagent
  Exec=spice-vdagent
  Type=Application
  X-GNOME-Autostart-enabled=true
  NoDisplay=true
'';
  };

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
