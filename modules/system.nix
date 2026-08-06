# /etc/nixos/modules/system.nix
# { config, pkgs, ... }:
{ pkgs, ... }:

{
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      # options = "--delete-older-than 7d";
      options = "--delete-generations +10";
      # 「絶対に消したくない特定の世代」がある場合
      # id=4880   modelname=gemini-3-flash-preview   maxtokens=20000   [26-07-24 13:09 ( 32.8s)]
      # 現在のシステム世代を新しいプロファイル名としてリンクする
      # 例 sudo ln -s /nix/var/nix/profiles/system-165-link /nix/var/nix/profiles/stable-20241027
      # nix-gc を実行しても、この stable-20241027 が参照しているファイルは絶対に削除されません。
      # ブートメニューには自動では出ませんが、必要になった時にいつでもこの状態に戻せます。
      # もし今のシステムが壊れて、その「絶対に残したかった状態」に戻りたくなったら、
      # 以下のコマンドでそのプロファイルを現在のシステムに強制適用する。
      # sudo nix-env --profile /nix/var/nix/profiles/system --set /nix/var/nix/profiles/stable-20241027
      # sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
    };
  };
  
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

 	# id=4696   modelname=gemini-3-flash-preview   maxtokens=20000   [26-06-15 21:32 ( 16.0s)]
  boot.kernel.sysctl."kernel.unprivileged_userns_clone" = 1;


  time.timeZone = "Asia/Tokyo";
  
  # 日本語ロケール設定
  i18n.defaultLocale = "ja_JP.UTF-8";
  i18n.supportedLocales = [
    "ja_JP.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
  ];
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ja_JP.UTF-8";
    LC_IDENTIFICATION = "ja_JP.UTF-8";
    LC_MEASUREMENT = "ja_JP.UTF-8";
    LC_MONETARY = "ja_JP.UTF-8";
    LC_NAME = "ja_JP.UTF-8";
    LC_NUMERIC = "ja_JP.UTF-8";
    LC_PAPER = "ja_JP.UTF-8";
    LC_TELEPHONE = "ja_JP.UTF-8";
    LC_TIME = "ja_JP.UTF-8";
  };

  # fcitx5 + mozc 日本語入力設定
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];
  };

    # Bluetooth ハードウェアを有効化
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true; # 起動時に自動でオンにする
    settings = {
      General = {
        # A2DPなどのプロファイルを有効化
        Enable = "Source,Sink,Media,Socket";
        # 一部のヘッドセットで接続を安定させる設定
        Experimental = true;
      };
    };
  };

  # オーディオシステム（PipeWire 推奨）
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # Bluetoothオーディオの有効化
    wireplumber.enable = true;
    jack.enable = true;   # Rosegarden は JACK を使うことが多い
  };

  # PulseAudio が起動していないことを確認
  # hardware.pulseaudio.enable = false;

  # （任意）Bluetooth 管理をユーザーに許可するポリシー
  # 通常はデフォルトで大丈夫ですが、必要なら以下を追加
  # security.polkit.enable = true;

  # gnome-keyring を有効にする((distroboxの)mysql-workbench用)
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.login.enableGnomeKeyring = true; # ログイン時に自動解錠

# # CUPS印刷サービスを有効化
# services.printing = {
#   enable = true;
#   # オープンソースのブラザードライバーと自動検出用フィルタを追加
#   drivers = with pkgs; [ 
#     brlaser 
#     cups-filters 
#   ];
# };


  nixpkgs.config.allowUnfree = true;
}

