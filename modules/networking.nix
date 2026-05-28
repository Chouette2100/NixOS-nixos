# /etc/nixos/modules/networking.nix
{ config, lib, pkgs, machineType ? "qemu", ... }:

let
  isQemu = machineType == "qemu";
in
{
  networking.networkmanager.enable = true;
  networking.networkmanager.insertNameservers = [ "192.168.0.24" ];
  networking.nameservers = [ "192.168.0.24" ];
  networking.networkmanager.ensureProfiles.profiles."wired-eno1" = {
    connection = {
      id = "有線接続 1";
      type = "802-3-ethernet";
      interface-name = "eno1";
      uuid = "99e03e99-129f-39c9-a1df-6656eade4e6d";
      autoconnect = true;
    };
    ipv4 = {
      method = "auto";
      ignore-auto-dns = true;
      dns = "192.168.0.24;";
    };
    ipv6 = {
      method = "auto";
      ignore-auto-dns = true;
    };
  };
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
