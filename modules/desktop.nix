# /etc/nixos/modules/desktop.nix
{ config, lib, pkgs, machineType ? "qemu", ... }:

let
  isBaremetal = machineType == "baremetal";
in

{
  services.xserver.enable = true;

  services.xserver.videoDrivers = lib.optionals isBaremetal [ "nvidia" ];

  hardware = lib.mkIf isBaremetal {
    graphics.enable = true;

    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      open = false;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

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
  
  # タスクバー上のキーボードとキーボード配列の表示にはつねに注意する

  services.xserver.xkb = {
    layout = "jp";
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

  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
  ];

}
