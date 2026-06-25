# /etc/nixos/modules/desktop.nix
# { config, lib, pkgs, machineType ? "qemu", pkgs-nvidia, ... }:
{ config, lib, pkgs, machineType ? "qemu", ... }:

let
  isBaremetal = machineType == "baremetal";
in

{
  services.xserver.enable = true;

  services.xserver.videoDrivers = lib.optionals isBaremetal [ "nvidia" ];

  hardware = lib.mkIf isBaremetal {
    graphics.enable = true;
    graphics.enable32Bit = true; # for Bottles/LINE

  # nvidia = {
  #   modesetting.enable = true;
  #   powerManagement.enable = false;
  #   open = false;
  #   package = config.boot.kernelPackages.nvidiaPackages.stable;
  # };

    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      open = false;
      # package = config.boot.kernelPackages.nvidiaPackages.stable;
      # package = pkgs-nvidia.linuxPackages.nvidiaPackages.stable;
      # package = config.boot.kernelPackages.nvidiaPackages.production;
      # package = config.boot.kernelPackages.nvidiaPackages.legacy_550;
      package = config.boot.kernelPackages.nvidiaPackages.legacy_580;

    # # PRIME設定の追加
    # prime = {
    #   # 同期モード（NVIDIAを常にメインにする場合）
    #   sync.enable = true;

    #   # バスIDの指定（重要：環境に合わせて書き換えてください）
    #   # コマンド `lspci | grep -E "VGA|3D"` で確認できます
    #   intelBusId = "PCI:0:2:0";   # 例: 00:02.0 の場合
    #   nvidiaBusId = "PCI:1:0:0";  # 例: 01:00.0 の場合
    # };
    };

  };

# services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland"; # デフォルト起動を指定
        user = "greeter";
      };
    };
  };

  programs.sway = {
    enable = true;
    extraPackages = with pkgs; [
      swaylock
      swayidle
      waybar
      wofi # ランチャー
    ];
  };

  services.xserver.desktopManager.xfce.enable = true; # ←これを追加

# # Xfceをより快適にするためのオプション（任意）
# environment.systemPackages = with pkgs; [
#   xfce.xfce4-pulseaudio-plugin # パネルで音量調節
#   xfce.xfce4-whiskermenu-plugin # Mintのようなメニュー
#   networkmanagerapplet         # ネットワーク管理
# ];

  # Hyprlandの有効化
  programs.hyprland = {
    enable = true;
    xwayland.enable = true; # X11アプリ用
  };

  # 必要な依存関係（これがないと画面共有などが動かない）
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # 必要なツール群
  environment.systemPackages = with pkgs; [
    waybar        # ステータスバー
    swaynotificationcenter # 通知
#   rofi-wayland  # アプリランチャー
    rofi
    kitty         # 推奨ターミナル
    swww          # 壁紙管理
  ];

  # id=4451   modelname=deepseek-v4-pro   maxtokens=20000   [26-05-27 09:19 ( 41.1s)]
  # キーボードがUSであると半角/全角キーで「&#x60;」が出る
  # JP106配列なら半角/全角キーは別のキーコードを送る
  # 半角/全角キーで「&#x60;」が出るのであればキーボードがUSのはず
  # KDEのシステム設定 → 入力デバイス → キーボード → レイアウトを開き、  
  # もしUSだけなら、下の「追加」から日本語を加え、USを削除するか優先度を下げる
  # タスクバーのキーボード配列が（USではなく）JPになっているのが正常
  # さらにvscode+vscodevimの場合は
  #     $ code --ozone-platform=x11
  # と起動した上で
  #     Preferences: Open User Settings (JSON)
  # にある editor.editContext のチェックをはずす。
  # "editor.editContext": false  がsetig.jsonに追加される（追加する）
  
  # タスクバー上のキーボードとキーボード配列の表示にはつねに注意する

  services.xserver.xkb = {
    layout = "jp";
    model = "jp106";
  # variant = "";
  # options = "ctrl:swapcaps"; # ここで入れ替えを指定
  };

  console.keyMap = "jp106";
  # コンソール（TTY）でも入れ替えを有効にしたい場合
# console.useXkbConfig = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  services.printing.enable = true;
  programs.firefox.enable = true;

  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
  ];

}
