# /etc/nixos/modules/service.nix
{ config, pkgs, ... }:

{

# MySQL
services.mysql = {
  enable = true;
  package = pkgs.mysql80;
  # 開発用：初期設定（必要に応じて）
  ensureDatabases = [ "ms" ];
  ensureUsers = [
    {
      name = "iapetus";
      ensurePermissions = { "*.*" = "ALL PRIVILEGES"; };
    }
  ];
  # 外部（コンテナ等）から接続させる場合は bind-address を調整
  settings = {
    mysqld = {
      bind-address = "0.0.0.0";
    };
  };
};

# ファイアウォールを開ける（MySQL: 3306）
# networking.firewall.allowedTCPPorts = [ 3306 ];

# NFS
services.nfs.server = {
  enable = true;
  # 固定ポートを使用するとファイアウォール設定が楽になります
  # fixedPorts = true;
  exports = ''
  # /mnt/lxddefault/custom/default_samba 192.168.0.0/24(rw,sync,no_subtree_check,root_squash)
  # /mnt/lxddefault/custom/default_samba 192.168.122.0/24(rw,sync,no_subtree_check,root_squash)
  # /mnt/lxddefault/custom/default_samba 10.63.22.0/24(rw,sync,no_subtree_check,root_squash)
    /home/chouette/MyProject 192.168.0.0/16(rw,sync,no_subtree_check,root_squash)
  '';
};

# NFSに必要なポートを開放
networking.firewall.allowedTCPPorts = [ 111 2049 4000 4001 4002 ];
networking.firewall.allowedUDPPorts = [ 111 2049 4000 4001 4002 ];


# Port forwarding
systemd.services.ssh-tunnel-kagoya = {
  description = "SSH Tunnel to Kagoya (Local & Reverse)";
  after = [ "network-online.target" ];
  wants = [ "network-online.target" ];
  wantedBy = [ "multi-user.target" ]; # これでログイン不要で起動

  serviceConfig = {
    User = "chouette"; # 既存のSSH鍵を持つユーザー
    # 複数のトンネルを1つの接続にまとめても良いし、分けても良いです
    ExecStart = ''
      ${pkgs.openssh}/bin/ssh -p 9978 -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -N \
        -L 9910:127.0.0.1:3306 \
      # -R 8978:localhost:9978
        chouette@133.18.160.207
    '';
    Restart = "always";
    RestartSec = "15s";
  };
};

}
