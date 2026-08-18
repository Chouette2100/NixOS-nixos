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
  minecloniaVersion = "0.99.1";
  minetestWorldName = "world4";
  minetestWorldPath = "/var/lib/minetest/worlds/${minetestWorldName}";
  minetestLegacyWorldPath = "/home/chouette/.minetest/worlds/${minetestWorldName}";
  minecloniaGame = pkgs.stdenvNoCC.mkDerivation {
    pname = "mineclonia";
    version = minecloniaVersion;
    src = pkgs.fetchzip {
      url = "https://codeberg.org/mineclonia/mineclonia/archive/${minecloniaVersion}.tar.gz";
      hash = "sha256-+0PZUR24cILm6fgL4H/zhbHpMLK3Dg91Ihs0YfAoboU=";
      stripRoot = false;
    };
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      mkdir -p "$out/share/luanti/games/mineclonia"
      if [ -f game.conf ]; then
        cp -r . "$out/share/luanti/games/mineclonia"
      else
        cp -r ./mineclonia/. "$out/share/luanti/games/mineclonia"
      fi
    '';
  };
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
    ./modules/printer.nix
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

  # ユーザー設定
  # users.groups.chouette = { };
  users.users.nixos = {
    isNormalUser = true;
    uid = 1000;
    description = "nixos";
    group = "users";
    extraGroups = [
      "wheel"
    ];
    # openssh.authorizedKeys.keys = [
    #   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIESoXUKQ+RNr/bJ99H09filTh0Xfh4E8/oK4kIV5KOeq chouette@600G4Mint"
    # ];
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
    amdgpu_top
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

  services.minetest-server = {
    enable = true;
    # 使用するゲーム
    gameId = "mineclonia";
    # サービスユーザーが読める場所で運用する
    world = minetestWorldPath;

    # サーバー設定
    config = {
      # 管理者ユーザー名を指定（ここに追加）
      name = "chouette"; 

      server_name = "World4";
      server_description = "NixOS Minetest Server";
      max_users = 5;

      # クリエイティブモードとダメージの設定をここに追加
      creative_mode = true;
      enable_damage = false;

      # Mineclonia/MineClone2 特有のオプションが必要な場合もあります
      # (基本は上記で足りますが、念のため)
      # mcl_creative_mode = true; 

      # デフォルトで全員に与えたい権限（任意）
      # ここに fly を入れておけば、grantme を打たなくても最初から飛べます
      default_privs = "interact, shout, fast, fly, creative";

      # 家族だけが入れるようにパスワードを設定する場合
      # strict_protocol_version_checking = true;
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/minetest/.minetest 0755 minetest minetest -"
    "d /var/lib/minetest/.minetest/games 0755 minetest minetest -"
    "d /var/lib/minetest/worlds 0755 minetest minetest -"
    "d ${minetestWorldPath} 0755 minetest minetest -"
    "L+ /var/lib/minetest/.minetest/games/mineclonia - - - - ${minecloniaGame}/share/luanti/games/mineclonia"
  ];

  system.activationScripts.minetestWorldBootstrap.text = ''
    if [ ! -e "${minetestWorldPath}/world.mt" ] && [ -f "${minetestLegacyWorldPath}/world.mt" ]; then
      ${pkgs.coreutils}/bin/mkdir -p "${minetestWorldPath}"
      ${pkgs.coreutils}/bin/cp -a "${minetestLegacyWorldPath}/." "${minetestWorldPath}/"
      ${pkgs.coreutils}/bin/chown -R minetest:minetest "${minetestWorldPath}"
    fi
  '';

  # ポート開放 (デフォルトは UDP 30000)
  networking.firewall.allowedUDPPorts = [ 30000 ];

  # 状態バージョン
  system.stateVersion = "25.11";
}
