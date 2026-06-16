# /etc/nixos/modules/system.nix
{ config, pkgs, ... }:

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
      options = "--delete-older-than 7d";
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

  # 環境変数（アプリケーションがfcitx5を認識するため）
  environment.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
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
  };

  # PulseAudio が起動していないことを確認
  # hardware.pulseaudio.enable = false;

  # （任意）Bluetooth 管理をユーザーに許可するポリシー
  # 通常はデフォルトで大丈夫ですが、必要なら以下を追加
  # security.polkit.enable = true;

  # gnome-keyring を有効にする((distroboxの)mysql-workbench用)
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.login.enableGnomeKeyring = true; # ログイン時に自動解錠


  nixpkgs.config.allowUnfree = true;
}

