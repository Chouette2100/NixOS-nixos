# /etc/nixos/modules/service.nix
# { config, pkgs, ... }:
{ pkgs, ... }:

{

# MySQL
services.mysql = {
  enable = true;
  package = pkgs.mysql84;
  ensureDatabases = [ "ms" ];
  ensureUsers = [
    {
      name = "iapetus";
      ensurePermissions = { "*.*" = "ALL PRIVILEGES"; };
    }
  ];
  settings = {
    mysqld = {
      bind-address = "0.0.0.0";
    };
  };
};

# NFS
services.nfs.server = {
  enable = true;
  mountdPort = 4002;
  statdPort = 4000;
  lockdPort = 4001;
  exports = ''
    # /mnt/lxddefault/custom/default_samba 10.231.221.0/24(rw,sync,no_subtree_check,all_squash,anonuid=1001,anongid=985)
    # /mnt/lxddefault/custom/default_samba 192.168.0.0/24(rw,sync,no_subtree_check,all_squash,anonuid=1001,anongid=985)
    # /mnt/lxddefault/custom/default_samba 192.168.122.0/24(rw,sync,no_subtree_check,all_squash,anonuid=1001,anongid=985)
    /mnt/lxddefault/custom/default_samba 100.64.0.0/10(rw,sync,no_subtree_check,all_squash,anonuid=1001,anongid=985)
  '';
};

# NFSに必要なポートを開放
# networking.firewall.allowedTCPPorts = [ 111 2049 4000 4001 4002 ];
# networking.firewall.allowedUDPPorts = [ 111 2049 4000 4001 4002 ];


# Port forwarding
systemd.services.ssh-tunnel-kagoya = {
  description = "SSH Tunnel to Kagoya (Local & Reverse)";
  after = [ "network-online.target" ];
  wants = [ "network-online.target" ];
  wantedBy = [ "multi-user.target" ]; # これでログイン不要で起動

  # SSHトンネル設定
  # ローカル:9910 → リモートMySQL (127.0.0.1:3306)
  # ローカル:9384 → リモートSyncthing (127.0.0.1:8384)
  serviceConfig = {
    User = "chouette"; # 既存のSSH鍵を持つユーザー
    ExecStart = ''
      ${pkgs.openssh}/bin/ssh -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -N \
        -L 9910:127.0.0.1:3306 \
        chouette@kagoya10.tail2b675a.ts.net
    '';
    Restart = "always";
    RestartSec = "15s";
  };
};

# Port forwarding
systemd.services.ssh-tunnel-nix01 = {
  description = "SSH Tunnel to nix01 (Local)";
  after = [ "network-online.target" ];
  wants = [ "network-online.target" ];
  wantedBy = [ "multi-user.target" ]; # これでログイン不要で起動

  # SSHトンネル設定
  # ローカル:9901 → リモートmariadb (127.0.0.1:3306)
  serviceConfig = {
    User = "chouette"; # 既存のSSH鍵を持つユーザー
    ExecStart = ''
      ${pkgs.openssh}/bin/ssh -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -N \
        -L 9901:127.0.0.1:3306 \
        chouette@nix01.tail2b675a.ts.net
    '';
    Restart = "always";
    RestartSec = "15s";
  };
};

# Port forwarding
systemd.services.ssh-tunnel-ubuntu05 = {
  enable = false; # 起動時に自動でトンネルを作らない
  description = "SSH Tunnel to ubuntu05 (Local & Reverse)";
  after = [ "network-online.target" ];
  wants = [ "network-online.target" ];
  # wantedBy = [ "multi-user.target" ]; # 手動起動だけにしたい場合はコメント化

  # SSHトンネル設定
  # ローカル:9998 → リモートMySQL(REPLICA) (127.0.0.1:3306)
  serviceConfig = {
    User = "chouette"; # 既存のSSH鍵を持つユーザー
    ExecStart = ''
      ${pkgs.openssh}/bin/ssh -p 9978 -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -N \
        -L 9911:127.0.0.1:3306 \
        chouette@192.168.0.28
    '';
    Restart = "always";
    RestartSec = "15s";
  };
};

# Port forwarding
systemd.services.ssh-tunnel-LB10 = {
  description = "SSH Tunnel to LB10 (Local & Reverse)";
  after = [ "network-online.target" ];
  wants = [ "network-online.target" ];
  wantedBy = [ "multi-user.target" ]; # これでログイン不要で起動

  # SSHトンネル設定
  # ローカル:15900 → リモートVNC (127.0.0.1:5900)
  serviceConfig = {
    User = "chouette"; # 既存のSSH鍵を持つユーザー
    ExecStart = ''
      ${pkgs.openssh}/bin/ssh -p 9978 -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -N \
        -L 15900:127.0.0.1:5900 \
        chouette@192.168.0.23
    '';
    Restart = "always";
    RestartSec = "15s";
  };
};

}
