# /etc/nixos/modules/networking.nix
{ config, lib, pkgs, machineType ? "qemu", ... }:

let
  isQemu = machineType == "qemu";
in
{
  networking.networkmanager.enable = true;
  networking.nftables.enable = true;
  
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
