# /etc/nixos/modules/desktop.nix
# { lib, pkgs, machineType ? "qemu", ... }:
{ lib, pkgs, machineType ? "qemu", ... }:

let
  isBaremetal = machineType == "baremetal";
in

{
  services.xserver.enable = true;

  services.xserver.videoDrivers = lib.optionals isBaremetal [ "amdgpu" ];

  hardware = lib.mkIf isBaremetal {
    graphics.enable = true;
    graphics.enable32Bit = true; # for Bottles/LINE

  };

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

# services.greetd = {
#   enable = true;
#   settings = {
#     default_session = {
#       command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland"; # デフォルト起動を指定
#       user = "greeter";
#     };
#   };
# };

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
