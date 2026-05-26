# /etc/nixos/modules/service.nix
{ config, pkgs, ... }:

{

# MySQL
services.mysql = {
  enable = true;
  package = pkgs.mysql80;
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
  exports = ''
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
    ExecStart = ''
      ${pkgs.openssh}/bin/ssh -p 9978 -o ServerAliveInterval=60 -o ExitOnForwardFailure=yes -N \
        -L 9910:127.0.0.1:3306 \
        chouette@133.18.160.207
    '';
    Restart = "always";
    RestartSec = "15s";
  };
};

}
