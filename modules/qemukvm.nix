# /etc/nixos/modules/containers.nix
{ config, pkgs, ... }:

{

# QEMU/KVM --------------------------
# id=4616   modelname=gemini-3-flash-preview   maxtokens=20000   [26-06-07 14:11 ( 12.7s)]
  # libvirtd デーモン + QEMU/KVM を有効化
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        # セキュアブート対応のフル機能版OVMFを使用
        packages = [ pkgs.OVMFFull.fd ];
      };
    };
  };

  # ユーザーを libvirtd グループに追加（非rootでVM管理）
  users.users.chouette.extraGroups = [ "libvirtd" "kvm" ];

  environment.systemPackages = with pkgs; [
    # virt-manager
    virt-viewer
    spice-gtk
    win-virtio
    swtpm
  ];
# -------------------------------------------------------------------------------------------

  # GUI (virt-manager) を有効化 (libvirtd や polkit も自動で設定)
  programs.virt-manager.enable = true;

  # 任意: UEFI ブート用 OVMF ファームウェア
  # virtualisation.libvirtd.qemu.ovmf.enable = true;
    #  - The 'virtualisation.libvirtd.qemu.ovmf' submodule has been removed. All OVMF images distributed with QEMU are now available by default.
    #  - Exactly one of users.users.yourusername.isSystemUser and users.users.yourusername.isNormalUser must be set.

    #  - users.users.yourusername.group is unset. This used to default to
    #  nogroup, but this is unsafe. For example you can create a group
    #  for this user with:
    #  users.users.yourusername.group = "yourusername";
    #  users.groups.yourusername = {};

  # 任意: ホスト ⇔ ゲスト間のクリップボード共有・自動リサイズ
  services.spice-vdagentd.enable = true;
}
