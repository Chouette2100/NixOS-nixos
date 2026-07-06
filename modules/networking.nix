# /etc/nixos/modules/networking.nix
# { config, lib, pkgs, machineType ? "baremetal", ... }:
{ lib, machineType ? "baremetal", ... }:

let
  isQemu = machineType == "qemu";
in
{
  networking.networkmanager.enable = true;

  # DNS設定の目的:
  # - LAN内の dnsmasq サーバー (192.168.0.24) を名前解決の参照先に統一する。
  # - DHCP で配られる上位DNSではなく、まずローカルの dnsmasq を使いたい。
  #
  # 設定方針:
  # - `networking.nameservers` でシステム全体の静的DNS候補として 192.168.0.24 を入れる。
  # - `ensureProfiles` で `eno1` の NetworkManager プロファイルを宣言し、
  #   DHCP 由来の DNS を無視して 192.168.0.24 を使う。
  # - `insertNameservers` は補助的な設定として残している。
  #
  # 注意点:
  # - NetworkManager の接続がすでに張られている場合、`nixos-rebuild switch` の後に
  #   接続の再アクティベート (`nmcli connection down/up`) が必要になることがある。
  # - `wired-eno1` の `uuid` と `interface-name` は現環境の `eno1` / 「有線接続 1」用。
  #   NIC名や接続UUIDが変わった場合はここも更新する。
  networking.networkmanager.insertNameservers = [ "192.168.0.24" ];
  networking.nameservers = [ "192.168.0.24" ];

  # 実装の要点:
  # - IPv4 は DHCP でアドレスを取得しつつ DNS だけ固定する。
  # - IPv6 も自動配布DNSを無視する。必要になれば `ipv6.dns` を別途明示する。
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
    "192.168.0.18" = [ "nixos" ];
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
