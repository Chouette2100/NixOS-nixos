# /etc/nixos/configuration.nix

# ビルドして結果を即時反映する
#     sudo nixos-rebuild switch --flake '.#baremetal'
# ビルドした結果を再起動後に反映する
# sudo nixos-rebuild boot --flake '.#baremetal'

# 過去の世代の一覧を表示する。
# id=4877   modelname=gemini-3-flash-preview   maxtokens=20000   [26-07-24 09:44 ( 7.7s)]
# chouette@nixos:~$ sudo nix-env -p /nix/var/nix/profiles/system --list-generations
# chouette@nixos:~$ nh os info

# { config, lib, pkgs, machineType ? "baremetal", ... }:

{ lib, pkgs, machineType ? "baremetal", ... }:

let
  isQemu = machineType == "qemu";
in
{
  nixpkgs.config.allowUnfree = true;

  # hardware.enableAllFirmware = true; # for Bluetooth

  imports = [
    ./modules/desktop.nix
    ./modules/containers.nix
    ./modules/qemukvm.nix
    ./modules/networking.nix
    ./modules/system.nix
    ./modules/service.nix
    ./modules/filesystems.nix
    ./modules/backup.nix
  ];

  # QEMU/KVM専用設定（SPICE / QXL）
  # services.spice-vdagentd.enable = isQemu; # ==> modules/containers.nix
  boot.kernelParams = lib.optionals isQemu [ "video=2560x1440@60" ];
  services.xserver.videoDrivers = lib.optionals isQemu [ "qxl" ];

  # ユーザー設定
  users.groups.chouette = { };
  users.users.chouette = {
    isNormalUser = true;
    uid = 1001;
    description = "Chouette2100";
    group = "chouette";
    extraGroups = [
      "net workmanager"
      "wheel"
      "dialout"
      "libvirtd"
      "kvm"
      "incus-admin"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIESoXUKQ+RNr/bJ99H09filTh0Xfh4E8/oK4kIV5KOeq chouette@600G4Mint"
    ];
  };

  # Polkitを有効化（通常はデスクトップ環境で有効になっていますが念のため）
  security.polkit.enable = true;

  # USBリダイレクトのためのPolkitルール
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if ((action.id == "org.spice-space.lowlevelusbaccess") &&
          subject.isInGroup("libvirtd")) {
        return polkit.Result.YES;
      }
    });
  '';

  # networking.firewall.enable = false; # test of LINE

  services.flatpak.enable = true;
  programs.steam.enable = true;

  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true; # 仮想カメラを使いたい場合
    plugins = with pkgs.obs-studio-plugins; [
      obs-vaapi # VA-API経由でIntel GPUを使うために重要
      obs-gstreamer
      obs-multi-rtmp # 同時配信したい場合
    ];
  };


  # システムパッケージ
  environment.systemPackages = with pkgs; [
    nh
    rclone
    fish
    vim
    git
    htop
    btop
    # id=4486   modelname=gemini-3-flash-preview   maxtokens=20000   [26-05-30 21:32 ( 13.3s)]
    nvtopPackages.full
    # distrobox
    # podman
    nfs-utils
    age # ageをシステムにインストール
    sops
    openssl
    minicom
    net-tools
    tigervnc
    librecad
    inkscape
    gforth
    joplin-desktop
    obsidian
    go
    gopls
    delve
    golangci-lint
    # stdenv
    gcc
    # playwright-driver.browsers
    # staticcheck
    gotools # goimports など
    impl
    gomodifytags
    go-outline
    pciutils # lspci
    usbutils # lsusb (ついでにあると便利)
    lsof
    #   google-chrome
    terminator
    keepassxc
    multitail
    xhost
    # bottles  # Wine環境をGUIで管理するツール
    # sticky
    sticky-notes
    dbeaver-bin
    luanti
    # MIDI
    rosegarden
    fluidsynth
    qsynth
    soundfont-fluid # FluidR3_GM.sf2 などが入る
    qjackctl # 必要なら
    # mysql-workbench # /usr/sbin/mysqld  Ver 8.0.45-0ubuntu0.24.04.1に対応していない
    # wineWowPackages.stable # 64bitおよび32bit環境をサポートする安定版
    # winetricks             # 各種ライブラリ導入ツール（必要に応じて）
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
