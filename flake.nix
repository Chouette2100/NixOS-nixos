{
  description = "My NixOS Configuration with Incus & Distrobox";

  inputs = {
    # NixOS 25.11（現在のバージョンに合わせる）
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    
    # ホームマネージャー（オプション）
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      # 現在のホスト名を確認して設定
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        
        modules = [
          # ハードウェア設定
          ./hardware-configuration.nix
          
          # メイン設定（現在のconfiguration.nixをベースに）
          ({ config, pkgs, ... }: {
            # Nix設定
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

            # 基本設定
            boot.loader.grub.enable = true;
            boot.loader.grub.device = "/dev/vda";
            boot.loader.grub.useOSProber = true;

            networking.hostName = "nixos";
            networking.networkmanager.enable = true;
            
            # ★重要：Incusに必要
            networking.nftables.enable = true;

            time.timeZone = "Asia/Tokyo";
            
            i18n.defaultLocale = "ja_JP.UTF-8";
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

            # KDE Plasma 6
            services.xserver.enable = true;
            services.displayManager.sddm.enable = true;
            services.desktopManager.plasma6.enable = true;
            
            services.xserver.xkb = {
              layout = "jp";
              variant = "";
            };

            # サウンド
            services.pulseaudio.enable = false;
            security.rtkit.enable = true;
            services.pipewire = {
              enable = true;
              alsa.enable = true;
              alsa.support32Bit = true;
              pulse.enable = true;
            };

            # 印刷
            services.printing.enable = true;

            # ユーザー設定
            users.users.chouette = {
              isNormalUser = true;
              description = "Chouette2100";
              extraGroups = [ "networkmanager" "wheel" "incus-admin" ];
              openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIESoXUKQ+RNr/bJ99H09filTh0Xfh4E8/oK4kIV5KOeq chouette@600G4Mint"
              ];
              packages = with pkgs; [
                kdePackages.kate
              ];
            };

            # Firefox
            programs.firefox.enable = true;

            # 非フリーパッケージを許可
            nixpkgs.config.allowUnfree = true;

            # IncusとPodman
            virtualisation.incus.enable = true;
            virtualisation.podman = {
              enable = true;
              dockerCompat = true;
              # enableSocketActivationは削除（NixOS 25.11ではデフォルトで有効）
            };

            # システムパッケージ
            environment.systemPackages = with pkgs; [
              vim
              git
              htop
              distrobox
            ];

            # SSH
            # services.openssh.enable = true;
            # networking.firewall.allowedTCPPorts = [ 9978 ];

            services.openssh = {
              enable = true;
              # ポート番号をリストで指定（複数指定も可能）
              ports = [ 9978 ]; 
    
              settings = {
                PermitRootLogin = "no";
                PasswordAuthentication = false;
              };
            };

            # ファイアウォールも新しいポートを開ける
            networking.firewall.allowedTCPPorts = [ 9978 ];

  # NFSクライアントに必要なパッケージ（NixOSは自動で読み込むことが多いが念のため）
  # environment.systemPackages = [ pkgs.nfs-utils ];

  # マウントの設定
  fileSystems."/mnt/nfsh" = {
    device = "192.168.0.13:/mnt/lxddefault/custom/default_samba"; # NFSサーバーのIPとエクスポートパス
    fsType = "nfs";
    options = [
      "nfsvers=4.2"      # NFSバージョン (4.0, 4.1, 4.2)
      "rw"               # 読み書き許可
      "soft"             # タイムアウト時にエラーを返す（hardにすると応答があるまで無限リトライ）
      "intr"             # ファイル操作を中断可能にする
      "nofail"           # マウント失敗時に起動を止めない（重要）
    ];
  };

            # 状態バージョン
            system.stateVersion = "25.11";
          })
          
          # ホームマネージャー統合（オプション）
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.chouette = {
              home.stateVersion = "25.11";
              programs.bash.enable = true;
            };
          }
        ];
      };
    };
  };
}

