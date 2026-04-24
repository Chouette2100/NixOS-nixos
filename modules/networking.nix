# /etc/nixos/modules/networking.nix
{ config, pkgs, ... }:

{
  networking.networkmanager.enable = true;
  networking.nftables.enable = true;
  
  # NFSマウント
  fileSystems."/mnt/nfsh" = {
    device = "192.168.0.13:/mnt/lxddefault/custom/default_samba";
    fsType = "nfs";
    options = [
      "nfsvers=4.2"
      "rw"
      "soft"
      "intr"
      "nofail"
    ];
  };
}
