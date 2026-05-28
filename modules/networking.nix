# /etc/nixos/modules/networking.nix
{ config, lib, pkgs, machineType ? "qemu", ... }:

let
  isQemu = machineType == "qemu";
in
{
  networking.networkmanager.enable = true;
  networking.networkmanager.insertNameservers = [ "192.168.0.24" ];
  networking.nftables.enable = true;
  networking.hosts = {
    "192.168.0.13" = [ "Mint221BE" ];
    "192.168.0.23" = [ "LB10" ];
    "192.168.0.16" = [ "opi" ];
    "192.168.0.21" = [ "opiwf" ];
    "192.168.0.24" = [ "LMTabKS" ];
    "192.168.0.22" = [ "LMTabKSw" ];
    "192.168.0.28" = [ "fbsd142" "ubuntu05" ];
    "192.168.0.29" = [ "obsd77" ];
    "192.168.0.19" = [ "ubuntu02" ];
    "192.168.0.27" = [ "ubuntu04" ];
    "192.168.122.21" = [ "Mint213A" ];
    "192.168.122.30" = [ "arch00" ];
    "192.168.122.84" = [ "qfbsd143" ];
    "133.18.160.207" = [ "kagoya10" ];
    "49.212.207.19" = [ "sakura" ];
  };
  
  # QEMU/KVM
  fileSystems."/mnt/nfsh" = lib.mkIf isQemu {
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
