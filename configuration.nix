# /etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
  imports = [
    ./modules/desktop.nix
    ./modules/containers.nix
    ./modules/networking.nix
    ./modules/system.nix
  ];

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
    vim
    git
    htop
    distrobox
    nfs-utils
    age  # ageをシステムにインストール
  ];

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

  # 状態バージョン
  system.stateVersion = "25.11";
}
