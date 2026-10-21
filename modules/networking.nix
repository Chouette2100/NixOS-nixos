# /etc/nixos/modules/networking.nix
# { config, lib, pkgs, machineType ? "baremetal", ... }:
{ lib, machineType ? "baremetal", ... }:

let
  isQemu = machineType == "qemu";
in
{
  networking.networkmanager.enable = true;

  # DNS設定の目的:
  # - DHCP 配布 DNS を基本とするオーソドックスな構成に戻す。
  # - Tailscale MagicDNS が有効な場合は、それを優先的に利用する。
  # - LAN 内ホスト名は `networking.hosts` で静的に補完する。
  #
  # 設定方針:
  # - `networking.nameservers` は指定しない。DHCP 配布 DNS を尊重する。
  # - `ensureProfiles` で `eno1` の NetworkManager プロファイルを宣言し、
  #   DHCP 由来の DNS をそのまま使う。
  # - `insertNameservers` は削除済み。
  #
  # 注意点:
  # - NetworkManager の接続がすでに張られている場合、`nixos-rebuild switch` の後に
  #   接続の再アクティベート (`nmcli connection down/up`) が必要になることがある。
  # - `wired-eno1` の `uuid` と `interface-name` は現環境の `eno1` / 「有線接続 1」用。
  #   NIC名や接続UUIDが変わった場合はここも更新する。

  # 実装の要点:
  # - IPv4 / IPv6 ともに DHCP でアドレスを取得しつつ DNS も DHCP 配布 DNS を尊重する。
  # - LAN 内ホスト名は `networking.hosts` で補完する。
  # - dnsmasq (192.168.0.24) は今回の構成では使用しない。必要に応じて `networking.hosts` に移行する。
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
      # DHCP 配布 DNS をそのまま使う
      ignore-auto-dns = false;
    };
    ipv6 = {
      method = "auto";
      ignore-auto-dns = false;
    };
  };
  networking.nftables.enable = true;
  networking.hosts = {
    "133.18.160.207" = [ "kagoya10" ];
    "133.18.43.195" = [ "nix01" ];
    "49.212.207.19" = [ "sakura" ];
    "192.168.0.18" = [ "nixos" ];
    "192.168.0.16" = [ "opi" ];
    "192.168.0.21" = [ "opiwf" ];
    "192.168.0.24" = [ "LMTabKS" ];
    "192.168.0.22" = [ "LMTabKSw" ];
    "192.168.0.23" = [ "LB10" ];
    "192.168.0.19" = [ "ubuntu02" ];
    "192.168.0.27" = [ "ubuntu04" ];
    "192.168.0.28" = [ "fbsd142" "ubuntu05" ];
    "192.168.0.29" = [ "obsd77" ];
    "192.168.122.21" = [ "Mint213A" ];
    "192.168.122.30" = [ "arch00" ];
    "192.168.122.84" = [ "qfbsd143" ];
    "10.0.0.26" = [ "vscode01" ];
  };
  
  # QEMU/KVM
  fileSystems."/mnt/nfsh" = lib.mkIf isQemu {
    device = "192.168.0.18:/mnt/lxddefault/custom/default_samba";
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
