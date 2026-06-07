# /etc/nixos/modules/containers.nix
{ config, pkgs, ... }:

{

  # distrobox -------------------
  # コンテナの基本設定を有効化
  # （これにより /etc/containers/policy.json などが自動生成されます）
  virtualisation.containers.enable = true;

  # Podmanの有効化
  virtualisation.podman = {
    enable = true;
    
    # dockerコマンドのエイリアスを作成（任意）
    dockerCompat = true;
    
    # コンテナ間のDNS名前解決を有効化（推奨）
    defaultNetwork.settings.dns_enabled = true;
  };

  # コンテナ内でNVIDIA GPUを使用するための設定
  # （distroboxの --nvidia オプションを機能させるために必要です）
  hardware.nvidia-container-toolkit.enable = true;

  # Distrobox本体のインストール
  environment.systemPackages = with pkgs; [
    distrobox
  ];

# virtualisation.incus.enable = true;
# virtualisation.podman = {
#   enable = true;
#   dockerCompat = true;
# };

# incus -----------------------------
  virtualisation.incus = {
    enable = true;
    # 初回起動時に自動設定を行う（incus admin init の代わり）
    preseed = {
      networks = [
        {
          name = "incusbr0";
          type = "bridge";
          config = {
            "ipv4.address" = "10.0.0.1/24";
            "ipv4.nat" = "true";
            "ipv6.address" = "none";
          };
        }
      ];
      storage_pools = [
        {
          name = "default";
          driver = "btrfs";
          config = {
            # ここにソースを指定
          # source = "/dev/disk/by-uuid/a8b6d806-1997-4e79-a615-fd87db5de7f6";
            source = "/mnt/sda3/@incus";
          };
        }
      ];
      profiles = [
        {
          name = "default";
          devices = {
            eth0 = {
                name = "eth0";
              network = "incusbr0";
              type = "nic";
            };
            root = {
              path = "/";
                pool = "default";
              type = "disk";
            };
          };
        }
      ];
    };
  };

  # Incusのブリッジインターフェースを信頼する
  networking.firewall.trustedInterfaces = [ "incusbr0" ];
  
  # もしnftablesを使用している場合は、以下も検討
  # networking.firewall.extraCommands = ''
  #   iptables -A INPUT -i incusbr0 -p udp --dport 67 -j ACCEPT
  # '';

}
