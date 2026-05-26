# /etc/nixos/modules/desktop.nix
{ config, lib, pkgs, machineType ? "qemu", ... }:

let
  isQemu = machineType == "qemu";
  isBaremetal = machineType == "baremetal";
in

{
  services.xserver.enable = true;

  # 2. X11/WaylandでNVIDIAドライバを使用するように設定
  services.xserver.videoDrivers = [ "nvidia" ];

hardware = lib.mkIf isBaremetal
{
  # 3. グラフィックス機能を有効化
  # (NixOS 24.05以降は hardware.graphics.enable です。古いバージョンなら opengl.enable)
  graphics.enable = true;

  # 4. NVIDIA固有の設定
  nvidia = {
    # モードセッティングを有効化（Wayland/KDE Plasma 6で必須）
    modesetting.enable = true;

    # 電源管理（サスペンド等で問題が出る場合は有効にする）
    powerManagement.enable = false;

    # プロプライエタリなドライバを使用
    open = false; # GT 1030 (Pascal) は新しいオープンソースドライバ非対応のため false

    # ドライバのバージョン指定（通常は stable でOK）
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
};


# services.xserver.displayManager.lightdm.enable = true;

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
# services.xserver.desktopManager.plasma6.enable = true;  # X11版の Plasma6 を有効化
# services.desktopManager.plasma6.enable = lib.mkForce false; # Wayland 版を無効化（念のため）

# services.xserver.displayManager.sddm.enable = true;

# services.xserver.desktopManager.xfce.enable = true;
# services.displayManager.defaultSession = "xfce";

 services.xserver.xkb = {
   layout = "jp";
#  variant = "jp106";
   model = "jp106";
 };

  console.keyMap = "jp106";

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

# # id=4367   modelname=deepseek-v4-flash   maxtokens=20000   [26-05-20 14:58 ( 17.6s)]
# fonts.packages = with pkgs; [
#   noto-fonts-cjk       # Noto CJK (日本語・中国語・韓国語)
#   noto-fonts-emoji     # 絵文字フォント（必要なら）
#   # お好みで他の日本語フォントも追加可能
#   ipafont             # IPAフォント
#   source-han-code-jp  # 源ノ角ゴシック Code
# ];

# id=4368   modelname=deepseek-v4-flash   maxtokens=20000   [26-05-20 15:11 ( 13.7s)]
fonts.packages = with pkgs; [
  noto-fonts-cjk-sans      # または noto-fonts-cjk-serif
  noto-fonts-cjk-serif     # 両方入れてもOK
  noto-fonts-color-emoji
];

# # 1. 日本語フォントパッケージのインストール
# fonts.packages = with pkgs; [
#   noto-fonts
#   noto-fonts-cjk-sans
#   noto-fonts-cjk-serif
#   noto-fonts-emoji
#   ipafont
#   vlgothic
# ];

# # 2. デフォルトの日本語フォントの指定 (Fontconfig)
# fonts.fontconfig = {
#   defaultFonts = {
#     serif = [ "Noto Serif CJK JP" "IPAMincho" ];
#     sansSerif = [ "Noto Sans CJK JP" "VL Gothic" ];
#     monospace = [ "Noto Sans Mono CJK JP" ];
#   };
# };

}
